---
name: agent-forge is the static template upstream
description: agent-forge at ~/projects/agent-forge is the generic forge template; thisminute-forge derives from it and propagates improvements back
type: project
---

agent-forge is the canonical generic forge template. thisminute-forge is a project-specific instance for the thisminute ecosystem.

**Why:** agent-forge needs to stay generic and useful for anyone. thisminute-forge is customized for thisminute/rhizome/mainmenu. Pattern improvements discovered through real usage here get propagated back to agent-forge's templates.

**How to apply:** When updating patterns in thisminute-forge, consider whether the change is generic enough to push back to agent-forge. Agent-forge is registered in agents.md but marked as "Template" maturity — don't try to run audit cycles on it the way you would an active project.
