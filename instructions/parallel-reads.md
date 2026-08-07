# Parallel Reads

- Batch independent `read`/`glob`/`grep` calls when they can run concurrently.
- Orchestrator may batch independent Task calls; subagents do not delegate.
- Assigned specialists read known files or symbols directly; use `@explore` only for broad or unknown discovery, caller inventories, or when targeted reads are insufficient.
