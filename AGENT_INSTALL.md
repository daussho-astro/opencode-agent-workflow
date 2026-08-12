# Agent Install Guide

## Objective

Install this workflow into `~/.config/opencode` with `install.sh`.

Installer handles `opencode.json`, prompts, instructions, commands, plugins, skills, and npm dependencies. It never handles provider credentials.

## Safety Rules

- Do not read, print, or commit secrets.
- Do not inspect `~/.local/share/opencode/auth.json`.
- Do not use `--overwrite` without explicit user approval.
- Run dry run first.
- Ensure `rtk` 0.23.0+ is in `PATH` when command rewriting is wanted; `plugins/rtk.ts` disables itself when absent.
- Existing `~/.config/opencode/opencode.json` remains unchanged without `--overwrite`; installer creates `opencode.workflow-template.json` instead.

## Commands

```bash
git clone git@github.com:daussho-astro/opencode-agent-workflow.git
cd opencode-agent-workflow
./install.sh --dry-run
./install.sh
```

Flags:

- `--dry-run` — show planned actions only.
- `--yes` — skip prompt for non-overwrite install.
- `--overwrite` — replace existing managed files after backup. Requires explicit user approval.

## Validate

```bash
python3 -m json.tool ~/.config/opencode/opencode.json > /dev/null
opencode --version
```

Confirm installed or intentionally skipped paths under:

```text
~/.config/opencode/
├── opencode.json
├── prompts/
├── instructions/
├── commands/
├── plugins/
└── skills/
```

Run `opencode providers list` for provider authentication. Restart opencode after installation; config-time files load only on startup.

## Rollback

`--overwrite` backups live under `~/.config/opencode/backups/<timestamp>/`. Restore only files intended for rollback. Never restore or copy `auth.json`.

```bash
BACKUP_DIR="$(ls -d ~/.config/opencode/backups/* | tail -1)"
cp -r "${BACKUP_DIR}"/* ~/.config/opencode/
```

## Backup Refresh

Repository backup refresh runs global-to-repo, not installer direction. Follow [AGENTS.md](AGENTS.md).
