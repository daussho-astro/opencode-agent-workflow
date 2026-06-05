# Parallel Reads

When exploring a codebase or reading multiple files:

- Launch multiple @explore subagents simultaneously via the Task tool
- Batch independent reads into one message with parallel Task calls
- Prefer @explore over @general for read-only exploration
- Use concurrent tool calls for independent glob/grep/read operations
- Delegate webfetch and websearch calls to @scout subagent via Task tool
- @scout uses a fast/cheap model — don't waste primary model tokens on external lookups
