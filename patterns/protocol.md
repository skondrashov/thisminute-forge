# Pattern: Startup Protocol

## Problem

Without a shared startup protocol, agents skip steps, read docs in wrong order, forget to check the forum, or fabricate timestamps. Each agent file duplicates startup instructions inconsistently.

## Solution

Create a standalone `PROTOCOL.md` that ALL agents follow. Keep `CLAUDE.md` as a one-liner pointer. Keep agent role files focused on tasks, not process.

## Template

```markdown
# Agent Protocol

How agents operate on {project}. For project architecture, see `AGENTS.md`.

## Startup

1. You will be told your name (e.g., "you are the builder")
2. **Understand your role**: Read your agent file (`agents/{your-name}.md`)
3. **Get current time**: Run `powershell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm'"` and record the output. You MUST use this exact timestamp in all forum posts and reports.
4. **Understand the project**: Read `AGENTS.md` for architecture. Then read the reference docs listed in your role file — only the ones marked as relevant to your role.
5. **Check the forum**: Read `FORUM.md`:
    - What have other agents been working on?
    - Vote on proposals relevant to your role (+1 agree, -1 disagree)
    - You MUST vote on at least 2 posts before posting anything new
6. **Check messages**: Read `messages/{your-name}.md` if it exists. Handle messages, then archive them.
7. **Execute your tasks**: Follow the Tasks section of your agent file.
8. **Report findings**: Post to `FORUM.md` or save to `reports/{your-name}.md`.
9. **Update memory**: Add learnings to `memory/{your-name}.md`. Remove stale info.
10. **Shutdown reflection**: The forgemaster will ask you to evaluate each context layer. Be specific and honest.
11. **Exit** (unless you're the forgemaster).
```

## Why Each Step Matters

- **Step 3 (timestamp)**: Without this, agents fabricate times. Forum posts become unorderable.
- **Step 4 (ref docs)**: Agents shouldn't read everything — only what's relevant to their role.
- **Step 5 (vote before posting)**: Forces agents to engage with existing work before adding noise.
- **Step 10 (reflection)**: Feeds the self-improving context loop.

## When to Use

All projects with 3+ agents. For 2-agent projects, the protocol can live in the forgemaster's role file instead of a standalone file.

## When to Skip

Solo-agent projects, or projects where the forgemaster file already covers the protocol adequately.

## Adoption Status

| Project | Has PROTOCOL.md | Has timestamps | Has ref doc routing | Has reflection step |
|---------|----------------|----------------|--------------------|--------------------|

<!-- Fill in during audits -->
