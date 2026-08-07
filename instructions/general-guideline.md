# General Agent Guidelines

- Use tools only when they materially improve correctness.
- Prefer the smallest read/search/command set that answers the task.
- Direct-read policy: for a known file or symbol, and up to three targeted reads, the assigned specialist reads directly. Use `@explore` only when orchestrator delegates broad or unknown discovery, caller-inventory reuse, or work beyond targeted reads.
- Only orchestrator delegates. Always use absolute paths when referring to files or delegating to subagents.
- Follow least privilege.
- Do not read or expose secrets.
- Keep changes tightly scoped.
