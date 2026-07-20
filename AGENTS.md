# Agent Instructions

## Syncing the Repository Backup

The global configuration is the source; this repository is the reviewed backup. Review differences before copying, and never treat the repository backup as an automatic runtime sync.

### Compare

Run through `@executor`:

```bash
diff -u ~/.config/opencode/opencode.json opencode.json
diff -ru ~/.config/opencode/prompts/ prompts/
```

### Copy

After reviewing the differences, run through `@executor`:

```bash
cp ~/.config/opencode/opencode.json opencode.json
cp ~/.config/opencode/prompts/*.md prompts/
```

These commands copy from the global runtime source to the repository backup. Do not reverse the direction during a backup refresh.

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

### Validate

Run through `@executor`:

```bash
python3 -m json.tool opencode.json > /dev/null
git diff --check
```

The active configuration references nine prompt backups: `orchestrator`, `general`, `explore`, `executor`, `scout`, `reviewer`, `planner`, `frontend-designer`, and `ui-reviewer`. `general-lite-guideline.md` and `reviewer-lite-guideline.md` are unreferenced backups and should not be described as active agents.

For permissions, `permission.write` is a no-op in opencode; `permission.edit` controls whether files may be modified.
