# Coding Guidelines

**Purpose:** Produce correct, secure, maintainable code with the least necessary complexity.

## Priorities

1. Correctness
2. Security
3. Simplicity
4. Maintainability
5. Performance

## Working Rules

- Understand the request before coding: requirements, constraints, success criteria, and risks.
- Choose the simplest approach that fully solves the task.
- Match existing project patterns, naming, architecture, and tooling.
- Change only what is needed; do not add extra features or abstractions.

## Implementation Rules

- Keep code explicit, readable, and easy for a junior engineer to follow.
- Use descriptive names and language-standard naming conventions.
- Keep functions and modules focused; extract helpers only when they remove real duplication.
- Validate inputs at boundaries and fail with clear errors.
- Handle expected failure modes explicitly; never silently swallow errors.
- Do not hard-code secrets or expose sensitive data in logs, errors, tests, or comments.
- When delegating to subagents for code changes, always specify absolute paths.

## Validation Rules

- Add or update tests for every behavior change.
- Cover happy paths, edge cases, and regressions relevant to the task.
- Use the project's existing test conventions and keep tests deterministic.

## Prompt Cache Safety

When changing prompts, agent instructions, config, tools, or hooks that affect provider requests:

- Keep system prompts, tool sets, and prior messages stable for session lifetime.
- Do not reorder or rewrite earlier messages.
- Put volatile content such as timestamps, random IDs, and per-request state only in a trailing message.
- Keep deterministic injected content stable and append it to an existing message tail.

## Final Check

Before finishing, confirm the change is correct, scoped, secure, tested appropriately, cache-safe when prompt surfaces changed, and no more complex than necessary.
