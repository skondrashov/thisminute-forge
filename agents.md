# thisminute-forge

Forge instance for the thisminute ecosystem: a news aggregation platform, its companion sites, and the meta-tools that manage them. Say **`go`** to start. The forgemaster takes over — scans each project's agent system against the pattern library and applies upgrades.

## Key Files

- `agents/` — Forge role files (forgemaster, assayer, smith, keeper)
- `audits/current.md` — Latest cross-project gap analysis
- `patterns/` — Reusable agent system patterns

## Relationship to agent-forge

`agent-forge` (`./agent-forge/`) lives inside thisminute-forge as a nested git repo. It holds the canonical patterns and role definitions. thisminute-forge manages it directly — editing files, running the smoke test, and tagging releases — so that agent-forge's own repo stays pristine (no .claude/ artifacts, no session state). When patterns evolve from real usage, improvements get propagated back to agent-forge's templates.

## Projects

| Project | Path | Domain | Agents | Maturity |
|---------|------|--------|--------|----------|
| thisminute | `~/projects/thisminute` | Real-time news aggregation platform | 11 | Full |
| llms.thisminute.org | `~/projects/llms.thisminute.org` | Agentic engineering education site at forge.thisminute.org — six sections: home, models, context, orchestration, tools, forge | 4 top-level + 8 in sections | Established |
| ↳ orchestration | `llms.thisminute.org/orchestration` | Agent orchestration pattern catalog (was rhizome) | 1 | Minimal |
| ↳ tools | `llms.thisminute.org/tools` | Software directory with filled + unfilled slots (was toolshed) | 7 | Full |
| ops | `~/projects/ops` | Deployment and infrastructure for the ecosystem | 2 | Minimal+ |
| dbt.thisminute.org | `~/projects/dbt.thisminute.org` | Encrypted static DBT diary card app — single-file, no agents | 0 | Static |
| sts2 | `~/projects/sts2` | LLM autopilot mod for Slay the Spire 2 | 9 | Structured |
| balatro | `~/projects/balatro` | LLM autopilot mod for Balatro | 5 | Established+ |
| rts | `~/projects/rts` | Clash — 3-faction multiplayer RTS (Bevy 0.15, Rust) | 4 | Minimal+ |
| arc-agi | `~/projects/arc-agi` | LLM agent for ARC-AGI-3 interactive puzzles (untracked) | 12 | Established |
| agent-forge | `./agent-forge` | Generic forge template (static) | 4 | Template |

**Retired / orphaned** (historical, not actively tracked):
- ~~singularity-forge~~ — retired 2026-04-09, premise was wrong
- ~~recipe-scaler-substituter~~ — retired 2026-04-15, orphaned weekend-scope crucible scaffold, never committed
- ~~forge.thisminute.org~~ — orphaned 2026-04-11, replaced by llms.thisminute.org

## Role Lists

### thisminute (11 agents)
builder, deployer, designer, economist, feedback, librarian, orchestrator, security, skeptic, strategist, tester

### llms.thisminute.org (4 top-level + 8 in sections)
Agentic engineering education site at forge.thisminute.org. Home page IS the agent anatomy diagram; each component links to a deeper section. Six sections: home (anatomy flowchart), models (60+ model catalog), context (statelessness explainer), orchestration (271 patterns), tools (16K+ entries), forge (multi-agent guide). Watermelon-pink + mint pastel theme on parchment-cream / plum-dusk. Fredoka typeface. Casual essayist voice. Repo dir name predates rebrand. Checkpoint-based state, no forum.

- **top-level (4)**: orchestrator, builder, skeptic + section stewards
- **orchestration section (1)** — `llms.thisminute.org/orchestration` (was rhizome, renamed 2026-04-11): steward — pattern catalog (271 patterns), FastAPI + SQLite social layer (votes, comments).
- **tools section (7)** — `llms.thisminute.org/tools` (was toolshed, renamed 2026-04-11): orchestrator, builder, curator, designer, librarian, skeptic, strategist — software directory with filled + unfilled slots, ~16K entries across 139 categories. Curator owns the unfilled slots concept (was crucible/ideas).

### ops (2 agents)
steward — handles deployment, health monitoring, scaling decisions, and backup across all ecosystem projects
security — infrastructure-layer security: nginx hardening, firewall, SSH, SSL/TLS, service isolation, secrets management

### dbt.thisminute.org (no agents)
Single-file static DBT (Dialectical Behavior Therapy) diary card app — encrypted, private, in `~/projects/dbt.thisminute.org/index.html`. Not a multi-agent project; user maintains directly.

### sts2 (9 agents, dormant)
orchestrator, mod-builder, bot-builder, mcp-engineer, play-operator, analyst, overlay-dev, cycle, skeptic — LLM autopilot mod development. Uses `.claude/iteration_checkpoint.md` for cross-session state and `.claude/advisor-manager-index.md` as a section index for the 4100+ line core file. No PROTOCOL.md or FORUM.md — rapid iteration cycles with a build-test-fix loop. Frozen at cycle 37 since 2026-03-14.

### balatro (5 agents, dormant)
orchestrator, player, analyst, librarian, api-developer — LLM autopilot mod for Balatro. Pivoted to Claude-as-player architecture. Lua/Steamodded mod + TCP server + cmd.py CLI. Playbook-based knowledge, no forum. NO AUTOPLAY constraint.

### rts (4 agents)
steward, builder, skeptic, balancer — Clash, a 3-faction multiplayer RTS in Bevy 0.15 (Rust). ~7,200+ lines across 13+ source files. UDP relay networking.

### arc-agi (12 agents, untracked)
orchestrator, player, analyst, skeptic, librarian + 7 pipeline agents (pipeline_planner, pipeline_perception, pipeline_explorer, pipeline_analyst, pipeline_troubleshooter, pipeline_reviewer, pipeline_skeptic) — LLM agent for ARC-AGI-3 interactive puzzles. Three co-existing modes: Claude-as-player (cmd.py + server.py), LLM-as-API (agent.py + game_manager.py), Pipeline (pipeline.py + 7 pipeline agents). AGENTS.md only documents the original 5 agents — pipeline subsystem invisible at top level.

### agent-forge (template, not active)
forgemaster, assayer, smith, keeper — template roles, not active agents. Canonical patterns and role templates live here; thisminute-forge syncs from this repo.
