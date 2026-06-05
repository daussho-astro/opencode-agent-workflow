# Opencode Agent Workflow

Reproducible, version-controlled configuration for [opencode](https://opencode.ai/) multi-agent workflows.

## Purpose

This repository stores the full opencode agent configuration — models, prompts, instructions, and orchestration rules — so the workflow can be replicated across machines, shared with teammates, and restored after resets.

## Workflow Diagram

```
User Request
    |
    v
+-----------+     reads/files    +---------+
|           | -----------------> | @explore |
|           |     bash/tests     | (cheap)  |
|  Primary  | <----------------- +---------+
|   Agent   |
| (@orchestrator) |  webfetch/search  +---------+
|   gpt-5.5 | <----------------- |  @scout  |
|           |    (fast/cheap)    | (cheap)  |
+-----------+                    +---------+
    |
    | delegates implementation / review
    v
+-----------+   +-------------+   +---------+
|  @general |   | @general-lite | | @reviewer|
|  gpt-5.5  |   |  kimi-k2.6   | |opus-4.8 |
|  (strong) |   |  (low-cost)  | |(strong)  |
+-----------+   +-------------+   +---------+
    |
    v
+-----------+   +-------------+
| @planner  |   |  @executor   |
|  gpt-5.5  |   |deepseek-v4  |
| (TRD/plan)|   |  (bash)     |
+-----------+   +-------------+
```

## Agent / Model Table

| Agent | Model | Mode | Role |
|-------|-------|------|------|
| `@orchestrator` | `github-copilot/gpt-5.5` | primary | Plan, delegate, synthesize |
| `@general` | `github-copilot/gpt-5.5` | subagent | Multi-step implementation, edits, coordination |
| `@general-lite` | `opencode-go/kimi-k2.6` | subagent | Low-cost simple edits, docs, config fixes |
| `@planner` | `github-copilot/gpt-5.5` | subagent | BRD → TRD + task breakdown |
| `@reviewer` | `github-copilot/claude-opus-4.8` | subagent | Medium/high-risk review |
| `@reviewer-lite` | `opencode-go/mimo-v2.5-pro` | subagent | Quick low-risk review |
| `@explore` | `opencode-go/deepseek-v4-flash` | subagent | Fast codebase exploration |
| `@executor` | `opencode-go/deepseek-v4-flash` | subagent | Bash commands, tests, builds |
| `@scout` | `opencode-go/deepseek-v4-flash` | subagent | Web fetch + search |

## Install

```bash
# 1. Clone or copy this repo
cd opencode-agent-workflow

# 2. Run the install script
bash install.sh
```

The script will:
- Copy `opencode.json` to `~/.config/opencode/opencode.json`
- Copy all prompt files to `~/.config/opencode/prompts/`
- Copy all instruction files to `~/.config/opencode/instructions/`
- Validate JSON syntax
- Check opencode version

## Validation Commands

After install, verify the configuration is active:

```bash
# Check opencode version
opencode --version

# Validate JSON
python3 -m json.tool ~/.config/opencode/opencode.json > /dev/null && echo "JSON valid"

# List loaded agents (inside an opencode session)
# Ask: "list my agents"
```

## Provider / Auth Notes

- **You must authenticate providers yourself.** This repo does not contain any credentials.
- Supported providers in this config: `github-copilot`, `opencode-go`.
- To authenticate, run:
  ```bash
  opencode provider add github-copilot
  opencode provider add opencode-go
  ```
- If you use a custom provider (e.g., the `9router` local endpoint in `opencode.json`), ensure it is reachable on your network.

## No-Secrets Warning

- **Do not commit `.env`, `auth.json`, or any API keys.**
- This repo intentionally excludes `~/.local/share/opencode/auth.json`.
- If you add custom provider credentials to `opencode.json`, keep them out of version control.

## Restart Opencode Reminder

After running `install.sh`, **restart your opencode session** (or start a new one) so the updated configuration is loaded.

```bash
# Exit current session, then:
opencode
```

## Directory Layout

```
opencode-agent-workflow/
├── opencode.json              # Main config (agents, models, permissions)
├── install.sh                 # One-command install script
├── README.md                  # This file
├── .gitignore                 # Excludes secrets/backups
├── prompts/
│   ├── orchestrator-guideline.md
│   ├── general-guideline.md
│   ├── explore-guideline.md
│   ├── executor-guideline.md
│   ├── scout-guideline.md
│   ├── reviewer-guideline.md
│   └── planner-guideline.md
└── instructions/
    ├── parallel-reads.md
    ├── general-guideline.md
    └── coding-guideline.md
```
