# Opencode Agent Workflow

Version-controlled [opencode](https://opencode.ai/) config, prompts, instructions, plugins, and skills.

## Install

```bash
git clone git@github.com:daussho-astro/opencode-agent-workflow.git
cd opencode-agent-workflow
./install.sh --dry-run
./install.sh
```

Installer never overwrites existing files by default. When `~/.config/opencode/opencode.json` exists, it saves repo config as `~/.config/opencode/opencode.workflow-template.json` and installs only missing active supporting files. Legacy `general-lite`, `reviewer-lite`, and `subagent-policy.ts` backups remain repository-only.

Flags:

- `--dry-run` — show planned actions.
- `--yes` — skip confirmation; does not overwrite files.
- `--overwrite` — replace existing managed files after timestamped backup under `~/.config/opencode/backups/`.

Restart opencode after installation. Config loads once per session.

## Requirements

- `opencode`, `git`, and `npm` in `PATH`.
- `rtk` 0.23.0+ in `PATH` for command rewriting. Workflow still works without it.
- Provider authentication completed separately. This repo stores no credentials.

## Configuration

Runtime source: `~/.config/opencode/`.

This repository: reviewed backup and installer source. Refresh backup from global config; do not copy repository files to global config except through `./install.sh`. See [AGENTS.md](AGENTS.md).

Active agents:

| Agent | Model | Role |
|---|---|---|
| `@orchestrator` | `openai/gpt-5.6-luna` | Own normal edits, commands, delegation, final synthesis |
| `@general` | `opencode-go/deepseek-v4-flash` | Complex or risky implementation |
| `@explore` | `opencode-go/deepseek-v4-flash` | Codebase discovery |
| `@scout` | `opencode-go/deepseek-v4-flash` | External research |
| `@planner` | `openai/gpt-5.6-luna` | Patch plans and scope clarification |
| `@reviewer` | `openai/gpt-5.6-terra` | Working-tree review |
| `@frontend-designer` | `opencode-go/deepseek-v4-flash` | Product UI implementation |
| `@ui-reviewer` | `openai/gpt-5.6-terra` | UI/UX review |

Agent permissions define tool access. `permission.edit` controls file changes; `permission.write` is not an opencode permission.

Plugins load from `opencode.json` and `plugins/`. Skills include `graphify`, `gh-stack`, `handover-load`, `handover-write`, and `verification-planning`.

## Validate

```bash
python3 -m json.tool opencode.json > /dev/null
git diff --check
opencode --version
```

After installation:

```bash
python3 -m json.tool ~/.config/opencode/opencode.json > /dev/null
opencode providers list
```

## Security

Do not commit `.env`, `auth.json`, API keys, or provider credentials. Do not inspect `~/.local/share/opencode/auth.json` while installing or syncing.

## Layout

```text
opencode-agent-workflow/
├── opencode.json
├── install.sh
├── AGENTS.md
├── AGENT_INSTALL.md
├── instructions/
├── prompts/
├── commands/
├── plugins/
├── skills/
├── package.json
└── package-lock.json
```
