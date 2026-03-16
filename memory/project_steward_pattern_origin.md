---
name: Steward pattern originated from rhizome discussion
description: The single-agent steward pattern was born from discussing what rhizome needed — user prefers organic role growth over pre-scaffolding
type: project
---

The steward pattern was created 2026-03-13 based on user's idea of a context manager that starts as one agent and splits when context pressure warrants it. Applied first to rhizome, then added to agent-forge as the 5th canonical pattern.

**Why:** User had previously experimented with context-manager + orchestrator + generic-worker, where the worker splits into new roles when its persistent context gets too big. We simplified to just the steward (worker + context manager in one).

**How to apply:** When onboarding new projects to the forge, offer the steward as the default starting point. Don't push multi-agent systems on projects that don't clearly need them.
