# One-layer handoff

- Only orchestrator delegates. Subagents never delegate; they use direct targeted reads and commands, then report blockers to orchestrator.
- Use this compact packet for implementation, planning, review, and frontend handoffs. For narrow `explore` and `scout` handoffs, provide only workspace root, bounded objective, exact target, supplied evidence, and return contract:
  - **Original goal:** user goal, including acceptance constraints
  - **Current objective:** one bounded objective for this agent
  - **Workspace/git context:** absolute workspace root; branch, dirty, and staged state when relevant
  - **Constraints/non-goals:** explicit boundaries
  - **Exact context:** absolute paths, symbols/areas, decisions, and supplied evidence
  - **Prior findings/results:** relevant reads, reviews, command outcomes, or blockers
  - **Completed/remaining work:** what is done and what is still needed
  - **Return contract:** exact evidence, files, or result format
- Downstream agents must use supplied evidence and perform only targeted reads needed to act. Do not broadly rediscover unchanged context. Missing critical context must be reported, not guessed.
- Group all related steps that the same downstream agent can complete into one handoff. The handoff must describe the ordered substeps and request one consolidated result; do not spawn one subagent per substep. Split only for a new decision, different specialist, unrelated context, or a changed plan.
- Preserve the original goal and acceptance constraints. Orchestrator retains reasoning, decisions, and final synthesis; subagents return only bounded evidence or execution results.
- Do not respawn an objective when the existing result already satisfies it. Native task calls may return a `task_id` that can be supplied to continue the same bounded objective; continuation is optional and only uses a task ID supplied by native tooling. Never fabricate IDs or add custom persistence/session files or protocols. Use fresh tasks for independent reviews, distinct objectives, or narrowed retries after terminal/blocking results; pass prior findings in the packet.
- Agents run their own commands for their bounded objective. Use ordered, fail-fast command sequences when steps depend on each other; split only for a new decision, unrelated context, or different agent. Require branch/dirty/staged context only for branch-sensitive or other git work.
