# Pattern: External Validation

## Problem

Agents that build and test their own work can produce circular results. Self-generated test suites validate the agent's assumptions, not the code's correctness. A project can score perfectly on its own tests while being fundamentally broken against real-world inputs.

This is especially dangerous for forges and other systems that generate projects at scale — the feedback loop is entirely internal, so confidence grows while quality doesn't.

## Evidence

A forge built 39 projects with internal test suites. One project scored 210/210 on self-generated math tests but only 9/20 on real problems sourced externally. External validation caught bugs in 6 projects that internal tests missed entirely. The root cause: agents test what they built, not what was needed.

## Solution

After building or significantly changing a project, validate outputs against **sources the agent didn't generate**:

1. **Real-world data** — test against actual inputs, not synthetic ones
2. **External APIs/standards** — compare behavior against documented specs
3. **Known-good references** — use established test sets, benchmarks, or reference implementations
4. **Manual spot-checks** — have the agent flag outputs that should be human-reviewed

The key constraint: **the validation source must be independent of the build process.** If the same agent wrote the code and the tests, the tests don't count as validation.

## When to Apply

- After a forge generates a new project
- After significant refactoring where test suites were also modified
- When a project's test results seem too good (100% pass rate on complex logic)
- During periodic audits of project health

## How to Apply

### For forges that generate projects

Add a validation step after the smith builds:

```
1. Smith builds project with internal tests
2. Smith (or assayer) identifies external validation sources:
   - Public APIs the project claims to interact with
   - Standards/specs the project claims to implement
   - Real datasets the project claims to process
3. Run the project against external sources
4. Compare results to internal test claims
5. Flag discrepancies in the audit
```

### For individual projects

Add to the skeptic's role file:

```markdown
## External Validation

When reviewing work, check at least one claim against an external source:
- If the code parses a format, test with a real file (not a synthetic one)
- If the code calls an API, verify against the actual API docs
- If the code implements a spec, check the spec directly
```

## Signs You Need This

- All tests pass but the product doesn't work in practice
- Test coverage is high but bug reports keep coming
- A project's metrics look better than its actual output quality
- Agents are writing tests that mirror the implementation rather than testing behavior

## Adoption Status

| Project | External validation active | Last validated | Notes |
|---------|--------------------------|----------------|-------|

<!-- Fill in during audits -->
