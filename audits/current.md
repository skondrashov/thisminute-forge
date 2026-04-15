# Cross-Project Agent System Audit

**Date**: 2026-04-15
**Type**: Full ecosystem scan — rewritten from scratch against post-rebrand structure
**Previous audit**: 2026-04-05 (with 2026-04-11 forgemaster update note)
**Audit author**: assayer

---

## Executive Summary

10 days since the last audit date; 4 days since the forgemaster's 2026-04-11 update note. This audit is a ground-up rewrite as the previous assayer requested.

Major changes since 2026-04-05:

- **Commit freeze broken**: ops committed twice today (2026-04-15). dbt.thisminute.org also committed today. llms.thisminute.org/orchestration/tools committed on 2026-04-11. The ecosystem is no longer entirely frozen — though thisminute, balatro, sts2, and rts remain dormant.
- **Site rebrand complete**: `forge.thisminute.org/` repo is orphaned; `llms.thisminute.org/` is the live site. Rhizome renamed to orchestration; toolshed renamed to tools. Both renames were nuclear-style — no redirects, localStorage keys reset. A VM-side migration is queued in `ops/DEPLOY_QUEUE.md`.
- **arc-agi grew to 12 agents**: 7 pipeline agents added (pipeline_planner, pipeline_perception, pipeline_explorer, pipeline_analyst, pipeline_troubleshooter, pipeline_reviewer, pipeline_skeptic). AGENTS.md still documents only the original 5. Pipeline subsystem is active and well-structured — pipeline.py is 39,381 bytes updated 2026-04-11, pipeline_planner.md updated 2026-04-11. **Major doc debt.**
- **Forge self-drift resolved**: previous audit flagged untracked pattern files and out-of-sync agent-forge patterns. Commit 3f2a401 ("Commit forge backlog") resolved all of it. Forge is now clean — no untracked files, patterns match agent-forge template exactly.
- **rts grew to 4 agents**: `balancer.md` added since last audit's registry (which listed 3). AGENTS.md reflects this with steward, builder, skeptic, balancer.
- **dbt.thisminute.org active today**: Not a multi-agent project (single encrypted HTML file), but has two commits today (vault support, lock screen rework). Registry correctly lists it as "Static / 0 agents."
- **singularity-forge retired**: commit 29f34b7 ("Retire singularity-forge"). Premise was wrong. Removed from active tracking.

---

## Pattern Adoption Matrix

Columns reflect current project names. Orphaned/retired projects omitted.

| Pattern | thisminute | llms | orchestration | tools | ops | sts2 | balatro | rts | arc-agi | recipe-scaler |
|---------|-----------|------|--------------|-------|-----|------|---------|-----|---------|---------------|
| Standalone PROTOCOL.md | Yes | No | No | No | No | No | No | No | No | No |
| AGENTS.md (separate from CLAUDE.md) | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Slim AGENTS.md + ref/ docs | Yes (ref/ exists) | No (all inline) | No | No | No | No | No | No | No | No |
| Timestamp in startup | Yes | No (checkpoint) | No | No | No | No (checkpoint) | No | No | No | No |
| Shutdown reflection | Yes (orchestrator) | No | No | No | No | No | No | No | No | No |
| Keeper feedback loop | Yes (librarian) | No | No | Yes (librarian) | No | No | Partial (librarian defined, active) | No | Partial (librarian ran once, memory/librarian.md) | No |
| Role file ref doc routing | Yes (backend.md, frontend.md) | No | No | No | No | No | Yes (player → playbook/) | No | Yes (player → playbook/) | No |
| Forum voting minimums | Yes (2 votes min) | No | No | No | No | No | No | No | No | No |
| Agent role files in agents/ | Yes (11) | Yes (3) | Yes (1) | Yes (7) | Yes (2) | Yes (9, stale cycle 37) | Yes (5) | Yes (4) | Yes (12 — 5 core + 7 pipeline) | Yes (1) |
| Steward bootstrap | N/A | N/A | Yes | N/A | Yes (variant) | N/A | N/A | Yes | N/A | Yes |
| Challenge loop (skeptic+strategist) | Partial (both exist, no explicit sequencing) | Partial (skeptic only) | No | Yes | No | Yes (skeptic, stale) | No (skeptic removed) | Yes (skeptic) | Yes (skeptic defined + pipeline_skeptic) | No |
| Checkpoint-as-protocol | No | Yes (.claude/checkpoint.md, active — session 10) | No | No | No | Yes (.claude/iteration_checkpoint.md, frozen cycle 37) | No (old checkpoint at root, stale cycle 15) | No | Yes (.claude/checkpoint.md, cycle ~130+ sessions) | No |
| Playbook (shared knowledge) | No | No | No | No | No | No | Yes (9 files) | No | Yes (playbook.md + games/) | No |
| Librarian (proactive maintenance) | Partial (via keeper/feedback.md) | No | No | Yes (named librarian, active memory) | No | No | Yes (named librarian, active memory) | No | Yes (ran once, memory/librarian.md) | No |
| External validation | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | No (still needed) | N/A |

---

## Maturity Levels

| Project | Agents | Level | Change | Last Commit | Days Dormant |
|---------|--------|-------|--------|-------------|-------------|
| **thisminute** | 11 | **Full** | — | 2026-03-17 | 29 days |
| **tools** | 7 | **Full** | — | 2026-04-11 | 4 days |
| **llms.thisminute.org** | 4 | **Established** | — | 2026-04-11 | 4 days |
| **balatro** | 5 | **Established+** | — | 2026-03-16 | 30 days |
| **arc-agi** | 12 | **Established** | ↑ | N/A (untracked) | N/A |
| **sts2** | 9 | **Structured** | — | 2026-03-14 | 32 days |
| **rts** | 4 | **Minimal+** | — | 2026-03-17 | 29 days |
| **orchestration** | 1 | **Minimal** | — | 2026-04-11 | 4 days |
| **ops** | 2 | **Minimal+** | — | 2026-04-15 | 0 days (active today) |
| **dbt.thisminute.org** | 0 | **Static** | — | 2026-04-15 | 0 days (active today) |
| **recipe-scaler** | 1 | **New** | — | never | — |
| **agent-forge** | 4 | **Template** | — | (synced) | — |

**arc-agi upgraded from Structured+ → Established.** Rationale: the project now has 12 well-structured agent role files, an active checkpoint with extensive session history, a consolidated playbook, a documented librarian pass, and a working pipeline subsystem with dedicated role files. What it lacks for Established+: a proven end-to-end multi-agent feedback loop (analyst → playbook update → player improvement loop with documented evidence). Also, AGENTS.md only documents 5 of the 12 agents — the pipeline subsystem is invisible at the top level. Established is earned by structure and evidence; Established+ requires the self-improving loop to have run and documented its output.

---

## Per-Project Assessment

### thisminute — Full (dormant, 29 days)

**Status**: Unchanged. Agent system is the most mature in the ecosystem. PROTOCOL.md, FORUM.md, librarian, keeper feedback loop, ref/ docs, 11 well-structured role files. Last commit 2026-03-17 (v128: LLM geocoding).

**Concern**: 29 days without a commit on an active news aggregation platform is the longest gap in its history. The 106-feed + 13-API pipeline presumably still runs on the VM, but no development activity. Not actionable by the forge — surface to user.

**Action**: None for the agent system. Dormancy note in summary.

---

### llms.thisminute.org — Established (active last 4 days)

**Status**: Rebrand complete as of 2026-04-11. Six sections: home, models, context, orchestration, tools, forge. Checkpoint (session 10) documents the URL-flatten restructure and nuclear cleanup. Orchestrator memory is rich (user preferences, nuclear-mode policy, harness tie-in philosophy).

**What it has**: 3 agent role files, checkpoint-as-protocol, active memory (orchestrator.md), correct deploy queue discipline (routes through ops).

**What it lacks**: shutdown reflection, keeper feedback loop, ref/ docs per section, forum. These are reasonable gaps for a content/education site — the checkpoint does the coordination work. No PROTOCOL.md is expected.

**Upgrade path**: The `forge/` section has a pending rename ("user wants to rename forge too but idk what to" — still unresolved per checkpoint). This is a UX decision, not an agent system gap. Not an upgrade action.

**Action**: Low priority. Site is healthy and active. If the team grows past 3 roles, consider adding a FORUM.md or formalizing the skeptic's challenge scope.

---

### orchestration — Minimal (active last 4 days)

**Status**: Renamed from rhizome on 2026-04-11. Single steward. Memory file documents the rename and the harness-built-in pattern framing. 271 patterns. VM-side migration still queued in ops.

**What it has**: steward + memory, correct minimal setup for a pattern catalog.

**What it lacks**: nothing unreasonable for its scale and role. The steward pattern is the right fit here.

**One gap**: AGENTS.md documents "orchestration steward" but doesn't say how a new session should know the VM migration is still pending. The steward's memory documents it, but a new session without memory might run deploy.sh against stale VM paths. The deploy queue in ops is the right place — just confirm it's there.

**Action**: Verify ops DEPLOY_QUEUE.md has the orchestration+tools VM migration. Low priority.

---

### tools — Full (active last 4 days)

**Status**: Renamed from toolshed on 2026-04-11. 7-agent team stable. Memory files across all 7 agents (1,480 lines total — healthy distribution). Curator memory at 928 lines, stable for multiple audits. 16,247 entries in catalog as of cycle 10.

**What it has**: 7 role files, active memory per agent, librarian defined and active, challenge loop (skeptic), orchestrator coordinates.

**What it lacks**: standalone PROTOCOL.md (uses checkpoint-as-protocol), shutdown reflection, forum voting minimums. These are reasonable gaps — the team runs smoothly without them.

**Action**: None. This is a healthy Full-equivalent system without protocol formalism. The curator memory size is stable — no bloat concern.

---

### ops — Minimal+ (active today)

**Status**: Committed twice today (2026-04-15). Two agents: steward and security. AGENTS.md is the most detailed ops doc in the ecosystem — lists all 6 deployable projects with repo, local path, and VM path. Recent commits are deploy queue management for dbt.thisminute.org.

**What it has**: 2 role files, memory files (steward.md, project_toolshed.md), active deploy queue process.

**What it lacks**: a named security pattern is present but the nginx hardening work flagged in prior audits is still pending. No explicit checkpoint. Memory docs are project-state records, not agent learnings.

**Note**: The VM-side migration for orchestration/tools (renaming `/opt/rhizome` → `/opt/orchestration`, `/opt/toolshed` → `/opt/tools`, systemd unit renames, nginx location blocks) is queued but not yet run. This is a moderate ops risk — the live site at `forge.thisminute.org` may still be serving from old paths until the migration runs.

**Action**: Medium priority — run the VM migration. Not a forge concern directly, but surfaced here because it blocks the "rebrand complete" status from being true end-to-end.

---

### dbt.thisminute.org — Static (active today)

**Status**: Single-file encrypted DBT diary card app. No agents. User maintains directly. Committed twice today. Not a multi-agent project — correct registry status.

**Action**: None. Not in scope for agent system audit beyond confirming the registry entry is accurate.

---

### balatro — Established+ (dormant, 30 days)

**Status**: 5 agents (orchestrator, player, analyst, librarian, api-developer). Playbook intact (9 files). Memory directory has 11+ files. Last commit 2026-03-16.

**Unresolved from previous audit**: `iteration_checkpoint.md` at project root is dated 2026-03-17 cycle 15 and describes the old MCP/runner.py architecture. This file is still present and still misleads. Balatro has since restructured to Claude-as-player (cmd.py + TCP server + playbook), but the checkpoint predates that pivot and was never updated.

**Risk**: any session that opens `iteration_checkpoint.md` as its state anchor will think the project is running runner.py and mcp_server.py. This is the third audit to flag it.

**Action**: Delete or rewrite `iteration_checkpoint.md`. **Priority: Medium, escalating.** Three audits of "carried forward" is a signal. If balatro resumes without fixing this, a session will build on the wrong foundation.

---

### sts2 — Structured (dormant, 32 days)

**Status**: 9 agent role files all dated 2026-03-14. Checkpoint at cycle 37 (mid-combat blocker). No activity since 2026-03-15. This is the fourth consecutive audit flagging sts2 as frozen with an unresolved architecture-docs mismatch.

**What the mismatch is**: sts2 has a Python `bot_vm/` directory (untracked) that represents a newer VM-based architecture, but all role files describe the original Lua/mod architecture from cycle 37. The reconciliation has never happened.

**Decision point**: sts2 has been dormant for 32 days across 4 audit cycles. The forge should stop carrying "reconcile when active" as a perpetual action item. Two options:

1. **Mothball explicitly**: Add a `STATUS.md` at the project root: "Paused at cycle 37. bot_vm/ is an uncommitted experiment. Resume by reading cycle.md and the checkpoint." Let future sessions find this instead of stale role files.
2. **Retire**: If the user has no plans to return to sts2, remove it from active registry and archive.

**Action**: **Forgemaster should ask the user** — mothball or retire? **Priority: High** (it has been Low/N/A for three audits; it now needs a decision).

---

### rts — Minimal+ (dormant, 29 days)

**Status**: Registry now shows 4 agents (steward, builder, skeptic, balancer) — `balancer.md` was added since the last audit. Git status shows significant uncommitted work: AGENTS.md modified, SPEC.md added, steward.md modified, memory/MEMORY.md modified, 20+ source files modified/deleted.

**Risk**: This uncommitted work has been sitting for 29 days. `src/menu.rs` is deleted in the working tree but not committed — if anything goes wrong (hardware, accidental reset), that deletion and all the other working-tree changes are lost.

**Action**: When rts resumes, commit or consciously discard current work before building on it. **Priority: High on resume.** The forge cannot do this — it requires a developer decision. But flag it clearly.

---

### arc-agi — Established (untracked, most active project)

**Status**: 12 agents, no git tracking. The pipeline subsystem (7 agents) was added between 2026-04-08 and 2026-04-11 and represents the most active development in the ecosystem. `pipeline.py` (39,381 bytes) and `test_stage.py` (22,702 bytes) are the primary new files. `pipeline_planner.md` (updated 2026-04-11) is the most recently modified agent file in the ecosystem.

**Architecture state**: arc-agi now has three operational modes:
1. **Claude-as-player** (cmd.py + server.py + play.py): original mode, checkpoint from 2026-03-27 references it
2. **LLM-as-API** (agent.py + game_manager.py + knowledge.py): mid-tier API-calling mode, added ~2026-04-07
3. **Pipeline** (pipeline.py + 7 pipeline agents): newest mode, perception → planning → execution pipeline for structured game-solving

The checkpoint (2026-03-27) only documents Mode 1. Modes 2 and 3 are entirely undocumented at the AGENTS.md level.

**AGENTS.md gap**: documents 5 agents, 12 exist. The 7 pipeline agents have role files that are well-written (pipeline_planner.md is 4,732 bytes with clear purpose, method, and output format). They just don't appear in AGENTS.md's agent table or architecture section.

**What this means operationally**: any session that reads AGENTS.md to orient itself will not know the pipeline subsystem exists. They'll see the original Claude-as-player architecture and 5 agents. The pipeline work is invisible to top-level orientation.

**Action**: Update AGENTS.md to document all 12 agents and describe all three modes. Update the checkpoint to reflect the pipeline architecture. **Priority: High — next active session will be confused.** Medium effort (reading the pipeline files + writing a coherent AGENTS.md update).

**External validation**: arc-agi still lacks any comparison to published ARC-AGI-3 benchmarks. The checkpoint records best scores (ft09: 45.93, vc33: 35.71) but these are not contextualized against known approaches. Given the project generates scores and claims progress, external validation per `patterns/external-validation.md` is appropriate.

---

### recipe-scaler — New (never committed, 31+ days)

**Status**: Unchanged from every prior audit. One steward role file. No commits. Project idea, CRUCIBLE_CONTEXT.md still present.

**Action**: Retire unless the user has active plans. Keeping it in the registry adds noise without signal. **Priority: Low — but needs a decision.**

---

## Forge Self-Audit

### Pattern library: clean

All 11 pattern files are present and in sync with `agent-forge/patterns/`. The previous audit's "untracked patterns" issue was resolved in commit 3f2a401. No pattern drift detected.

### Forge working tree: clean

`git status` reports no uncommitted work. The forge itself is in the cleanest state seen across all audits.

### Registry accuracy

`agents.md` is up to date for most projects. One structural issue: the Role Lists section still uses old names:
- "rhizome (1 agent) — `forge.thisminute.org/rhizome`" should read "orchestration (1 agent) — `llms.thisminute.org/orchestration`"
- "toolshed (7 agents) — `forge.thisminute.org/toolshed`" should read "tools (7 agents) — `llms.thisminute.org/tools`"

The Projects table at the top has been updated, but the Role Lists section below still has the old names. Minor inconsistency but worth a keeper pass.

### agent-forge divergence: none

Pattern sets are identical. No divergence.

---

## Flagged Patterns

### 1. Pipeline subsystem as a pattern

arc-agi has built a structured multi-stage pipeline with dedicated specialist agents per stage (perception → planning → execution → review → troubleshooting). Each pipeline agent has:
- A single narrow responsibility with a clear output format
- Explicit "you receive X, you output Y" contract
- No loops or state — pure transform
- A reviewer and skeptic at the end

This is distinct from the Hub-and-Spoke pattern (coordinator + workers) and the Challenge Loop (proposal + skeptic). It's a linear assembly pipeline with typed handoffs.

**Evidence it works**: pipeline_planner.md is 4,732 bytes of tightly-scoped spec; pipeline.py is 39,381 bytes of implementation; both updated 2026-04-11 showing active development. The pipeline was designed to solve a specific failure mode: Claude-as-player was inconsistent because context got polluted across steps. The pipeline isolates each cognitive stage into a fresh context.

**Worth extracting**: Yes. Once arc-agi has run the pipeline end-to-end and measured score improvement, this should become a pattern. The handoff-document convention (each stage writes a structured handoff for the next) is the key extractable insight.

**Not ready yet**: wait for arc-agi to report pipeline scores before formalizing.

### 2. Harness-built-in roles as orchestration patterns

The orchestration steward added two patterns (2026-04-11) under a new framing: harness-native features (Claude Code's plan mode, Copilot's autopilot) are orchestration patterns that happen to ship inside the harness. The key insight — "orchestration doesn't require multiple LLM instances, it requires multiple context templates" — has wide implications for the pattern catalog.

This is already in the orchestration section at `/orchestration/`. Not a new forge pattern per se, but worth flagging as a conceptual framing that should inform future pattern writing. When new patterns are extracted from arc-agi's pipeline or from other projects, ask: is this about context templates or about agent instances?

### 3. Playbook as game memory (confirmed)

Both arc-agi and balatro use `playbook/` as persistent cross-session game knowledge — distinct from `memory/` (agent learnings) and distinct from documentation. The pattern is in `patterns/playbook.md`. Arc-agi has consolidated to a single `playbook.md` + per-game files under `playbook/games/`. Balatro has 9 files (README, strategy, mechanics, jokers, bosses, blinds, consumables, mistakes, run_log). Two independent implementations, same structure, same function. Pattern is confirmed and formalized — no further action.

---

## Top-Priority Actions for Next Cycle

Ordered by urgency × ROI.

### 1. Smith: arc-agi AGENTS.md + checkpoint update (High, Medium)

- Read all 7 pipeline agent files in `agents/`
- Read `pipeline.py` for the current pipeline architecture
- Rewrite AGENTS.md's agent table to include all 12 agents
- Add an "Architecture" section describing all three modes (Claude-as-player, LLM-as-API, Pipeline)
- Update `.claude/checkpoint.md` to reflect current pipeline state

This is the highest-value action: arc-agi is the most active project, and every new session is starting blind on 7 agents and the entire pipeline subsystem.

### 2. Forgemaster: sts2 retirement decision (High, Small)

- Ask user: "sts2 has been dormant for 32 days across 4 audit cycles. Should we retire it, formally mothball it, or schedule a reconciliation session?"
- If mothball: add `STATUS.md` at project root with state summary
- If retire: update `agents.md` registry, strike the entry

The "reconcile when active" action item has been carried forward 4 times. It is not going to happen organically.

### 3. Smith: balatro checkpoint deletion/rewrite (Medium, Small)

- Delete `iteration_checkpoint.md` at balatro project root (dated 2026-03-17, describes old MCP architecture)
- The current architecture lives in the playbook + memory files
- If a checkpoint is still useful, create a new one dated current reflecting the Claude-as-player / cmd.py architecture

This has been flagged 3 audits in a row. A new balatro session that reads this file will be misled.

### 4. Keeper: fix agents.md Role Lists section (Low, Small)

- Update "rhizome (1 agent) — `forge.thisminute.org/rhizome`" → "orchestration (1 agent) — `llms.thisminute.org/orchestration`"
- Update "toolshed (7 agents) — `forge.thisminute.org/toolshed`" → "tools (7 agents) — `llms.thisminute.org/tools`"

The Projects table is correct. The Role Lists section below still has the pre-rebrand names.

### 5. Ops: run VM migration (Medium, Medium)

The orchestration + tools rename (rhizome→orchestration, toolshed→tools) is complete in the repo but not yet on the VM. Until the migration runs, the live site may be serving from `/opt/rhizome` and `/opt/toolshed` paths. Check `ops/DEPLOY_QUEUE.md` for the migration block.

### 6. Forgemaster: recipe-scaler retirement decision (Low, Small)

- Ask user: "recipe-scaler has never committed and has been in the registry for 30+ days. Retire or kickstart?"
- If retire: remove from `agents.md`

### 7. Monitor: thisminute commit freeze (Ongoing)

- thisminute has not committed since 2026-03-17 (29 days). For an active news aggregation platform this is unusual — the VM presumably still runs, but no code changes. Not actionable by the forge but worth surfacing.

---

## Keeper Challenge Notes

1. **Forge is clean** — the previous assayer's "commit the forge backlog" action happened (commit 3f2a401). Acknowledging that the feedback loop works: audit flags something, keeper acts.

2. **arc-agi pipeline is a new architectural unit** that deserves its own section in AGENTS.md. The pipeline subsystem has as much content as some entire projects (7 role files, 39K lines of implementation). Treating it as an invisible extension of the 5-agent system is the single biggest information hazard in the ecosystem right now.

3. **The commit freeze finding from the last audit was partially accurate**: arc-agi has no git tracking (so never "breaks" the freeze), ops and dbt.thisminute.org are active, but the game projects (balatro, sts2, rts, thisminute) are genuinely dormant. These may just be in an off phase — not a crisis unless it extends further.

4. **Singularity-forge retirement is clean** — no loose ends. The memory/agents from that project are not carried forward anywhere. Correct outcome given the premise was wrong.

5. **External validation** is the one persistent arc-agi gap that three audits have flagged. The project has scores. It has a comparison method (official ARC-AGI-3 leaderboard). It hasn't run the comparison. This is low-effort and high-signal — worth a dedicated assayer note to the user.

---

*Audit author: assayer, 2026-04-15*
*Method: git log, working-tree inspection, file mtime analysis, AGENTS.md + checkpoint + memory reads. No project files were modified.*

---

## Shutdown Reflection

**Rating sources by usefulness:**

**Spawn prompt** (8/10): Excellent. Listed all the changes since the last audit explicitly (rebrand, renames, arc-agi growth, pattern matrix column name issue). This saved significant discovery work — I didn't have to guess what changed. The one gap: it said "arc-agi grew 5 → 12 agents" but didn't say AGENTS.md was not updated, so I had to verify that myself (it wasn't). Minor omission.

**Role file** (9/10): Clear task breakdown. The 8 things to check per project (CLAUDE.md, AGENTS.md, agents/, PROTOCOL.md, FORUM.md, memory/, ref/, checkpoint) is a complete checklist. The 8-level maturity scale is well-calibrated — I upgraded arc-agi to Established based on it and the criteria were unambiguous. Nothing was wrong. The only thing I'd add: a note that some projects don't track via git (arc-agi) and how to handle "days dormant" in that case.

**Previous audit** (7/10): Valuable for the "carried forward" history — balatro checkpoint, sts2 stasis, rts uncommitted work. The 2026-04-11 update note was crucial (told me what changed). However, the bulk of the audit was stale by the time I read it (pre-rebrand column names, singularity-forge still active, arc-agi at 5 agents). I had to mentally discard most of the matrix and rebuild from scratch, which was the right call. The forgemaster's note to "rewrite from scratch against the new structure" was exactly right.

**Patterns library** (7/10): Having the 11 pattern files available was useful as a checklist for the adoption matrix. However, I mostly referenced the pattern names rather than reading the files in depth — I already understood the patterns from prior context. The library is stable and complete. No missing patterns, no obsolete ones. Minor: `first-run.md` still hasn't been field-tested against a fresh forge instance (flagged in the previous audit, still true).

**Registry (agents.md)** (8/10): The Projects table was accurate and up-to-date post-rebrand. The Role Lists section below the table had stale names (flagged as keeper action item #4). The registry correctly marked singularity-forge as Retired and dbt as Static. Good signal-to-noise ratio overall.

**What was missing**: A note about arc-agi's git tracking status. The spawn prompt, registry, and previous audit all discuss arc-agi extensively but none explicitly says "this project has no git history at all." I had to infer it from the empty `git log` output. This should be in the registry entry.

**What was noise**: The previous audit's detailed "changes since last audit" section. Everything in that section was superseded by the 2026-04-11 update note and my fresh scan. It added cognitive load without adding value. Future assayers: read the previous audit's executive summary and keeper notes, skip the detailed change log if the update note says "rewrite from scratch."
