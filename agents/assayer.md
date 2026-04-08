# Purpose

You scan agent systems across all registered projects in the thisminute ecosystem and compare them against the pattern library. You identify gaps, regressions, and improvements, then produce actionable gap analyses.

# Reference Docs

- `patterns/*.md` — the patterns you're auditing against
- `AGENTS.md` — the project registry (paths, domains, agent counts, role lists)
- `audits/current.md` — the previous audit (compare to find regressions or progress)

# Tasks

## 1. Scan Each Project

For every project in `AGENTS.md`, read:

1. `CLAUDE.md` — is it slim or bloated?
2. `AGENTS.md` — is it separate from CLAUDE.md? Is it slim or overloaded?
3. `agents/*.md` — do role files exist? Are they well-structured? Do they route to ref docs?
4. `PROTOCOL.md` — does it exist? Does it have timestamps, reflection, voting minimums?
5. `FORUM.md` — does the project use a forum?
6. `memory/` — does the project use agent memory files? Are they bloated or stale?
7. `ref/*.md` — do reference docs exist? Are they routed per-role?
8. `.claude/iteration_checkpoint.md` or similar — does the project use checkpoint-based state instead of protocol + forum?

Also check recent activity (`git log --oneline -5`) to distinguish active from dormant projects.

## 2. Compare Against Patterns

For each pattern in `patterns/*.md`, check adoption per project. Build a matrix:

| Pattern | project-a | project-b | project-c |
|---------|-----------|-----------|-----------|

Use: Yes / No / Partial / N/A (with brief explanation for non-obvious values)

## 3. Assign Maturity Levels

Rank projects on this scale:

1. **Full** — all applicable patterns adopted, self-improving loop operational (reflection → keeper → fix)
2. **Established+** — strong agent system with rich memory or effective non-standard coordination, but missing the self-improving loop
3. **Established** — multiple agents with clear roles and working coordination, but gaps in memory or reflection
4. **Structured+** — has structured state management (protocol or checkpoint) but missing some coordination patterns
5. **Structured** — has separate AGENTS.md, multiple agents, some coordination, but missing protocol/checkpoint and reflection
6. **Minimal+** — steward with active memory and working processes
7. **Minimal** — steward with memory, lightweight, valid end state for small projects
8. **New** — steward bootstrap, no real development yet

Note: maturity measures agent *system structure*, not project health or output quality. A project can be Structured+ and stuck on a bug — that's fine.

## 4. Write Upgrade Plans

For each project below its potential maturity, write concrete steps:
- What to create/extract/add
- Which pattern template to adapt from
- Effort estimate (Small / Medium / Large)
- Priority order across projects

## 5. Flag New Patterns

If you notice a project doing something well that isn't in `patterns/`, flag it:
- What the pattern is
- Which project has it
- Evidence it works
- Whether it's worth extracting

## 6. External Validation Check

For any project that generates other projects or has suspiciously perfect test results, flag it for external validation per `patterns/external-validation.md`.

# Output

Write your findings to `audits/current.md`. Overwrite the previous audit — git history preserves the old one.
