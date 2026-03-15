#!/usr/bin/env bash
# forge-smoke-test.sh — Deterministic harness for agent-forge smoke tests
#
# Tests the cold-start experience: someone clones agent-forge and uses it
# to bootstrap agent systems for projects that have never seen the forge.
#
# Designed to be driven by the ops steward. The LLM-powered phases (bootstrap
# and quality eval) run as steward subagents instead of claude -p, so there's
# no extra API cost per run.
#
# Subcommands:
#   setup [ref]       Phases 1-3: clone, leak scan, security scan, create projects.
#                     Writes bootstrap + eval prompts to work dir.
#                     Prints WORK_DIR and CLONE_DIR for the steward.
#                     ref: branch or tag to test (default: main)
#
#   validate <dir>    Phase 5: structural checks + security scan on bootstrapped
#                     projects. Run after the steward's bootstrap agent finishes.
#
#   report <dir>      Phase 7: aggregate results into final report.
#                     Run after validate (and optionally after eval agent).
#
# Steward workflow (pre-release):
#   1. bash forge-smoke-test.sh setup            # tests main
#   2. If setup finds leaks: spawn forge smith agent to fix them in
#      agent-forge, then re-run setup to verify
#   3. Spawn agent with $WORK_DIR/bootstrap_prompt.txt
#   4. bash forge-smoke-test.sh validate $WORK_DIR
#   5. Spawn agent with $WORK_DIR/eval_prompt.txt  (can be a
#      thisminute-forge agent — read-only eval, no extra cost)
#   6. bash forge-smoke-test.sh report $WORK_DIR
#   7. If passed: tag and push
#
# Security scan coverage (16 checks per file):
#   URLs, sensitive file refs, network requests, encoding/eval,
#   confirmation bypass, system paths, push/deploy, env vars,
#   prompt injection, write-to-sensitive, shell injection,
#   hidden unicode, security tooling disabling, git exfiltration,
#   clipboard access, destructive operations
#
# Prerequisites: git, grep (GNU with -P), awk
# Run by: ops steward, before tagging agent-forge releases

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_FORGE_PATH="${AGENT_FORGE_PATH:-$(cd "$SCRIPT_DIR/.." && cd agent-forge && pwd)}"
TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M UTC')

# ── Helpers ─────────────────────────────────────────────────────────────

log()  { echo "[$1] $2"; }

record() {
  # Append a result line to the state file
  local work_dir="$1" level="$2" msg="$3"
  echo "$level: $msg" >> "$work_dir/.results"
  log "$level" "$msg"
}

count_results() {
  local work_dir="$1"
  local file="$work_dir/.results"
  [ -f "$file" ] || { echo "0 0 0"; return; }
  # grep -c outputs "0" AND exits 1 when no matches, so || echo 0
  # inside $() would produce "0\n0". Use || var=0 pattern instead.
  local p f w
  p=$(grep -c "^PASS:" "$file" 2>/dev/null) || p=0
  f=$(grep -c "^FAIL:" "$file" 2>/dev/null) || f=0
  w=$(grep -c "^WARN:" "$file" 2>/dev/null) || w=0
  echo "$p $f $w"
}

strip_code_fences() {
  # Output only lines outside ``` code blocks.
  # Used to avoid false positives on code examples in pattern files.
  awk '/^```/{fence=!fence;next} !fence{print}' "$1"
}

# ── Security File Scanner ─────────────────────────────────────────────
#
# Per-file security scan. Called from phase 2b (on forge source files)
# and phase 5 (on LLM-generated output).
#
# Modes:
#   normal — forge source files; URL allowlist, forgemaster exemptions
#   strict — generated output; no allowlists, warnings become failures

scan_file_security() {
  local file="$1" work_dir="$2" label="$3" mode="${4:-normal}"
  local name
  name=$(basename "$file")

  # In strict mode, warnings escalate to failures
  local sev_warn="WARN"
  if [ "$mode" = "strict" ]; then
    sev_warn="FAIL"
  fi

  # ── 1. Unexpected URLs ──────────────────────────────────────────────
  local url_filter='(example\.com|localhost|127\.0\.0\.1)'
  if [ "$mode" = "normal" ]; then
    url_filter='(github\.com/skondrashov/agent-forge|keepachangelog\.com|semver\.org|example\.com|localhost|127\.0\.0\.1)'
  fi
  local suspicious_urls
  suspicious_urls=$(grep -oiE 'https?://[^ )>"]+' "$file" 2>/dev/null | grep -viE "$url_filter" || true)
  if [ -n "$suspicious_urls" ]; then
    record "$work_dir" FAIL "SECURITY: $label contains unexpected URL(s): $(echo "$suspicious_urls" | head -3 | tr '\n' ' ')"
  fi

  # ── 2. Sensitive file references ────────────────────────────────────
  if grep -qiE '\.(env|pem|key|crt|credentials|secret|password|token)\b' "$file" 2>/dev/null; then
    local suspicious
    suspicious=$(grep -iE '\.(env|pem|key|crt|credentials|secret|password|token)\b' "$file" 2>/dev/null \
      | grep -viE '(never|don.t|avoid|ignore|gitignore|exclude|protect|sensitive|\.gitignore)' || true)
    if [ -n "$suspicious" ]; then
      record "$work_dir" "$sev_warn" "SECURITY: $label references sensitive file types — verify intent"
    fi
  fi

  # ── 3. Network exfiltration ─────────────────────────────────────────
  if grep -iE '(curl|wget|http\.get|requests\.(get|post)|urllib|httpx|fetch\()' "$file" 2>/dev/null \
     | grep -qviE 'git fetch'; then
    record "$work_dir" FAIL "SECURITY: $label contains network request instructions"
  fi

  # ── 4. Encoding / obfuscation ───────────────────────────────────────
  if grep -qiE '(base64|btoa|atob|\\x[0-9a-f]{2}|eval\(|exec\()' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label contains encoding/eval instructions"
  fi

  # ── 5. Confirmation bypass ──────────────────────────────────────────
  if grep -qiE '(--no-verify|--force|--yes\b|without asking|skip review|auto.?approve|do not (ask|confirm|prompt))' "$file" 2>/dev/null; then
    record "$work_dir" "$sev_warn" "SECURITY: $label may bypass user confirmation — verify intent"
  fi

  # ── 6. System paths (read access) ──────────────────────────────────
  if grep -qiE '(/etc/|/home/|/root/|/var/|~\/\.|%APPDATA%|%USERPROFILE%)' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label references system paths outside project scope"
  fi

  # ── 7. Push / deploy instructions ──────────────────────────────────
  if grep -qiE '(git push|git remote add|deploy|scp |rsync |ssh )' "$file" 2>/dev/null; then
    # In normal mode, forgemaster.md may reference git push for upstream checks
    if [ "$mode" = "strict" ] || [ "$name" != "forgemaster.md" ] || \
       grep -qiE '(scp |rsync |ssh |deploy)' "$file" 2>/dev/null; then
      record "$work_dir" "$sev_warn" "SECURITY: $label contains push/deploy instructions — verify scope"
    fi
  fi

  # ── 8. Environment variable access ─────────────────────────────────
  if grep -qiE '(printenv|\benv\b|os\.environ|process\.env|System\.Environment)' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label references environment variables"
  fi

  # ── 9. Prompt injection markers ─────────────────────────────────────
  if grep -qiE '(ignore (previous|above|prior|all) instructions|disregard.{0,20}(previous|above|prior)|you are now|act as (if|though)|pretend (to be|you)|override.{0,20}(instruction|rule|guard)|system prompt|<\|im_start\|>|<\|endoftext\|>|\[INST\]|\[\/INST\])' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label contains prompt injection markers"
  fi

  # ── 10. Write to sensitive locations ────────────────────────────────
  if grep -qiE '(write|create|save|output|append|overwrite).{0,40}(/etc/|/home/|/root/|/var/|~/\.|\.ssh/|authorized_keys|crontab|%APPDATA%|%USERPROFILE%)' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label instructs writing to sensitive system locations"
  fi

  # ── 11. Shell command injection (outside code fences) ───────────────
  if strip_code_fences "$file" | grep -qE '(\$\([^)]+\)|;\s*(rm|chmod|chown|kill|dd |mkfs)|>\s*/dev/|>\s*/etc/|>\s*/tmp/)' 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label contains shell injection patterns (outside code fences)"
  fi

  # ── 12. Hidden unicode (zero-width, RTL override, BOM) ─────────────
  # Match raw UTF-8 bytes for: U+200B-200F, U+202A-202E, U+2060, U+FEFF
  if LC_ALL=C grep -P '\xe2\x80[\x8b-\x8f]|\xe2\x80[\xaa-\xae]|\xe2\x81\xa0|\xef\xbb\xbf' "$file" >/dev/null 2>&1; then
    record "$work_dir" FAIL "SECURITY: $label contains hidden unicode characters (zero-width/RTL/BOM)"
  fi

  # ── 13. Security tooling disabling (outside code fences) ────────────
  if strip_code_fences "$file" | grep -qiE '(disable|remove|delete|modify|edit|turn off).{0,30}(\.gitignore|pre-commit|\.eslint|\.prettier|ci\.yml|\.github.workflows|security|linter|hook)' 2>/dev/null; then
    record "$work_dir" "$sev_warn" "SECURITY: $label may disable security tooling — verify intent"
  fi

  # ── 14. Git data exfiltration ───────────────────────────────────────
  if grep -qiE 'git\s+(send-email|bundle|archive|format-patch)|git\s+remote\s+set-url' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label contains git exfiltration commands"
  fi

  # ── 15. Clipboard / stdin access ────────────────────────────────────
  if grep -qiE '(pbcopy|pbpaste|xclip|xsel|clip\.exe|Get-Clipboard|Set-Clipboard|/dev/stdin)' "$file" 2>/dev/null; then
    record "$work_dir" FAIL "SECURITY: $label contains clipboard/stdin access"
  fi

  # ── 16. Destructive operations (outside code fences) ────────────────
  if strip_code_fences "$file" | grep -qiE '(rm\s+-rf|rmdir\s|DROP\s+TABLE|TRUNCATE\s|DELETE\s+FROM|format\s+[A-Z]:|mkfs\.|shred\b)' 2>/dev/null; then
    record "$work_dir" "$sev_warn" "SECURITY: $label contains destructive operation instructions — verify intent"
  fi
}

# ── Phase 1: Clone ─────────────────────────────────────────────────────

phase1_clone() {
  local work_dir="$1" ref="$2"
  log "INFO" "Phase 1: Cloning agent-forge at $ref..."
  local clone_dir="$work_dir/agent-forge"
  git clone "$AGENT_FORGE_PATH" "$clone_dir" 2>/dev/null
  git -C "$clone_dir" checkout "$ref" 2>/dev/null

  # Basic template structure
  [ -f "$clone_dir/CLAUDE.md" ]          && record "$work_dir" PASS "CLAUDE.md exists"          || record "$work_dir" FAIL "CLAUDE.md missing"
  [ -f "$clone_dir/AGENTS.md" ]          && record "$work_dir" PASS "AGENTS.md exists"          || record "$work_dir" FAIL "AGENTS.md missing"
  [ -f "$clone_dir/README.md" ]          && record "$work_dir" PASS "README.md exists"          || record "$work_dir" FAIL "README.md missing"
  [ -d "$clone_dir/agents" ]             && record "$work_dir" PASS "agents/ directory exists"  || record "$work_dir" FAIL "agents/ directory missing"
  [ -d "$clone_dir/patterns" ]           && record "$work_dir" PASS "patterns/ directory exists"|| record "$work_dir" FAIL "patterns/ directory missing"
  [ -d "$clone_dir/audits" ]             && record "$work_dir" PASS "audits/ directory exists"  || record "$work_dir" FAIL "audits/ directory missing"

  # CLAUDE.md should point to AGENTS.md
  if grep -qi "AGENTS.md" "$clone_dir/CLAUDE.md" 2>/dev/null; then
    record "$work_dir" PASS "CLAUDE.md references AGENTS.md"
  else
    record "$work_dir" FAIL "CLAUDE.md does not reference AGENTS.md"
  fi

  # Role files exist for all 4 forge roles
  for role in forgemaster assayer smith keeper; do
    [ -f "$clone_dir/agents/$role.md" ] && record "$work_dir" PASS "agents/$role.md exists" || record "$work_dir" FAIL "agents/$role.md missing"
  done

  # Pattern files have required sections
  for pattern in "$clone_dir"/patterns/*.md; do
    name=$(basename "$pattern")
    if grep -q "## When to" "$pattern" 2>/dev/null || grep -q "**When to" "$pattern" 2>/dev/null; then
      record "$work_dir" PASS "patterns/$name has When-to guidance"
    else
      record "$work_dir" WARN "patterns/$name missing When-to-use/skip guidance"
    fi
  done
}

# ── Phase 2: Leak Scan ─────────────────────────────────────────────────

phase2_leak_scan() {
  local work_dir="$1"
  local clone_dir="$work_dir/agent-forge"
  log "INFO" "Phase 2: Scanning for ecosystem-specific data leaks..."

  LEAK_PATTERNS=(
    "skondrashov"       # GitHub username
    "tkond"             # Local username
    "136\.119"          # VM IP
    "/opt/thisminute"   # VM paths
    "DEPLOY_QUEUE"      # Ops-specific
    "mainmenu"          # Ecosystem project
    "balatro"           # Ecosystem project
    "sts2"              # Ecosystem project
    "rhizome"           # Ecosystem project (as project name, not concept)
  )

  local leaks_found=0
  for pattern in "${LEAK_PATTERNS[@]}"; do
    matches=$(grep -ri "$pattern" "$clone_dir" --include="*.md" -l 2>/dev/null | grep -v -E '(README|CHANGELOG|SECURITY)\.md' || true)
    if [ -n "$matches" ]; then
      record "$work_dir" FAIL "Leak: '$pattern' found in: $(echo "$matches" | xargs -I{} basename {})"
      leaks_found=$((leaks_found + 1))
    fi
  done

  # README.md, CHANGELOG.md, SECURITY.md — only flag non-provenance leaks
  # (allowed: thisminute.org as origin in README, GitHub URLs in CHANGELOG/SECURITY)
  for file in README.md CHANGELOG.md SECURITY.md; do
    for pattern in "tkond" "136\.119" "/opt/" "DEPLOY_QUEUE"; do
      if grep -qi "$pattern" "$clone_dir/$file" 2>/dev/null; then
        record "$work_dir" FAIL "Leak in $file: '$pattern' (not provenance)"
        leaks_found=$((leaks_found + 1))
      fi
    done
  done

  if [ "$leaks_found" -eq 0 ]; then
    record "$work_dir" PASS "No ecosystem-specific data leaks detected"
  fi
}

# ── Phase 2b: Security Scan ───────────────────────────────────────────
#
# Scans forge source files (agents/*.md, patterns/*.md) for dangerous
# patterns using the shared scan_file_security() function, plus
# directory-level structural checks.

phase2b_security_scan() {
  local work_dir="$1"
  local clone_dir="$work_dir/agent-forge"
  log "INFO" "Phase 2b: Security scan of role files and patterns (16 checks/file)..."

  # Count security findings before scan
  local before=0
  before=$(grep -c "SECURITY:" "$work_dir/.results" 2>/dev/null) || before=0

  # Scan each prompt file
  local prompt_files
  prompt_files=$(find "$clone_dir/agents" "$clone_dir/patterns" -name "*.md" 2>/dev/null)

  for file in $prompt_files; do
    local label
    label="$(basename "$(dirname "$file")")/$(basename "$file")"
    scan_file_security "$file" "$work_dir" "$label" "normal"
  done

  # ── Directory-level checks ──────────────────────────────────────────

  # Verify README has security warning (disclaimer or security section with SECURITY.md link)
  if grep -qiE '(supply chain|security|disclaimer)' "$clone_dir/README.md" 2>/dev/null; then
    if grep -qiE '(SECURITY\.md|read.*before|review.*before|vet.*before)' "$clone_dir/README.md" 2>/dev/null; then
      record "$work_dir" PASS "SECURITY: README contains security warning with actionable guidance"
    else
      record "$work_dir" WARN "SECURITY: README mentions security but may not direct users to review files"
    fi
  else
    record "$work_dir" FAIL "SECURITY: README missing security warning"
  fi

  # Check that no files are executable (they shouldn't be — these are prompts)
  local executables
  executables=$(find "$clone_dir/agents" "$clone_dir/patterns" -type f -executable 2>/dev/null || true)
  if [ -n "$executables" ]; then
    record "$work_dir" WARN "SECURITY: Executable files found in prompt directories: $executables"
  fi

  # Check for non-.md files in agents/ and patterns/ (unexpected file types)
  local non_md
  non_md=$(find "$clone_dir/agents" "$clone_dir/patterns" -type f ! -name "*.md" 2>/dev/null || true)
  if [ -n "$non_md" ]; then
    record "$work_dir" FAIL "SECURITY: Non-markdown files in prompt directories: $non_md"
  fi

  # Summary
  local after=0
  after=$(grep -c "SECURITY:" "$work_dir/.results" 2>/dev/null) || after=0
  if [ "$after" -eq "$before" ]; then
    record "$work_dir" PASS "SECURITY: No dangerous patterns detected in role files or templates"
  fi
}

# ── Phase 3: Create Synthetic Projects ──────────────────────────────────

phase3_create_projects() {
  local work_dir="$1"
  log "INFO" "Phase 3: Creating synthetic test projects..."

  # Project 1: Multi-developer Go API
  mkdir -p "$work_dir/recipe-api/cmd/server" "$work_dir/recipe-api/internal/handlers"
  git -C "$work_dir/recipe-api" init -q
  cat > "$work_dir/recipe-api/README.md" << 'EOF'
# recipe-api

REST API for recipe management. Built in Go with PostgreSQL.

## Stack
- Go 1.22, chi router, sqlc for queries
- PostgreSQL 16, migrations via golang-migrate
- Docker Compose for local dev

## Endpoints
- /api/recipes — CRUD for recipes (title, ingredients, steps, tags)
- /api/users — User accounts, profile management
- /api/auth — JWT auth, refresh tokens
- /api/search — Full-text search across recipes

## Team
3 developers. One focused on API/auth, one on data layer/search, one on infra/deploy.
EOF
  cat > "$work_dir/recipe-api/cmd/server/main.go" << 'EOF'
package main

import "fmt"

func main() {
	fmt.Println("recipe-api server")
}
EOF
  git -C "$work_dir/recipe-api" add -A && git -C "$work_dir/recipe-api" commit -qm "Initial commit" 2>/dev/null

  # Project 2: Multi-stack app
  mkdir -p "$work_dir/study-buddy/frontend/src" "$work_dir/study-buddy/backend/app"
  git -C "$work_dir/study-buddy" init -q
  cat > "$work_dir/study-buddy/README.md" << 'EOF'
# study-buddy

Flashcard app with spaced repetition (SM-2 algorithm).

## Stack
- Frontend: React 19, TypeScript, Vite, TailwindCSS
- Backend: Python 3.12, FastAPI, SQLite
- Shared: OpenAPI spec for contract

## Features
- Create/edit decks and cards (markdown support)
- Spaced repetition scheduling per-card
- Deck sharing via public links
- Study statistics and streak tracking

## Team
3 developers. Frontend specialist, backend specialist, one generalist.
EOF
  cat > "$work_dir/study-buddy/frontend/src/App.tsx" << 'EOF'
export default function App() {
  return <div>study-buddy</div>
}
EOF
  cat > "$work_dir/study-buddy/backend/app/main.py" << 'EOF'
from fastapi import FastAPI
app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}
EOF
  git -C "$work_dir/study-buddy" add -A && git -C "$work_dir/study-buddy" commit -qm "Initial commit" 2>/dev/null

  # Project 3: Solo hobby project
  mkdir -p "$work_dir/greenhouse"
  git -C "$work_dir/greenhouse" init -q
  cat > "$work_dir/greenhouse/README.md" << 'EOF'
# greenhouse

Raspberry Pi sensor dashboard for my greenhouse. Hobby project, just me.

## What it does
- Reads DHT22 temperature/humidity sensors every 5 minutes
- Stores readings in SQLite
- Serves a simple dashboard at :8080 (Chart.js graphs)
- Sends Pushover alerts if temp drops below 5C or above 40C

## Stack
Python 3.11, Flask, SQLite, Chart.js. Runs on a Pi 4.
EOF
  cat > "$work_dir/greenhouse/sensors.py" << 'EOF'
import time
import sqlite3

def read_sensor():
    """Read DHT22 sensor (stubbed for dev)."""
    return {"temperature": 22.5, "humidity": 65.0}

def store_reading(db_path, reading):
    conn = sqlite3.connect(db_path)
    conn.execute(
        "INSERT INTO readings (temperature, humidity, ts) VALUES (?, ?, ?)",
        (reading["temperature"], reading["humidity"], time.time())
    )
    conn.commit()
    conn.close()
EOF
  git -C "$work_dir/greenhouse" add -A && git -C "$work_dir/greenhouse" commit -qm "Initial commit" 2>/dev/null

  record "$work_dir" PASS "3 synthetic projects created"
}

# ── Write Prompts ──────────────────────────────────────────────────────

write_prompts() {
  local work_dir="$1"
  local clone_dir="$work_dir/agent-forge"

  # Bootstrap prompt — for steward to spawn as agent
  cat > "$work_dir/bootstrap_prompt.txt" << PROMPT_EOF
You are in a fresh clone of agent-forge at: $clone_dir

Read the patterns in $clone_dir/patterns/ first, then bootstrap agent systems for 3 projects.

Projects:
1. recipe-api ($work_dir/recipe-api) — Go REST API, 3 developers (API/auth, data/search, infra). Read its README.
2. study-buddy ($work_dir/study-buddy) — React+Python app, 3 developers (frontend, backend, generalist). Read its README.
3. greenhouse ($work_dir/greenhouse) — Raspberry Pi sensor dashboard, solo hobby project. Read its README.

For each project, create: CLAUDE.md, AGENTS.md, and role files in agents/. Adapt patterns to the domain — don't paste templates verbatim. Greenhouse is steward-scale (1-2 agents). The others need multi-agent setups.

Register all 3 in $clone_dir/AGENTS.md and write audit results to $clone_dir/audits/current.md.
PROMPT_EOF

  # Eval prompt — for steward to spawn as read-only agent
  cat > "$work_dir/eval_prompt.txt" << PROMPT_EOF
You are reviewing the output of an agent-forge smoke test. The forge bootstrapped agent systems for 3 synthetic projects. This is a READ-ONLY evaluation — do not modify any files.

Projects to review:
- $work_dir/recipe-api/ — Go REST API, 3 developers (expected: multi-agent with protocol or forum)
- $work_dir/study-buddy/ — React+Python app, 3 developers (expected: multi-agent, possibly ref doc splitting)
- $work_dir/greenhouse/ — Solo hobby project (expected: single steward agent)
- $clone_dir/ — The forge clone (check AGENTS.md registry and audits/current.md)

Evaluate each project on:
1. Pattern selection — appropriate coordination model for size/complexity?
2. Domain adaptation — role files adapted to the domain, or generic paste jobs?
3. AGENTS.md quality — accurately describes the project and setup?
4. Completeness — all necessary files present and cross-referenced?
5. Proportionality — agent system appropriately sized?

Also check for leaked ecosystem data and whether CLAUDE.md -> AGENTS.md chains work.

Output: structured markdown report, scores (Good/Acceptable/Poor) per criterion, specific examples. End with: OVERALL: [PASS/MARGINAL/FAIL]

Write your report to $work_dir/eval_output.txt
PROMPT_EOF

  log "INFO" "Prompts written to $work_dir/bootstrap_prompt.txt and eval_prompt.txt"
}

# ── Phase 5: Structural Validation (Deterministic) ─────────────────────
#
# Validates LLM-generated output: structural invariants, cross-references,
# quality signals, and a full security scan in strict mode.

phase5_validate() {
  local work_dir="$1"
  local clone_dir="$work_dir/agent-forge"
  log "INFO" "Phase 5: Validating structural invariants..."

  for project in recipe-api study-buddy greenhouse; do
    local dir="$work_dir/$project"

    # ── File existence ────────────────────────────────────────────────

    # CLAUDE.md exists and points to AGENTS.md
    if [ -f "$dir/CLAUDE.md" ]; then
      record "$work_dir" PASS "$project: CLAUDE.md exists"
      if grep -qi "AGENTS.md" "$dir/CLAUDE.md"; then
        record "$work_dir" PASS "$project: CLAUDE.md references AGENTS.md"
      else
        record "$work_dir" FAIL "$project: CLAUDE.md does not reference AGENTS.md"
      fi
    else
      record "$work_dir" FAIL "$project: CLAUDE.md missing"
    fi

    # AGENTS.md exists and has content
    if [ -f "$dir/AGENTS.md" ]; then
      local lines
      lines=$(wc -l < "$dir/AGENTS.md")
      if [ "$lines" -gt 5 ]; then
        record "$work_dir" PASS "$project: AGENTS.md has content ($lines lines)"
      else
        record "$work_dir" WARN "$project: AGENTS.md is very short ($lines lines)"
      fi
    else
      record "$work_dir" FAIL "$project: AGENTS.md missing"
    fi

    # agents/ directory with role files
    if [ -d "$dir/agents" ]; then
      local agent_count
      agent_count=$(find "$dir/agents" -name "*.md" | wc -l)
      if [ "$agent_count" -gt 0 ]; then
        record "$work_dir" PASS "$project: agents/ has $agent_count role file(s)"
      else
        record "$work_dir" FAIL "$project: agents/ exists but is empty"
      fi

      for role_file in "$dir"/agents/*.md; do
        [ -f "$role_file" ] || continue
        local role_name role_lines
        role_name=$(basename "$role_file")
        role_lines=$(wc -l < "$role_file")
        if [ "$role_lines" -lt 3 ]; then
          record "$work_dir" WARN "$project: agents/$role_name is nearly empty ($role_lines lines)"
        fi
      done
    else
      if [ "$project" = "greenhouse" ]; then
        record "$work_dir" WARN "$project: no agents/ directory (acceptable if steward is minimal)"
      else
        record "$work_dir" FAIL "$project: agents/ directory missing"
      fi
    fi

    # ── Ecosystem leak scan ───────────────────────────────────────────

    for pattern in "thisminute" "skondrashov" "mainmenu" "balatro" "sts2" "rhizome"; do
      if grep -ri "$pattern" "$dir" --include="*.md" -q 2>/dev/null; then
        record "$work_dir" FAIL "$project: contains ecosystem reference '$pattern'"
      fi
    done

    # ── Cross-reference validation ────────────────────────────────────

    # Agent files referenced in AGENTS.md must exist
    if [ -f "$dir/AGENTS.md" ]; then
      local refs
      refs=$(grep -oE 'agents/[a-zA-Z0-9_-]+\.md' "$dir/AGENTS.md" 2>/dev/null | sort -u || true)
      for ref in $refs; do
        if [ -f "$dir/$ref" ]; then
          record "$work_dir" PASS "$project: $ref referenced in AGENTS.md (exists)"
        else
          record "$work_dir" FAIL "$project: $ref referenced in AGENTS.md (missing)"
        fi
      done
    fi

    # Orphan detection: agent files that exist but aren't in AGENTS.md
    if [ -d "$dir/agents" ] && [ -f "$dir/AGENTS.md" ]; then
      for role_file in "$dir"/agents/*.md; do
        [ -f "$role_file" ] || continue
        local role_basename
        role_basename=$(basename "$role_file" .md)
        if ! grep -qi "$role_basename" "$dir/AGENTS.md" 2>/dev/null; then
          record "$work_dir" WARN "$project: agents/$(basename "$role_file") exists but not referenced in AGENTS.md"
        fi
      done
    fi

    # ── Structural quality ────────────────────────────────────────────

    # CLAUDE.md should be a slim pointer, not a novel
    if [ -f "$dir/CLAUDE.md" ]; then
      local claude_lines
      claude_lines=$(wc -l < "$dir/CLAUDE.md")
      if [ "$claude_lines" -gt 10 ]; then
        record "$work_dir" WARN "$project: CLAUDE.md is $claude_lines lines — should be a slim pointer"
      fi
    fi

    # Role files should have a Purpose or Role heading
    if [ -d "$dir/agents" ]; then
      for role_file in "$dir"/agents/*.md; do
        [ -f "$role_file" ] || continue
        if ! grep -qiE '^#.*(purpose|role|what you do|responsibilit)' "$role_file" 2>/dev/null; then
          record "$work_dir" WARN "$project: $(basename "$role_file") missing Purpose/Role heading"
        fi
      done
    fi

    # Duplicate agent names (case-insensitive)
    if [ -d "$dir/agents" ]; then
      local dupes
      dupes=$(find "$dir/agents" -name "*.md" -exec basename {} .md \; 2>/dev/null \
        | tr '[:upper:]' '[:lower:]' | sort | uniq -d || true)
      if [ -n "$dupes" ]; then
        record "$work_dir" FAIL "$project: duplicate agent names (case-insensitive): $dupes"
      fi
    fi

    # ── Artifact leak checks ──────────────────────────────────────────

    # No .claude/ directory (session artifact)
    if [ -d "$dir/.claude" ]; then
      record "$work_dir" FAIL "$project: .claude/ directory found (session artifact leak)"
    fi

    # No executable markdown files
    local exec_md
    exec_md=$(find "$dir" -name "*.md" -type f -executable 2>/dev/null || true)
    if [ -n "$exec_md" ]; then
      record "$work_dir" WARN "$project: executable markdown files found"
    fi

    # No non-.md files in agents/
    if [ -d "$dir/agents" ]; then
      local non_md
      non_md=$(find "$dir/agents" -type f ! -name "*.md" 2>/dev/null || true)
      if [ -n "$non_md" ]; then
        record "$work_dir" FAIL "$project: non-markdown files in agents/: $(echo "$non_md" | xargs -I{} basename {})"
      fi
    fi
  done

  # ── Scale checks ────────────────────────────────────────────────────

  # greenhouse should be steward-scale (1-2 agents)
  if [ -d "$work_dir/greenhouse/agents" ]; then
    local gh_agents
    gh_agents=$(find "$work_dir/greenhouse/agents" -name "*.md" | wc -l)
    if [ "$gh_agents" -gt 3 ]; then
      record "$work_dir" WARN "greenhouse: has $gh_agents agents — expected steward-scale (1-2)"
    else
      record "$work_dir" PASS "greenhouse: appropriate scale ($gh_agents agent(s))"
    fi
  fi

  # recipe-api and study-buddy should have multiple agents
  for project in recipe-api study-buddy; do
    if [ -d "$work_dir/$project/agents" ]; then
      local count
      count=$(find "$work_dir/$project/agents" -name "*.md" | wc -l)
      if [ "$count" -ge 3 ]; then
        record "$work_dir" PASS "$project: multi-agent setup ($count agents)"
      else
        record "$work_dir" WARN "$project: only $count agent(s) — expected 3+ for a team project"
      fi
    fi
  done

  # ── Forge registry ──────────────────────────────────────────────────

  if grep -q "recipe-api" "$clone_dir/AGENTS.md" 2>/dev/null; then
    record "$work_dir" PASS "Forge registry: recipe-api registered"
  else
    record "$work_dir" FAIL "Forge registry: recipe-api not registered"
  fi
  if grep -q "study-buddy" "$clone_dir/AGENTS.md" 2>/dev/null; then
    record "$work_dir" PASS "Forge registry: study-buddy registered"
  else
    record "$work_dir" FAIL "Forge registry: study-buddy not registered"
  fi
  if grep -q "greenhouse" "$clone_dir/AGENTS.md" 2>/dev/null; then
    record "$work_dir" PASS "Forge registry: greenhouse registered"
  else
    record "$work_dir" FAIL "Forge registry: greenhouse not registered"
  fi

  # Audit was written
  if [ -f "$clone_dir/audits/current.md" ]; then
    local audit_lines
    audit_lines=$(wc -l < "$clone_dir/audits/current.md")
    if [ "$audit_lines" -gt 10 ]; then
      record "$work_dir" PASS "Audit file has content ($audit_lines lines)"
    else
      record "$work_dir" WARN "Audit file is sparse ($audit_lines lines)"
    fi
  else
    record "$work_dir" WARN "No audit file written"
  fi

  # ── Phase 5b: Security scan on generated output ─────────────────────
  log "INFO" "Phase 5b: Security scan of generated agent files (strict mode)..."

  local sec_before=0
  sec_before=$(grep -c "SECURITY:" "$work_dir/.results" 2>/dev/null) || sec_before=0

  for project in recipe-api study-buddy greenhouse; do
    local dir="$work_dir/$project"
    # Scan all generated .md files except README.md (which is our own fixture)
    local gen_files
    gen_files=$(find "$dir" -name "*.md" ! -name "README.md" 2>/dev/null || true)
    for file in $gen_files; do
      local rel_path="${file#"$work_dir"/}"
      scan_file_security "$file" "$work_dir" "$rel_path" "strict"
    done
  done

  local sec_after=0
  sec_after=$(grep -c "SECURITY:" "$work_dir/.results" 2>/dev/null) || sec_after=0
  if [ "$sec_after" -eq "$sec_before" ]; then
    record "$work_dir" PASS "SECURITY: No dangerous patterns in generated agent files"
  fi
}

# ── Phase 7: Report ────────────────────────────────────────────────────

phase7_report() {
  local work_dir="$1"
  local tag="${2:-unknown}"

  read -r p f w <<< "$(count_results "$work_dir")"
  local total=$((p + f + w))
  local summary="$p passed, $f failed, $w warnings (of $total checks)"

  echo ""
  echo "════════════════════════════════════════════"
  echo "  FORGE SMOKE TEST: $summary"
  echo "════════════════════════════════════════════"
  echo ""

  if [ -f "$work_dir/.results" ]; then
    echo "── Results ──"
    cat "$work_dir/.results"
    echo ""
  fi

  if [ -f "$work_dir/eval_output.txt" ]; then
    echo "── Quality Evaluation ──"
    cat "$work_dir/eval_output.txt"
    echo ""
  fi

  # Write full report to file
  cat > "$work_dir/report.txt" << REPORT_EOF
# Forge Smoke Test Report

**Date:** $TIMESTAMP
**Ref:** $tag
**Work dir:** $work_dir

## Summary

$summary

## Results

$(cat "$work_dir/.results" 2>/dev/null || echo "No results recorded")
REPORT_EOF

  log "INFO" "Report written to $work_dir/report.txt"

  if [ "$f" -gt 0 ]; then
    exit 1
  fi
}

# ── Main ────────────────────────────────────────────────────────────────

cmd="${1:-}"

case "$cmd" in
  setup)
    ref="${2:-main}"
    work_dir=$(mktemp -d)
    echo "$ref" > "$work_dir/.ref"

    echo ""
    echo "Forge Smoke Test Setup — $TIMESTAMP"
    echo "Testing agent-forge at: $ref"
    echo "Work directory: $work_dir"
    echo ""

    phase1_clone "$work_dir" "$ref"
    phase2_leak_scan "$work_dir"
    phase2b_security_scan "$work_dir"
    phase3_create_projects "$work_dir"
    write_prompts "$work_dir"

    read -r p f w <<< "$(count_results "$work_dir")"
    echo ""
    log "INFO" "Setup complete: $p passed, $f failed, $w warnings"
    log "INFO" "WORK_DIR=$work_dir"
    log "INFO" "CLONE_DIR=$work_dir/agent-forge"
    log "INFO" "REF=$ref"
    log "INFO" ""
    log "INFO" "Next: steward spawns bootstrap agent with $work_dir/bootstrap_prompt.txt"
    ;;

  validate)
    work_dir="${2:?validate requires WORK_DIR argument}"
    [ -d "$work_dir" ] || { echo "ERROR: $work_dir does not exist"; exit 1; }
    phase5_validate "$work_dir"
    read -r p f w <<< "$(count_results "$work_dir")"
    log "INFO" "Validation complete: $p passed, $f failed, $w warnings"
    ;;

  report)
    work_dir="${2:?report requires WORK_DIR argument}"
    [ -d "$work_dir" ] || { echo "ERROR: $work_dir does not exist"; exit 1; }
    ref=$(cat "$work_dir/.ref" 2>/dev/null || echo "unknown")
    phase7_report "$work_dir" "$ref"
    ;;

  *)
    echo "Usage: forge-smoke-test.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  setup [ref]       Clone, leak scan, security scan, create projects."
    echo "                    ref: branch or tag (default: main)"
    echo "  validate <dir>    Structural + security checks on bootstrapped projects."
    echo "  report <dir>      Generate final report."
    echo ""
    echo "Steward workflow (pre-release):"
    echo "  1. bash forge-smoke-test.sh setup"
    echo "  2. If leaks found: spawn forge smith to fix, re-run setup"
    echo "  3. Spawn agent with \$WORK_DIR/bootstrap_prompt.txt"
    echo "  4. bash forge-smoke-test.sh validate \$WORK_DIR"
    echo "  5. Spawn agent with \$WORK_DIR/eval_prompt.txt"
    echo "  6. bash forge-smoke-test.sh report \$WORK_DIR"
    echo "  7. If passed: tag and push"
    exit 1
    ;;
esac
