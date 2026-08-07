---
name: handover-load
description: Restore session context from .opencode/handover/. Use when user says "load handover", "handover-load", "resume", "restore context". Also checks at session start and after compaction.
---

# Handover Load

Restore context from a previous handover file so work can continue after compaction or a fresh session.

## When to use
- At session start — check for handover automatically
- After compaction — check for handover automatically
- User says: load handover, handover-load, resume, restore

## Rules
- **Do NOT delegate.** Use your own tools directly (glob, read, todowrite).

## Steps
1. If user named a specific file (e.g. "load handover-20260727-1430"): read `.opencode/handover/<name>.md`
2. If no file named: `glob .opencode/handover/*.md`, sort descending, pick newest
3. If no handover dir or no files: say "No handover found, starting fresh" and stop
4. If specified file missing: list available files, ask which one
5. Read the handover file
6. `todowrite` write — restore todo items from the handover
7. Output summary to user:
   - Timestamp of handover
   - Active task
   - Next steps
   - Blockers
