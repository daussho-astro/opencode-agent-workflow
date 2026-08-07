# Agent Instructions

## Sync Repository Backup

Global `~/.config/opencode/` is runtime source. This repository is reviewed backup and installer source. Review differences before copying. Never reverse sync direction during backup refresh.

Do not read, print, or commit credentials, especially `~/.local/share/opencode/auth.json`.

### Compare

```bash
diff -qr ~/.config/opencode . \
  -x node_modules -x .git -x backups -x .DS_Store \
  -x dcp-prompts -x dcp.jsonc -x .ponytail-active \
  -x .gitignore -x AGENTS.md -x AGENT_INSTALL.md -x README.md \
  -x install.sh -x .opencode -x subagent-policy.ts \
  -x general-lite-guideline.md -x reviewer-lite-guideline.md
```

Review changed files before copying. Repo-only `AGENTS.md`, `AGENT_INSTALL.md`, `README.md`, `install.sh`, `.opencode/`, and legacy backup files are not global runtime config.

### Copy

Copy global runtime files into matching repository paths. Use `cp`; do not re-write synced files.

```bash
cp ~/.config/opencode/opencode.json opencode.json
cp ~/.config/opencode/prompts/*.md prompts/
cp ~/.config/opencode/instructions/*.md instructions/
cp ~/.config/opencode/plugins/* plugins/
cp -R ~/.config/opencode/skills/* skills/
```

Copy only regular config assets. Exclude machine-local runtime state such as `node_modules/`, `backups/`, `dcp-prompts/`, `dcp.jsonc`, `.ponytail-active`, and credentials.

### Validate

```bash
python3 -m json.tool opencode.json > /dev/null
git diff --check
git status --short
```

Known upstream whitespace in a synced file must remain unchanged unless global source fixes it. Validate other paths separately when needed:

```bash
git diff --check -- . ':(exclude)skills/graphify/SKILL.md'
```

Commit only reviewed config assets. Do not commit `.opencode/` plans or reviews unless explicitly requested.
