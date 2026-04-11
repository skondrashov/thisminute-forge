# Cross-Project Agent System Audit

**Date**: 2026-04-05
**Type**: Full ecosystem scan (11 projects + 1 template)
**Previous audit**: 2026-03-26 (never committed — still uncommitted in forge working tree)

## Executive Summary

10 days since last audit. Cycles 61-90 in the forge log are labeled dormant monitoring cycles, and that matches reality: **no project has committed work since 2026-03-19** (ops) — an 18-day commit freeze across the ecosystem. But "no commits" does not mean "no activity":

- **arc-agi pivoted architecture**: added `agent.py` (761 lines, Anthropic Messages API direct) + `game_manager.py` (in-process arc-agi SDK, no TCP server). The "Claude-as-player" + TCP + cmd.py architecture described in AGENTS.md is now partially obsolete. player.md was modified 2026-04-02 — **the most recent activity in the entire ecosystem.**
- **arc-agi stale files resolved** (per last audit's request): `builder.md` and `play-operator.md` deleted; librarian agent removed old dead code; memory/librarian.md documents the cleanup.
- **arc-agi playbook consolidated**: 5 separate files (strategy.md, action-effects.md, game-catalog.md, mechanics.md, README.md) → one `playbook/playbook.md` (172 lines), distilled from 130+ sessions across 25 games. Added `playbook/games/wa30.md` as first per-game file.
- **sts2 architecture docs still frozen** at cycle 37 (2026-03-14). No activity in working tree since March 15. The reconciliation flagged in the previous audit has not happened.
- **Forge patterns out of sync with template**: `agent-forge/patterns/` has two new patterns (`librarian.md`, `playbook.md`) created 2026-03-27 that are absent from `thisminute-forge/patterns/`. This is a reverse drift — the upstream template received patterns that should flow back into this forge's active library.
- **Three forge pattern files** (`checkpoint.md`, `external-validation.md`, `first-run.md`) still untracked after 10 days — previous audit flagged them, they never got committed. The previous audit itself is also still uncommitted.
- **singularity-forge still dormant** since 2026-03-22 (last memory update). No new projects in `~/projects/singularity/`. Still 43 projects, unchanged.

The "uncommitted work everywhere" finding from the last audit now extends to "uncommitted work everywhere AND nobody committed for nearly three weeks." The ecosystem is in a deep quiet phase.

---

## Pattern Adoption Matrix

| Pattern | thisminute | toolshed | forge.thisminute.org | rhizome | ops | sts2 | balatro | rts | singularity-forge | recipe-scaler | arc-agi |
|---------|-----------|----------|---------------------|---------|-----|------|---------|-----|-------------------|---------------|---------|
| Standalone PROTOCOL.md | Yes | Yes | No | No | No | No | No | No | No | No | No |
| AGENTS.md (separate from CLAUDE.md) | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Slim AGENTS.md + ref/ docs | Yes | No (~108 lines) | No | No | No | No | No | No | No | No | Partial (playbook/ serves as ref) |
| Timestamp in startup | Yes | Yes | N/A | N/A | N/A | No (checkpoint) | No | N/A | N/A | N/A | No (checkpoint) |
| Shutdown reflection | Yes (orchestrator) | Partial | No | No | No | No | No | No | No | No | No |
| Keeper feedback loop | Yes (librarian) | Yes (librarian) | No | No | No | No | Partial (librarian defined) | No | No | No | Partial (librarian defined + ran once) |
| Role file ref doc routing | Yes | No | No | No | No | No | Yes (player → playbook/) | No | No | No | Yes (player → playbook/) |
| Forum voting minimums | Yes (2 votes) | Yes (2 votes) | No | No | No | No | No | No | No | No | No |
| Agent role files in agents/ | Yes (11) | Yes (7) | Yes (3) | Yes (1) | Yes (2) | Yes (9, stale) | Yes (5) | Yes (3) | Yes (4) | Yes (1) | Yes (5) |
| Steward bootstrap | N/A | N/A | N/A | Yes | Yes (variant) | N/A | N/A | Yes | N/A | Yes | N/A |
| Challenge loop (skeptic+strategist) | Partial (both exist, no explicit sequencing) | Yes | Yes (skeptic only) | No | No | Yes (skeptic, stale) | No (skeptic removed) | Yes (skeptic) | Yes (skeptic, no strategist) | No | Yes (skeptic defined, never activated) |
| Checkpoint-as-protocol | No | No | Yes (.claude/checkpoint.md) | No | No | Yes (.claude/iteration_checkpoint.md, frozen) | Yes (iteration_checkpoint.md, stale at cycle 15) | No | No | No | Yes (.claude/checkpoint.md, cycle ~6) |
| Playbook (shared knowledge) | No | No | No | No | No | No | Yes | No | No | No | Yes |
| Librarian (proactive maintenance) | Partial (via keeper/feedback.md) | Yes (named librarian) | No | No | No | No | Yes | No | No | No | Yes (ran once, `memory/librarian.md`) |
| External validation | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | Yes (honest-assessment.md) | N/A | No (still needed) |

*Note on new rows: `Playbook` and `Librarian` rows added this audit. Pattern files for these exist in `agent-forge/patterns/` but not yet in `thisminute-forge/patterns/` — see Flagged Patterns and Top-Priority Actions.*

---

## Maturity Levels

| Project | Agents | Level | Change | Notes |
|---------|--------|-------|--------|-------|
| **thisminute** | 11 | **Full** | — | Dormant since v128 (2026-03-17, 19 days). Agent system healthy. |
| **toolshed** | 7 | **Full** | — | Dormant. Last activity 2026-03-21. Curator memory still 928 lines (stable 3 audits). |
| **forge.thisminute.org** | 3 | **Established** | — | Dormant since 2026-03-22. Checkpoint unchanged. Orchestrator memory still a stub (2026-03-14). |
| **balatro** | 5 | **Established+** | — | Dormant since 2026-03-25. Restructuring settled — all 5 agents, playbook, memory intact. |
| **arc-agi** | 5 | **Structured+** | ↑ | Architecture pivot in progress. Stale files cleaned. Playbook consolidated. Active until 2026-04-02. |
| **sts2** | 9 | **Structured** | — | Still frozen. Architecture-docs mismatch unresolved. Last touch 2026-03-15. |
| **singularity-forge** | 4 | **Structured** | — | Dormant since 2026-03-22. Memory files now present (4 files, 193 lines). |
| **rhizome** | 1 | **Minimal** | — | Dormant. Last activity 2026-03-15. Steward memory stable. |
| **ops** | 2 | **Minimal+** | — | Dormant. Last commit 2026-03-19. Security review doc present. |
| **rts** | 3 | **Minimal+** | — | Dormant. Last code change 2026-03-25 (net.rs). Heavy uncommitted work carried forward 2 audits. |
| **recipe-scaler** | 1 | **New** | — | Never committed. Unchanged since 2026-03-15. |

**arc-agi upgraded from Structured → Structured+** on the strength of: cleaned agent files (matches AGENTS.md 5 agents), librarian ran and documented its cleanup in memory, playbook consolidation, 130+ player sessions recorded, active checkpoint. Still missing: proven multi-agent feedback loop (analyst + skeptic never ran, per memory evidence).

---

## Changes Since Last Audit (2026-03-26)

### Committed work

**None.** Last commit on any tracked project was 2026-03-19 (ops: "Log dbt deploys"). This is the longest commit gap in the ecosystem's audit history.

### Uncommitted activity by project

**arc-agi — active until 2026-04-02:**
- `agents/builder.md` and `agents/play-operator.md` deleted (per last audit's action item)
- `memory/librarian.md` added (2026-03-26) — documents dead-code cleanup; removed `main.py`, `quickstart.py`, `engine.py`, `solver.py`, `bot/reason.py`
- `playbook/` restructured: old multi-file playbook replaced with single `playbook.md` (172 lines) distilled from 130+ sessions + `playbook/games/wa30.md`
- New scripts: `agent.py` (761 lines, phase-based Anthropic Messages API agent), `game_manager.py` (729 lines, in-process SDK wrapper — replaces server.py + cmd.py combination), `knowledge.py` (188 lines, system prompt builder), `submit.py` (169 lines, scorecard submission)
- `.claude/checkpoint.md` dated 2026-03-27 with session "~130+ player runs + 7 analyst runs" — records scores for 13 games (best: ft09 45.93, vc33 35.71)
- `agents/player.md` modified 2026-04-02 — now references `flowchart-output/` directory (PLANNING/OBSERVATION/EXECUTION/EXPLORATION templates), contradicts old cmd.py-centric workflow

**balatro — dormant since 2026-03-25:**
- All Cycle 84 restructuring uncommitted work still present (deletions of 8 old agent files, additions of player/librarian/api-developer, playbook/, cmd.py, etc.)
- `iteration_checkpoint.md` in project root still describes cycle 15 (2026-03-17) with OLD architecture (runner.py, mcp_server.py, Sonnet+Opus API calls) — contradicts the new structure
- 12 memory files stable (last one edited 2026-03-24)
- No new files since last audit

**rts — dormant since 2026-03-25:**
- Still has uncommitted rename `AGENTS.md → SPEC.md`, plus creation of new `AGENTS.md`
- Untracked: new `DESIGN.md`, `LORE.md`, `LORE copy.md`, new agent files (builder.md, skeptic.md), memory files, asset directory, 7 new source files (bubble.rs, galaxy.rs, hunger_mat.rs, polyhedra.rs, proof_edge.rs, space_bg.rs)
- No changes since last audit — work has been frozen for 10 days

**forge.thisminute.org/toolshed/rhizome — dormant since 2026-03-22:**
- Work identical to last audit — no progress
- Last file touch in toolshed was 2026-03-21 (FORUM.md, curator memory)

**sts2 — frozen since 2026-03-15:**
- Working tree state identical to last audit
- bot_vm/ (Python) still present as untracked
- All 9 agent role files still dated 2026-03-14
- Checkpoint still at cycle 37

**singularity-forge — dormant since 2026-03-22:**
- 4 memory files (assayer, forgemaster, skeptic, smith) present as untracked directory — same state as last audit
- No audit updates since 2026-03-17
- Still 43 projects in `~/projects/singularity/`

**ops, thisminute, rhizome, recipe-scaler — no activity.**

### Forge actions this cycle (provisional — this audit has not yet been committed)

- **Confirmed**: arc-agi stale-files issue resolved independently by a librarian session (2026-03-26)
- **Discovered**: arc-agi mid-pivot to LLM-as-API architecture (agent.py + game_manager.py)
- **Discovered**: agent-forge template has `librarian.md` and `playbook.md` patterns (created 2026-03-27) that never propagated back to thisminute-forge
- **Flagged**: ecosystem-wide 18-day commit freeze

---

## Per-Project Assessment & Upgrade Plans

### arc-agi — Structured+ (monitor pivot)

**Status change**: ↑ from Structured. Earned the upgrade by:
- Cleaning the stale agent files (direct response to last audit)
- Running a librarian session and documenting its work in `memory/librarian.md`
- Consolidating the playbook into a single curated document
- Maintaining an active checkpoint across 130+ sessions

**Unresolved: architecture ambiguity.** The project now has two co-existing architectures:

1. **Architecture A (documented in AGENTS.md, described in player.md's command block)**: `play.py` supervisor → Claude Code CLI sessions → `cmd.py` + `server.py` (TCP).
2. **Architecture B (newer, more recently modified)**: `agent.py` (Anthropic Messages API direct) + `game_manager.py` (in-process SDK wrapper) + `knowledge.py` (prompt builder) + flowchart-output/ templates.

Evidence Architecture B is the active path:
- `agent.py` last modified 2026-03-31, `knowledge.py` 2026-03-30 — newer than any TCP-stack file (`server.py`, `play.py` last touched 2026-03-25)
- `agents/player.md` (modified 2026-04-02) references the flowchart-output directory and phase-based PLANNING/OBSERVATION/EXECUTION/EXPLORATION loops that correspond to `agent.py`'s phase calls
- But `player.md`'s own command block still shows `cmd.py` usage

The checkpoint (2026-03-27) predates this pivot — it references server ports 19401-19410, tier_check.py, .prev_grid.npy, all TCP-stack artifacts.

**Action**: On next active cycle, pick a canonical architecture. Options:
- **(A)** Keep Claude-as-player via cmd.py; delete agent.py, game_manager.py, knowledge.py, submit.py as an abandoned experiment.
- **(B)** Commit to LLM-as-API via agent.py; update AGENTS.md, deprecate play.py + cmd.py + server.py, update player.md to describe flowchart templates instead of cmd.py commands.
- **(C)** Explicitly document both as "two modes" — one for exploratory play (cmd.py), one for batch scoring runs (agent.py).

**Priority: High when active.** Current docs actively mislead sessions.

**Other notes**:
- `memory/librarian.md` is the first real proof that the librarian pattern works in a project. Worth citing when writing the librarian pattern for thisminute-forge.
- `analyst.md` and `skeptic.md` still never activated — the checkpoint mentions "7 analyst runs" but no analyst memory file exists. If the analyst ran, its output went into playbook consolidation, which is the right outcome — but the role file should explicitly say "analyst work product = playbook updates."
- External validation still needed — checkpoint reports scores but makes no attempt to compare against other published ARC-AGI-3 results or the anonymous leaderboard.

### sts2 — Structured (unchanged, regression risk)

The reconciliation flagged in the previous audit has not happened. 10 days later, the working tree is byte-for-byte the same. This is the third consecutive audit that has flagged sts2's architecture-docs mismatch as "High priority when active, N/A while dormant."

**New consideration**: if sts2 stays dormant another cycle or two, the best action may be to formally deprecate it rather than keep queuing reconciliation work. The project has been architecturally stuck since mid-March. A fourth "carried forward" action item is a signal the work isn't going to happen organically.

**Action**: No change this cycle — still dormant. But on the next dormant audit, consider asking whether sts2 should be retired or explicitly mothballed.

### balatro — Established+ (stable, checkpoint drift)

Restructuring is stable. All 5 agents present with role files. Playbook intact (793 lines across 9 files). Memory directory has 12 files.

**Issue**: `iteration_checkpoint.md` at project root is dated 2026-03-17 cycle 15 and describes the OLD architecture (runner.py, mcp_server.py, Sonnet+Opus multi-tier API calls). The restructuring deleted that entire code path. The checkpoint actively misleads.

**Action**: Delete or rewrite `iteration_checkpoint.md` to reflect the Claude-as-player architecture. **Priority: Medium** (low impact while dormant, but first session to resume will read this file and get confused).

### forge.thisminute.org — Established (carried forward)

Checkpoint unchanged, orchestrator memory still a stub. Dormant. Same action as last audit — **Medium priority, carried**.

### toolshed — Full (carried, stable)

Curator memory at 928 lines is stable for 3 audits. Treat as natural size. **No action.**

### rhizome — Minimal (stable)

Dormant, correct size. **No action.**

### thisminute — Full (stable, long dormancy)

19 days without activity. Agent system healthy. **No action.**

### ops — Minimal+ (stable)

Last commit 2026-03-19. Security nginx hardening still pending from prior audits. **Low priority, carried.**

### rts — Minimal+ (dormant heavy-uncommitted)

No change since last audit. 7 new source files, renamed AGENTS.md → SPEC.md, new agent files, memory files — all still uncommitted for 10+ days. This is a growing risk of state loss if anything corrupts the working tree.

**Action**: When rts resumes, the steward should either commit current work or consciously abandon it. **Priority: High on resume, N/A while dormant.**

### singularity-forge — Structured (stuck)

Memory files present (4 files, 193 lines total), created 2026-03-22 per file dates. But:
- No audit updates since 2026-03-17
- No new projects since 2026-03-17 (still 43 projects in the directory)
- The project was supposed to replace bellows as an active chained-forge workflow

The "Structured" rating understates the concern — singularity-forge has not meaningfully run in nearly three weeks. If it's meant to be an active agent system scanning the toolshed for gaps, it isn't.

**Action**: Flag for user attention. Either it should be running a cycle or the scheduled monitoring that would trigger its cycles has stopped. **Priority: Medium — ask the user whether singularity-forge is expected to be active.**

### recipe-scaler — New (still dormant)

Never committed. Unchanged. **No action.** Consider retiring if still dormant at next audit.

---

## Forge Self-Audit

The thisminute-forge itself has drift:

1. **Three pattern files still untracked** after 10 days: `patterns/checkpoint.md`, `patterns/external-validation.md`, `patterns/first-run.md`. Previous audit flagged them for evaluation and integration; keeper never ran. All three are well-written and ready — should be committed.

2. **Two patterns exist in template but not forge**: `agent-forge/patterns/librarian.md` and `agent-forge/patterns/playbook.md` (both created 2026-03-27). These are the codification of the convergent patterns from balatro and arc-agi that the previous audit flagged as "worth monitoring." They should be copied from the template into `thisminute-forge/patterns/` and adapted with adoption-status tables reflecting current ecosystem usage.

3. **Previous audit itself uncommitted**: `audits/current.md` and its associated `agents.md`/`agents/assayer.md` changes from 2026-03-26 are still staged but uncommitted. This audit will overwrite `current.md` and those changes will need to be committed together.

4. **No first-run wizard invocation yet**: `first-run.md` exists but was never tested against a fresh forge instance. Consider a smoke test against agent-forge before declaring the pattern stable.

**Action**: Full keeper sweep needed — commit the previous audit's uncommitted work + this audit + the three pattern files + copy the two new patterns from the template. **Priority: High.**

---

## Flagged Patterns

### Formalized in template but not yet in forge: Playbook + Librarian

Both patterns were written into `agent-forge/patterns/` on 2026-03-27, presumably during a keeper or smith session that was never committed to thisminute-forge. Evidence they work:

- **balatro**: has `playbook/` (9 files, 793 lines), dedicated `librarian` role, stable for 2 audits
- **arc-agi**: has `playbook/` (consolidated 172-line doc + per-game files), dedicated `librarian` role, `memory/librarian.md` documents a real cleanup session

**Action**: Copy `agent-forge/patterns/librarian.md` and `agent-forge/patterns/playbook.md` into `thisminute-forge/patterns/`, fill in the adoption-status tables, and update the pattern matrix above with proper rows. Already partially done in this audit (rows added, pattern files still to be copied).

### Emerging but unresolved: Claude-as-Player vs LLM-as-API tension

The previous audit flagged "Claude-as-player" as a convergent architecture across arc-agi and balatro. Ten days later, arc-agi has partially abandoned it. The `agent.py` + `game_manager.py` path is a return to the classic "Python calls Anthropic API" pattern — specifically because:

- **Cost control**: 130+ sessions via Claude Code are expensive; API calls with prompt caching are cheaper
- **Reproducibility**: batch runs against the scorecard API need deterministic invocation, not CLI sessions
- **Structured output**: phase-based flowchart templates work better when the harness enforces them

This suggests the pattern isn't "Claude-as-player" in the universal sense — it's "Claude-as-player for exploration + LLM-as-API for execution." balatro and sts2 may eventually feel the same pressure.

**Action**: Do not extract "Claude-as-player" as a formal pattern yet. The story is more nuanced. Revisit once arc-agi picks a canonical architecture.

### Confirmed working: Librarian as proactive-maintenance role

`arc-agi/memory/librarian.md` is the first field evidence of a librarian doing real work: it lists files deleted, files kept with justification, and doc corrections. This is the behavior the pattern describes, with tangible output. Cite this file when finalizing the librarian pattern.

### Risk: Ecosystem-wide commit freeze

18 days since any commit anywhere. This is not "dormant" in the healthy sense — at least three projects (balatro, rts, arc-agi) have substantial uncommitted work. If a workstation incident happened today, that work would be lost. The forge cannot prevent this but should surface it clearly in audits.

**Action**: Add "days since last commit" to the per-project table in future audits as an early warning.

---

## Keeper Challenge Notes

1. **The previous audit never committed.** Someone (a dormant session, an interrupted keeper) left `audits/current.md` and its sibling changes in the working tree. 10 days passed. This audit inherits that state. When committing this audit, also commit the three pattern files and the previous audit's agent registry changes in the same keeper session.

2. **Agent-forge and thisminute-forge have diverged.** The template picked up `librarian.md` and `playbook.md` — the reverse of the usual flow (template → active forge). Someone was working on agent-forge directly on 2026-03-27. The thisminute-forge pattern library is now *behind* the template. This needs to be reconciled, and the reverse-direction sync protocol should be documented.

3. **arc-agi deserves a rating ceiling conversation.** It's been upgraded to Structured+ but could plausibly reach Established on the next active cycle if the architecture pivot is finished cleanly and the analyst/librarian feedback loop runs end-to-end. The project has the most energy in the ecosystem right now and the most tangible proof that patterns work.

4. **singularity-forge is a silent failure.** A forge that doesn't scan the toolshed or create projects is not doing its job. Previous audits counted it as Structured based on file presence; this audit should be explicit that the rating is purely structural — the operational status is "not running."

5. **sts2 needs a deprecation conversation.** Three consecutive audits flagging the same "reconcile when active" action, with no activity. At some point the honest call is to retire it or archive the Python bot_vm/ work as a reference and rebuild from scratch. Not this audit, but flag it.

---

## Top-Priority Actions for Next Cycle

Ordered by urgency. Smith and keeper should work through these in sequence.

### 1. Keeper: commit the forge backlog (High, Small)

- Commit the previous audit's `audits/current.md` + `agents.md` + `agents/assayer.md` changes
- Commit the three untracked pattern files (`checkpoint.md`, `external-validation.md`, `first-run.md`)
- Commit this audit (which overwrites `current.md`)
- Single coherent keeper commit or a small series

### 2. Keeper: sync patterns from agent-forge template (High, Small)

- Copy `agent-forge/patterns/librarian.md` → `thisminute-forge/patterns/librarian.md`
- Copy `agent-forge/patterns/playbook.md` → `thisminute-forge/patterns/playbook.md`
- Fill in adoption-status tables with current ecosystem data:
  - Playbook: balatro (Yes), arc-agi (Yes, consolidated into one file)
  - Librarian: toolshed (Yes, named "librarian"), balatro (Yes), arc-agi (Yes, ran once — cite `memory/librarian.md`)
- Include a brief note about the reverse-sync (template → forge)

### 3. Smith: arc-agi architecture reconciliation (High, Medium) — only if arc-agi resumes

- Read `agent.py`, `game_manager.py`, `player.md`, `.claude/checkpoint.md` in full
- Determine whether the project is committing to Architecture B (LLM-as-API) or retaining Architecture A (Claude-as-player)
- Update AGENTS.md and player.md to match the canonical architecture
- Delete dead code from whichever path is abandoned
- Update the checkpoint if it's still referencing the old stack

### 4. Smith: balatro checkpoint cleanup (Medium, Small)

- Delete or rewrite `iteration_checkpoint.md` at balatro root — it describes cycle 15's old MCP architecture and actively misleads sessions about the project state
- The checkpoint now lives implicitly in the playbook + memory files; decide whether a new checkpoint file is needed at all

### 5. Forgemaster: ask user about singularity-forge (Medium, Small)

- It has been dormant for 14+ days with no new projects
- The intended design is an active chained-forge workflow scanning the toolshed
- Either it's supposed to be running and isn't, or the plan has changed — user clarification needed

### 6. Forgemaster + keeper: retire-or-activate decisions (Low, batch)

- recipe-scaler: still "New" with no commits 21 days after registration — retire or kickstart
- sts2: third audit in a row with no progress — retire, mothball, or make reconciliation a top priority
- rts: not retire, but the uncommitted state should be committed or consciously discarded on resume

### 7. Monitoring: ecosystem commit freeze (ongoing)

- No commits in 18 days across the entire ecosystem
- Not actionable by the forge directly, but flag in user summary
- Add "days since last commit" to future audit tables

---

*Audit author: assayer, 2026-04-05*
*Method: direct working-tree inspection + git log + file mtime analysis. No project files were modified.*

---

## Update 2026-04-11 — significant ecosystem changes since this audit

This audit is now stale on several "current state" claims. See `agents.md` for the canonical registry. Notable changes:

- **Major site rebrand + reorganization**: forge.thisminute.org content moved to `~/projects/llms.thisminute.org/` (directory name predates rebrand). The site is now organized around the agent anatomy diagram itself: home (anatomy flowchart) → /models/ → /context/ → /orchestration/ (was rhizome) → /tools/ (was toolshed) → /forge/. New visual identity (Fredoka, watermelon-pink + mint pastel, casual essayist voice). Two new content sections: /models/ (~60 model catalog) and /context/ (statelessness explainer with embedded token demo). crucible/ deleted, /llms/llm/ deleted (absorbed into /context/). Old `~/projects/forge.thisminute.org/` repo orphaned at the 2026-04-09 commit.
- **Renames**: rhizome → orchestration, toolshed → tools. Same content, same agents, new paths. Nuclear cleanup: localStorage keys reset, API endpoints renamed, deploy script paths updated.
- **dbt.thisminute.org added**: encrypted static DBT diary card app (single-file, no agents, user maintains directly). Recent activity: onboarding wizard, calendar view, accessibility tweaks.
- **arc-agi grew from 5 to 12 agents**: added 7 pipeline agents (planner, perception, explorer, analyst, troubleshooter, reviewer, skeptic). Architecture evolved beyond original Claude-as-player: now has agent.py + game_manager.py for batch runs alongside cmd.py for exploration. AGENTS.md still documents only the original 5 — pipeline agents undocumented at top level. Project remains untracked by git. ~130+ player runs across 13 games, best score 45.93 on ft09.
- **Old forge.thisminute.org repo**: orphaned but not deleted. Frozen at the 2026-04-09 reorganization commit.
- **llms.thisminute.org has substantial uncommitted work**: this is intentional — the rebrand is queued at `~/projects/ops/DEPLOY_QUEUE.md` and waiting for ops steward to run a one-time VM migration before committing.

**For next assayer cycle**: rewrite from scratch against the new structure. The pattern adoption matrix needs new column names (orchestration/tools), and arc-agi's stale top-level docs are worth flagging in the per-project assessment.

*Update author: forgemaster, 2026-04-11*
