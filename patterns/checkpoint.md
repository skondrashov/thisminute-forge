# Pattern: Checkpoint-as-Protocol (Iterative State Tracking)

## Problem

PROTOCOL.md + FORUM.md work well for multi-agent deliberation — agents vote on forum posts, follow a structured startup sequence, and coordinate through explicit communication channels. But for projects with tight build-test-fix loops (game mods, iterative prototypes, solo-dev tools), the protocol overhead doesn't pay for itself. Agents don't need to deliberate — they need to know what happened last time and what's blocked.

## Solution

Replace PROTOCOL.md + FORUM.md with a single **checkpoint file** that tracks current state, blockers, and decisions. Agents read it at startup and update it at shutdown. Combined with per-agent memory files, this provides similar coordination benefits with less ceremony.

The checkpoint is a living document — it reflects the current session's state, not a historical log. Old state gets overwritten, not appended.

## Template

### File structure
```
.claude/
  iteration_checkpoint.md   # Current state, blockers, decisions
agents/
  *.md                      # Role files (same as standard pattern)
memory/
  *.md                      # Per-agent persistent memory (same as standard pattern)
```

### .claude/iteration_checkpoint.md
```markdown
# Iteration Checkpoint

## Current State
{What's working, what's not, where development left off}

## Blockers
{Active blockers with evidence — what failed, error messages, API limitations}

## Decisions
{Key decisions made this session that future sessions need to know}

## Next Steps
{Concrete next actions, ordered by priority}
```

## When to Use

- Projects with iterative build-test-fix loops (game mods, prototypes)
- Projects where agents work sequentially, not in parallel
- Projects where the "forum voting" model adds overhead without value
- Projects with checkpoint-natural workflows (cycles, iterations, sprints)

## When to Skip

- Projects where multiple agents need to deliberate on decisions (use FORUM.md)
- Projects where startup sequencing matters (use PROTOCOL.md)
- Projects with 5+ agents that need structured communication channels

## How It Differs from Protocol + Forum

| | Protocol + Forum | Checkpoint |
|---|---|---|
| Coordination | Structured startup sequence + forum voting | Read checkpoint → work → update checkpoint |
| Communication | Forum posts with votes | Checkpoint sections + memory files |
| History | Forum accumulates posts (needs cleanup) | Checkpoint is overwritten each session |
| Overhead | Higher — multiple files, voting minimums | Lower — one file, no voting |
| Best for | Multi-agent deliberation | Sequential iterative work |

## Combining with Memory

The checkpoint tracks *session state* (ephemeral). Memory tracks *learnings* (persistent). Don't duplicate between them:

- Checkpoint: "Currently blocked on X API returning 404" → gets cleared when resolved
- Memory: "X API requires auth header even for public endpoints" → stays forever

## Adoption Status

| Project | Has checkpoint | Memory active | Notes |
|---------|---------------|---------------|-------|

<!-- Fill in during audits -->
