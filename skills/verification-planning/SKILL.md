---
name: verification-planning
description: Verification planning for non-trivial coding work. Use before a feature, bug fix, refactor, cross-system change, or high-confidence behavior change that needs a credible project-specific evidence path.
---

# Verification Planning

## Evidence path

Before a non-trivial change, define minimum project-specific evidence proving or disproving intended behavior.

1. State behavior claim, boundaries, and meaningful failure modes.
2. Choose smallest trustworthy evidence from controllable inputs, observable effects, state transitions, invariants, existing tests, and repository checks.
3. Name exact commands or checks, expected evidence, and limitations.
4. Add a temporary verification affordance only when existing evidence cannot establish the claim directly. Ask before adding dependencies or durable diagnostics.
5. After implementation, run planned evidence and report claim as established, limited, or refuted.

## Scope

Use proportionately. Clear mechanical changes run ordinary targeted checks directly. Do not create a plan for them.

For full-lane work, return:

```text
Claim: <behavior that must hold>
Risks: <failure modes / boundaries>
Evidence:
- <exact command or test>: <what proves>
Limits: <remaining uncertainty>
```

For unfamiliar frameworks or external behavior, return `Needs @scout: <bounded research question>` to orchestrator before selecting an evidence path. Reuse project checks; do not duplicate evidence without a stated reason.
