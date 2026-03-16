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
| forge.thisminute.org | `~/projects/forge.thisminute.org` | Portal hub for forge ecosystem (contains rhizome + toolshed) | 3 | Established |
| toolshed | `~/projects/forge.thisminute.org/toolshed` | Universal software directory (was mainmenu) | 7 | Full |
| rhizome | `~/projects/forge.thisminute.org/rhizome` | Agent orchestration pattern catalog | 1 | Minimal |
| ops | `~/projects/ops` | Deployment and infrastructure for the ecosystem | 2 | Minimal+ |
| sts2 | `~/projects/sts2` | LLM autopilot mod for Slay the Spire 2 | 9 | Structured+ |
| balatro | `~/projects/balatro` | LLM autopilot mod for Balatro | 9 | Established+ |
| rts | `~/projects/rts` | Space Crystals RTS — Bevy 0.15 (Rust), was Godot | 1 | New |
| singularity-forge | `~/projects/singularity/singularity-forge` | Forge that builds missing toolshed software (replaced bellows) | 4 | New |
| recipe-scaler-substituter | `~/projects/recipe-scaler-substituter` | Domain-aware numerical reasoning with contextual substitution | 1 | New |
| agent-forge | `./agent-forge` | Generic forge template (static) | 4 | Template |

## Role Lists

### thisminute (11 agents)
builder, deployer, designer, economist, feedback, librarian, orchestrator, security, skeptic, strategist, tester

### rhizome (1 agent) — `forge.thisminute.org/rhizome`
steward — sole agent handling all work; self-manages context and proposes role splits when needed

### toolshed (7 agents) — `forge.thisminute.org/toolshed` (was mainmenu)
builder, curator, designer, librarian, orchestrator, skeptic, strategist

### ops (2 agents)
steward — handles deployment, health monitoring, scaling decisions, and backup across all ecosystem projects
security — infrastructure-layer security: nginx hardening, firewall, SSH, SSL/TLS, service isolation, secrets management

### sts2 (9 agents)
orchestrator, mod-builder, bot-builder, mcp-engineer, play-operator, analyst, overlay-dev, cycle, skeptic — LLM autopilot mod development. Uses `.claude/iteration_checkpoint.md` for cross-session state and `.claude/advisor-manager-index.md` as a section index for the 4100+ line core file. No PROTOCOL.md or FORUM.md — rapid iteration cycles with a build-test-fix loop.

### forge.thisminute.org (3 agents)
orchestrator, builder, skeptic — portal landing page and shared CSS theme for the forge ecosystem site. Checkpoint-based state, no forum. Owns visual consistency across rhizome, toolshed, and forge sub-sites. crucible/ (ideas database) being built out as fourth pillar.

### balatro (9 agents)
orchestrator, mod-builder, bot-builder, mcp-engineer, play-operator, analyst, overlay-dev, cycle, skeptic — LLM autopilot mod for Balatro. Adapted from sts2 architecture. Lua/Steamodded mod + external bot via TCP. Checkpoint-based state, no forum.

### rts (1 agent)
steward — Space Crystals RTS in Bevy 0.15 (Rust). Single-file implementation (~2000 lines). Replaced the Godot 4.6 version. Steward model, will split when codebase grows.

### singularity-forge (4 agents) — `~/projects/singularity/singularity-forge`
forgemaster, assayer, smith, skeptic — forge instance that scans the toolshed for missing software and creates projects to build them. Manages projects under `~/projects/singularity/`. Replaced bellows.

### agent-forge (template, not active)
forgemaster, assayer, smith, keeper — these are template roles, not active agents. agent-forge is the generic default forge that other forge instances (like this one) are derived from. It holds the canonical patterns and role templates. It doesn't run cycles — it gets maintained when patterns evolve.
