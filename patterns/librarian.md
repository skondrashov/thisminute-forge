# Pattern: Librarian (Proactive Doc Maintenance)

## Problem

Projects that accumulate knowledge artifacts — playbook files, memory files, multiple agent role files — experience drift. File references break. Playbook entries contradict each other. Memory files accumulate stale claims. Agent role files describe obsolete architecture. Dead code from abandoned approaches lingers, confusing agents about what's canonical.

The keeper feedback loop (`patterns/feedback.md`) handles reactive processing of shutdown reflections in forum-based projects. But many projects need proactive maintenance without a forum. They need someone to go looking for problems, not wait for agents to report them.

## Solution

A librarian agent that proactively maintains project knowledge. The librarian is distinct from the keeper in `patterns/feedback.md`:

| | Keeper (feedback.md) | Librarian |
|---|---|---|
| Trigger | Processes shutdown reflections | Proactively scans for problems |
| Scope | Forum cleanup + feedback routing | Playbook, memory, docs, agent files, dead code |
| Requires | Forum | No forum needed |
| Style | Reactive | Proactive |
| Best for | Projects with active forums | Projects with accumulating knowledge artifacts |

The librarian's core job: **make sure what the docs say matches what the code does.** If a role file references a file that doesn't exist, the librarian catches it. If a playbook entry has been disproven, the librarian removes it. If dead code from an old approach is confusing agents, the librarian flags it for cleanup.

## Template

### agents/librarian.md
```markdown
# Purpose

You maintain the project's knowledge: playbook, memory, docs, and project files. You prevent information decay — when docs drift from reality, when files reference things that don't exist, when the playbook contradicts itself.

# How This Agent System Works

- **`AGENTS.md`** — Project overview, architecture, constraints. Read this first.
- **`agents/*.md`** — Role files. You maintain all of them.
- **`playbook/`** — Domain knowledge base. You own this.
- **`memory/`** — Persistent memory across sessions. You own this too.

# What You Own

| File/Dir | What to maintain |
|----------|-----------------|
| `playbook/*.md` | Domain knowledge — keep accurate, remove wrong entries, add verified ones |
| `memory/` | Cross-session memory — remove stale info, consolidate duplicates |
| `AGENTS.md` | Project overview — keep structure current |
| `CLAUDE.md` | Entry point — keep minimal, don't expand |
| `agents/*.md` | Role files — keep descriptions accurate |

# Tasks

## 1. Maintain the Playbook

The playbook is the project's knowledge base. Keep it accurate:
- Update entries based on new evidence
- Resolve contradictions between files
- Remove entries that have been disproven
- Add verified findings from recent sessions

## 2. Maintain Memory

- Remove stale or wrong information
- Consolidate duplicate entries
- Seed empty memory files when agents have learnings worth persisting

## 3. Keep Docs Current

- AGENTS.md project structure matches reality
- File references point to things that actually exist
- Role files reflect how roles actually work
- No references to deleted files or old architecture

## 4. Clean Dead Code

Flag or remove artifacts from abandoned approaches:
- Code that imports functions that don't exist
- Files marked deprecated that are still in the tree
- Scripts that contradict the project's current methodology

## 5. Verify Claims

When updating docs, verify against the codebase:
- If a doc says "file X does Y", check that file X exists and does Y
- If a playbook entry makes a factual claim, check it against current evidence
- Flag discrepancies

# Boundaries

You maintain knowledge, not the product. You DO NOT build features. You DO NOT operate the system. You DO NOT make architectural decisions. You maintain the docs that describe those things.
```

## When to Use

- Projects with 3+ knowledge artifacts (playbook files, memory files, agent role files) that could drift from reality
- Projects where docs have already drifted from the codebase
- Projects that recently pivoted or restructured (high risk of stale references)
- Projects without a forum where the keeper feedback loop doesn't apply

## When to Skip

- Steward-level projects (1 agent, minimal docs — the steward self-maintains)
- Projects already running the keeper feedback loop with an active forum that covers doc maintenance
- Projects where all agents read all files and drift is immediately visible

## Combining with Other Patterns

The librarian complements:
- **Playbook** (`patterns/playbook.md`) — the librarian maintains the knowledge base
- **Keeper feedback loop** (`patterns/feedback.md`) — in projects with both a forum and a playbook, one agent can serve both roles
- **Checkpoint** (`patterns/checkpoint.md`) — the librarian can verify that checkpoint entries reference real files and current architecture

## Adoption Status

| Project | Has librarian | Playbook maintained | Docs current | Notes |
|---------|---------------|---------------------|--------------|-------|
| thisminute | Partial (via `librarian` role serving as keeper) | N/A — no playbook | Yes | Librarian also runs the forum keeper loop — one role, two jobs |
| toolshed | Yes (named `librarian`) | N/A — no playbook | Yes | Works with forum; proactive memory/doc maintenance |
| balatro | Yes (added in 9→5 restructure) | Yes (9-file playbook) | Active | Restructured 2026-03-25; librarian role defined, not yet proven in a session |
| arc-agi | Yes | Yes (consolidated single-file playbook) | Yes | **First field-tested librarian**: `memory/librarian.md` documents a real cleanup session (2026-03-26) that deleted dead-code files (`main.py`, `engine.py`, `solver.py`, stale agent files) and preserved rationale |

**Field evidence**: arc-agi's `memory/librarian.md` is the first recorded librarian session with concrete output — files deleted, files kept with justification, doc corrections. Cite this when explaining the pattern.
