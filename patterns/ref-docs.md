# Pattern: Reference Doc Splitting

## Problem

AGENTS.md grows to include everything: architecture, frontend pitfalls, backend pitfalls, domain-specific details. Every agent reads all of it, even though most of it isn't relevant to their role.

Context bloat = wasted tokens + agents skimming past relevant info.

## Solution

Split AGENTS.md into:
1. **AGENTS.md** (slim, universal) — architecture diagram, stack, key design decisions
2. **ref/*.md** (role-specific) — detailed technical context that only relevant agents read

Each agent's role file lists which ref docs it should read.

## Template

```
AGENTS.md              # ~100 lines. Everyone reads this.
ref/frontend.md        # UI layout, filter system, pitfalls, quality signals
ref/backend.md         # Pipeline flow, data quality, API patterns
```

### Routing Table (add to each role file)

```markdown
# Reference Docs

Read before starting work (per PROTOCOL.md step 4):
- `ref/frontend.md` — if your task touches UI/JS/CSS
- `ref/backend.md` — if your task touches API/pipeline/data
```

## When to Split

- AGENTS.md exceeds ~150 lines
- More than 2 distinct technical domains (frontend vs backend vs ML vs infra)
- Agents are reading 200+ lines of context they never reference

## When to Skip

- AGENTS.md is under 100 lines
- The project has only one technical domain
- Small teams where every agent touches everything

## Adoption Status

| Project | AGENTS.md slim | Has ref/ docs | Role files route |
|---------|---------------|---------------|-----------------|

<!-- Fill in during audits -->
