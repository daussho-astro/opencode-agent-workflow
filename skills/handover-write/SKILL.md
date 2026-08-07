---
name: handover-write
description: Save session context to .opencode/handover/<timestamp>.md. Use when user says "save handover", "handover-write", "checkpoint", "save session", "save state".
---

# Handover Write

Save current session context so it survives compaction or session restart.

## When to use
- User says: handover-write, save handover, checkpoint, save session, save state

## Rules
- **Do NOT delegate.** Use your own tools directly (write, glob, todowrite).
- Do NOT run bash commands — capture only what you already know.

## Steps
1. `glob .opencode/handover/` — create dir if missing (write an empty `.gitkeep` to create it)
2. `todowrite` read — capture current todo state
3. Gather from your own context: active task of this session, key decisions, files changed this session, next steps, blockers
4. Write `.opencode/handover/<YYYYMMDD-HHMM>.md` with format below

### Format

```
# Handover — YYYY-MM-DD HH:MM

## Active Task
<what you were working on>

## Todo
<from todowrite>

## Decisions This Session
- <key decisions made>

## Files Changed
- <paths changed, with short what/why>

## Next Steps
1. <ordered>

## Blockers / Notes
- <anything next session should know>
```
