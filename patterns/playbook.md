# Pattern: Playbook (Shared Knowledge Base)

## Problem

Projects with experiential domains — where knowledge comes from doing, not from specs — accumulate learnings through trial and error. Game mechanics, deployment procedures, research protocols, trading strategies: these are discovered iteratively and refined over time.

Existing coordination patterns don't serve this well:
- **Memory files** are per-agent. Knowledge is scattered across roles, and agents re-discover what other agents already know.
- **Forum** is for deliberation and voting, not knowledge storage. Resolved findings get buried under new threads.
- **Ref docs** are static technical references. They describe architecture, not strategy.
- **Checkpoint** tracks session state (ephemeral). It's overwritten each cycle — not a place for durable knowledge.

Without a shared knowledge base, hard-won learnings get lost between sessions, agents repeat mistakes, and the project's accumulated experience has no home.

## Solution

A `playbook/` directory containing curated, verified knowledge that all agents share. The playbook is:

- **Experiential** — built from verified observation, not theory or specs
- **Shared** — all agents can read it; no per-role routing needed
- **Living** — updated after each cycle based on new evidence
- **Curated** — maintained by a dedicated role (librarian or the orchestrator), not append-only

| | Playbook | Memory | Ref Docs | Forum |
|---|---|---|---|---|
| Scope | Shared domain knowledge | Per-agent learnings | Static technical reference | Deliberation + voting |
| Updates | After verified discovery | After each session | When architecture changes | Continuously |
| Owner | Librarian or orchestrator | Each agent | Relevant domain owner | All agents |
| Durability | Persists, actively curated | Persists, per-agent maintained | Persists, rarely updated | Accumulates, needs cleanup |

The key distinction: playbook entries are **verified before recording**. An agent observes something, tests it, and only then records it. This keeps the playbook reliable — agents can trust what they read.

## Template

### File structure
```
playbook/
  README.md        # Index, boot protocol, how to record findings
  mechanics.md     # Core domain rules and verified facts
  strategy.md      # Tested strategies, heuristics, approaches
  mistakes.md      # Verified failure modes and how to avoid them
```

Adapt the file names to the domain. A deployment project might use `runbooks.md`, `incidents.md`, `checklists.md`. A research project might use `methods.md`, `findings.md`, `dead-ends.md`. The structure matters more than the names.

### Structural variants observed in the wild

**Multi-file (balatro)**: 9 files organized by topic — mechanics, strategy, jokers, combos, mistakes, per-session logs. Works when the domain has clear sub-areas and the team has time to maintain multiple files.

**Single-file consolidation (arc-agi, 2026-03-26)**: 5 original files collapsed into one 172-line `playbook.md` distilled from 130+ sessions, plus a `playbook/games/` directory with one file per game instance. Works when the core knowledge is dense enough to fit in one document and per-instance detail can live in its own sub-directory. Distillation happens periodically, not continuously.

Neither variant is inherently better — choose based on domain shape and maintenance budget.

### playbook/README.md
```markdown
# Playbook

Verified domain knowledge for {project}. Read before starting work.

## Files

| File | What it contains |
|------|-----------------|
| mechanics.md | Core domain rules and verified facts |
| strategy.md | Tested strategies and approaches |
| mistakes.md | Failure modes and how to avoid them |

## Boot Protocol

1. Read this README for orientation
2. Read mechanics.md for domain fundamentals
3. Read strategy.md for current best approaches
4. Check mistakes.md to avoid known pitfalls

## Recording New Findings

When you discover something worth recording:
1. **Verify it** — test the finding, don't record hunches
2. **Check for contradictions** — does it conflict with existing entries?
3. **Record with context** — what you observed, how you verified it, when
4. **Flag low-confidence entries** — if verification was partial, say so
```

### playbook/mistakes.md
```markdown
# Mistakes

Verified failure modes. Each entry records what went wrong and how to avoid it.

<!-- Add entries as you learn. Format:
### {Short description}
**What happened:** {what went wrong}
**Why:** {root cause}
**How to avoid:** {concrete guidance}
-->
```

## Integration with Agents

The playbook works with any agent structure. Typical integration:

- **Worker agents** (builder, player, operator) read the playbook at startup to benefit from accumulated knowledge
- **Analyst agents** study results and propose playbook updates based on evidence
- **Librarian agents** maintain the playbook — resolve contradictions, remove wrong entries, keep it organized (see `patterns/librarian.md`)
- **Orchestrator** decides when to prioritize playbook updates vs. other work

If the project doesn't have a dedicated librarian, the orchestrator or the worker agent maintains the playbook. The pattern works at any team size.

## When to Use

- Experiential domains where knowledge accumulates through iterative discovery
- Projects with trial-and-error workflows (game development, deployment, research, prototyping)
- Domains where "verified by doing" matters more than "documented by spec"
- Any project where agents keep re-discovering the same facts

## When to Skip

- Static codebases with no domain knowledge to accumulate
- Projects where ref docs already cover the domain adequately (the domain is fully specified)
- Projects without an iterative learn-by-doing workflow
- Very early projects — wait until there's something worth recording (don't create an empty playbook as scaffolding)

## Adoption Status

| Project | Has playbook | Structure | Maintained by | Last updated |
|---------|--------------|-----------|---------------|--------------|
| balatro | Yes | Multi-file (9 files, 793 lines) | `librarian` role | 2026-03-24 |
| arc-agi | Yes | Single-file (172 lines) + `playbook/games/` sub-dir | `librarian` role | 2026-03-27 |

**Notes**:
- arc-agi's consolidation (5 files → 1) happened during a librarian session that distilled 130+ sessions worth of verified mechanics into a single dense document. The 172-line size came from aggressive deduplication, not arbitrary trimming.
- balatro's multi-file structure predates its librarian role; the library was designed as a reference doc before there was a maintainer.
- Both are game-mod projects with Claude-as-player architectures. The pattern may generalize beyond games, but current evidence is all from that domain.
