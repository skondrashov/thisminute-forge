---
name: No concrete thresholds for LLM decisions
description: User trusts LLM judgment for decisions like when to split agent roles — don't add arbitrary numeric thresholds
type: feedback
---

Don't add concrete thresholds or numeric decision points for things an LLM agent will be judging (e.g., "split when context exceeds 150 lines"). The user trusts the LLM to make these calls contextually.

**Why:** The user sees the LLM as a capable decision-maker that doesn't need rigid rules to make judgment calls. Adding thresholds implies distrust and over-constrains the agent.

**How to apply:** When designing agent systems or writing role files, describe *what* to watch for (e.g., "context covering too many distinct domains") but let the agent decide *when* to act. No line counts, no magic numbers.
