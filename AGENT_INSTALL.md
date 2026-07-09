# Agent Install Guide

Short instructions for an AI/code agent installing the opencode-agent-workflow.

## Objective

Install the opencode-agent-workflow configuration into `~/.config/opencode` by running the provided `install.sh` script.

The installer handles `opencode.json`, prompts, instructions, commands, plugins, skills, and npm dependencies.

## Safety Rules

- Do **not** read, print, or commit secrets.
- Do **not** inspect `~/.local/share/opencode/auth.json`.
- Do **not** overwrite any existing user files unless the user explicitly requests `--overwrite`.
- If `~/.config/opencode/opencode.json` already exists, **stop and ask the user** whether to merge manually or run `./install.sh --overwrite`.

## Exact Commands

```bash
git clone git@github.com:daussho-astro/opencode-agent-workflow.git
cd opencode-agent-workflow
./install.sh --dry-run
./install.sh
```

Optional flags:
- `./install.sh --dry-run` — preview actions without copying files.
- `./install.sh --yes` — non-interactive proceed for safe actions (does **not** imply overwrite).

**Never use `--overwrite` unless the user explicitly requests it.**

## Validation Checklist

After installation, confirm all of the following:

- [ ] `~/.config/opencode/opencode.json` exists (or `opencode.workflow-template.json` if a user config already existed).
- [ ] `python3 -m json.tool ~/.config/opencode/opencode.json` succeeds (or skip if `python3` is unavailable).
- [ ] `~/.config/opencode/prompts`, `instructions`, `commands`, `plugins`, and `skills` contain the repo files or were intentionally skipped because they already existed.
- [ ] `npm install --prefix ~/.config/opencode` succeeded, or npm was unavailable and dependencies will be installed manually.
- [ ] `opencode --version` returns a version string.
- [ ] No secrets were printed in output.

## Rollback Instructions

If the user wants to revert:

1. Identify the latest backup directory under `~/.config/opencode/backups/`.
2. Restore the backed-up `opencode.json`, `prompts/`, `instructions/`, `commands/`, `plugins/`, `skills/`, and package files to `~/.config/opencode/`.
3. Do **not** restore `auth.json`.

Example:

```bash
BACKUP_DIR="$(ls -d ~/.config/opencode/backups/* | tail -1)"
cp -r "${BACKUP_DIR}"/* ~/.config/opencode/
```

## Notes

- The installer does **not** handle provider authentication. The user must run `opencode providers list` and complete the login flow manually.
- The installer may run `npm install --prefix ~/.config/opencode` to install npm-based plugins.
- The installer validates JSON syntax if `python3` is available.
- Restart opencode after installation so the new configuration loads.
