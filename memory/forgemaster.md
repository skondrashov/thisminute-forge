# Forgemaster Operational Memory

**Last updated:** 2026-03-15 (after cycle 13)

## Ecosystem State

8 projects, 3 coordination models, 43 agents total. All CLAUDE.md files harmonized to "See AGENTS.md." All projects registered and audited. 6 field-tested patterns in rhizome.

**Stable projects (low-touch):** rhizome, ops, mainmenu, agent-forge
**Active development:** thisminute, sts2, balatro, forge.thisminute.org

## Lessons from 13 Cycles

### Forum management
- Forums balloon 10x in a single active session (thisminute: 51→1,008 lines). Librarian must be spawned frequently during heavy sessions, not just at cleanup time.
- mainmenu hit 904 lines before getting a librarian role. Adding the librarian + archiving immediately dropped it to 60 and it stabilized.
- Threshold for concern: >500 lines. Threshold for action: >800 lines.

### When to intervene vs. let projects self-correct
- Forum cleanup in a project with an active librarian: let the project handle it. Only intervene if it crosses 800+ with no librarian.
- Memory file creation: organic adoption works. 3 new memory files appeared across projects without smith intervention. Don't force it.
- Pattern retirement (messages/): needed smith intervention because it was referenced in PROTOCOL.md across multiple projects. Cross-cutting changes require forge-level coordination.

### Pattern extraction timing
- Extract after 2+ projects validate a pattern, not after 1.
- sts2's checkpoint pattern is proven (37 cycles) but held pending balatro validation. This was the right call — one instance is anecdote, two is pattern.
- The section-index pattern (for 4100+ line files) is also sts2-only. Same rule applies.

### Smith conflicts
- Smith should not touch projects during active sessions. Check git status for modified/untracked files before upgrading.
- When in doubt, flag the change and defer to next idle cycle.

### Audit cadence
- 3+ consecutive idle cycles means ecosystem is stable. Skip detailed scans and do quick-check only.
- Full scans are valuable after known active sessions or when onboarding new projects.

## agent-forge Release Process

Smoke test (`tests/forge-smoke-test.sh`) must pass before tagging a new agent-forge release. Three subcommands — `setup`, `validate`, `report` — with LLM phases (bootstrap + eval) run as steward subagents between them (no extra API cost). Tests 3 synthetic projects: Go API (multi-agent), React+Python app (multi-stack), solo hobby project (steward). Ops steward owns the workflow.

## Deferred Work

1. **Checkpoint + section-index patterns** — Extract to forge_validated.json once balatro has 10+ cycles. Currently at cycle 0.
2. **rhizome .claude/ gitignore** — Minor, runtime lock files only.
3. **ops resilience** — Health check script added (2026-03-15). Monitor effectiveness.

## Registry Corrections Made

- sts2 agent count: was 5, corrected to 9 (cycle 5)
- agent-forge CLAUDE.md: removed thisminute-specific deploy queue reference (cycle 5)
- messages/ pattern: retired ecosystem-wide, zero remaining references (cycle 12)
