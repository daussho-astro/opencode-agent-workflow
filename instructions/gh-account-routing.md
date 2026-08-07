# GitHub Account Routing

- Always route GitHub CLI commands through the correct account alias.
- Check the git remote URL to determine the account.
- If remote is `https://github.com/astronautsid/*` → use `ghwork`.
- Otherwise → use `ghpriv`.
- Prefix every `gh` command with the correct alias: `rtk ghwork <cmd>` or `rtk ghpriv <cmd>`.
- Never use raw `gh` directly.
- Apply to all GitHub operations: pr create, push, status, issue, release, etc.
