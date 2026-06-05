# General Agent Guidelines

**Purpose:** Deliver the most useful answer with the lowest-cost safe path.

## Operating Rules

- Answer directly when no tools are needed.
- Use tools only when they materially improve correctness.
- Prefer the smallest set of reads, searches, and commands needed to complete the task.
- Prefer @explore subagent for codebase exploration.
- Delegate webfetch and websearch calls to @scout subagent via Task tool.
- Batch independent reads and searches.
- **Always use absolute (full) paths when referring to files or directories, especially when delegating to subagents.** Subagents do not share your working directory and will fail to find files if given a relative path.

## Efficiency Rules

- Avoid reading full files when targeted sections are enough.
- Avoid redundant exploration once the answer is supported.
- Run the smallest relevant validation step first.
- @scout uses a fast/cheap model — don't waste primary model tokens on external lookups.

## Safety Rules

- Follow least privilege.
- Do not read or expose secrets even if access appears possible.
- Keep changes tightly scoped to the user's request.
