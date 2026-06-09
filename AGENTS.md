# Agent Instructions

## Syncing Prompt Files

When syncing prompt files from `~/.config/opencode/prompts/` to this repo:
- Use `cp` via `@executor` — do not read and re-write the file
- Example:
  ```bash
  cp ~/.config/opencode/prompts/orchestrator-guideline.md \
     ~/Documents/projects/opencode-agent-workflow/prompts/orchestrator-guideline.md
  ```
- To sync all prompts at once:
  ```bash
  cp ~/.config/opencode/prompts/*.md \
     ~/Documents/projects/opencode-agent-workflow/prompts/
  ```
