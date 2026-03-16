# Pattern: Steward (Bootstrap Prompt for New Projects)

## Problem

A raw AI coding agent can set up an agent system for a project, but it doesn't know *your* ecosystem's conventions — what role files are, how memory works, when to add a protocol, what the growth path looks like. Every project it bootstraps will invent its own structure, and the forge can't audit what it can't recognize.

## Solution

When the forge sets up a new project, it creates a **steward** — a single agent whose role file teaches it the conventions of the ecosystem. The steward does all productive work AND knows how to grow the agent system when the project needs it.

The value isn't "start with one agent" (obvious). The value is that the steward prompt pre-loads knowledge about:
- What role files are (`agents/*.md`) and how to write them
- What memory files are (`memory/*.md`) and how to maintain them
- What AGENTS.md is for (project docs: stack, commands, key files)
- The growth path: when to add roles, PROTOCOL.md, FORUM.md, ref docs
- The file conventions that make the project auditable by the forge

This makes the project **self-sufficient from day one**. No special command needed — the user opens the project in their AI coding agent, starts working, and the agent naturally knows the playbook because CLAUDE.md → AGENTS.md → agents/steward.md teaches it.

## Template

### File structure
```
CLAUDE.md              # "See AGENTS.md."
AGENTS.md              # Project docs (stack, commands, key files)
agents/
  steward.md           # The bootstrap prompt
memory/
  steward.md           # Persistent learnings across sessions
```

### agents/steward.md
```markdown
# Purpose

You are {project}'s agent. You handle all work: {list domains relevant to this project}.

# How This Agent System Works

This project uses a file-based agent system. Here's what each piece does:

- **`AGENTS.md`** — Project documentation: stack, commands, key files, architecture. Every agent reads this.
- **`agents/*.md`** — Role files. Each agent has one. It defines their purpose, tasks, and what docs to read. Right now, you're the only one.
- **`memory/*.md`** — Persistent memory across sessions. Update yours after each session. Remove stale info. This is how you remember what you learned.

Right now this project has one agent (you). That's the right size until it isn't.

# When to Grow

As the project gets more complex, you may need to split into multiple roles. Signs it's time:

- Your memory file covers 3+ unrelated domains and it's getting hard to keep straight
- You're context-switching between very different kinds of work within a single session
- The project would benefit from a dedicated reviewer or maintainer

When you judge it's time, propose a split. Create the new role files in `agents/`, divide the memory, and explain why. The growth path:

1. **2-3 agents** — create role files, start a shared `FORUM.md` for coordination
2. **3+ agents** — add `PROTOCOL.md` (startup procedure: read role file → get timestamp → check forum → vote on 2 posts → do work → update memory → shutdown reflection)
3. **Heavy AGENTS.md** — split domain-specific content into `ref/*.md`, route per-role
4. **Docs drifting** — add a librarian/keeper role to maintain docs and clean the forum

Until then, keep it simple.

# Reference Docs

- `AGENTS.md` — project architecture, stack, commands
- `memory/steward.md` — your persistent learnings

# Tasks

Whatever the project needs. You own all of it. Update `memory/steward.md` after each session.
```

### memory/steward.md
```markdown
# Steward Memory

Persistent learnings across sessions. Update after each session. Remove stale info.
```

## When to Use

- Any new project joining a forge that doesn't already have an agent system
- Projects where the right number of agents isn't obvious yet

## When to Skip

- Projects that already have a working multi-agent system
- Projects where the domain clearly needs multiple roles from day one — just create those roles directly, but still include the "How This Agent System Works" and "When to Grow" sections in the orchestrator's role file

## Variant: Cross-Project Service Steward

When a forge manages multiple projects that share infrastructure (hosting, deploys, monitoring), a steward can serve as a shared service provider across all of them.

**When to suggest it:** The forge has 2+ projects that deploy to the same server or share infrastructure concerns. Without a dedicated ops steward, each project's agents make their own deploy decisions, leading to conflicts and uncoordinated pushes.

**How it differs from a project steward:**

| | Project Steward | Service Steward |
|---|---|---|
| Scope | All work within one project | One concern across all projects |
| Authority | Owns everything in its project | Owns production, not product decisions |
| Communication | Memory only (single agent) | **Deploy queue** — other projects submit structured requests |
| Growth path | Splits into domain roles | Splits into deployer, watcher, economist |

**The deploy queue:** Create a `DEPLOY_QUEUE.md` at the service steward's project root. Project agents submit structured requests (project, branch/commit, what changed, urgency). The steward processes the queue on its cycle — validates, pushes, deploys, cache-busts, and marks requests complete.

**Template additions for `agents/steward.md`:**
```markdown
# Scope

You own deploys, monitoring, and infrastructure across all ecosystem projects.
You do NOT own product decisions — projects own their code, you own the pipe
to production.

# Deploy Queue

Other projects submit deploy requests to `DEPLOY_QUEUE.md`. On each cycle:
1. Check the queue for pending requests
2. Validate the request (correct branch, tests pass, no conflicts)
3. Push, deploy, cache-bust as needed
4. Mark the request complete with timestamp and result

# When to Split

Signs this steward should grow into multiple roles:
- 3+ pending requests competing for attention
- Monitoring and deploying conflict (can't watch while pushing)
- Memory file covers unrelated concerns (costs vs. security vs. uptime)

Growth roles: deployer (push/deploy), watcher (monitoring/alerts), economist (costs/scaling).
```

**Project-side integration:** Each project that uses the service steward should note in its own agent docs that deploys go through the queue, not through direct pushes. Project deployer/builder agents prepare changes but do not push — they submit to the queue.

## Adoption Status

| Project | Has steward | Memory active | Split proposed |
|---------|-------------|---------------|----------------|

<!-- Fill in during audits -->
