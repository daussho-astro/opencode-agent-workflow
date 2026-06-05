#!/usr/bin/env bash
set -euo pipefail

# Install opencode workflow config from this repo into ~/.config/opencode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"

echo "==> Installing opencode workflow config"

# Ensure directories exist
mkdir -p "${CONFIG_DIR}/prompts"
mkdir -p "${CONFIG_DIR}/instructions"

# Copy main config
cp "${SCRIPT_DIR}/opencode.json" "${CONFIG_DIR}/opencode.json"

# Copy prompts
for f in "${SCRIPT_DIR}/prompts/"*.md; do
  cp "$f" "${CONFIG_DIR}/prompts/$(basename "$f")"
done

# Copy instructions
for f in "${SCRIPT_DIR}/instructions/"*.md; do
  cp "$f" "${CONFIG_DIR}/instructions/$(basename "$f")"
done

# Validate JSON
if command -v python3 &> /dev/null; then
  python3 -m json.tool "${CONFIG_DIR}/opencode.json" > /dev/null && echo "  JSON valid"
else
  echo "  (python3 not found, skipping JSON validation)"
fi

# Check opencode version
if command -v opencode &> /dev/null; then
  echo "  opencode version: $(opencode --version 2>/dev/null || echo 'unknown')"
else
  echo "  opencode CLI not found in PATH"
fi

echo "==> Install complete. Restart opencode to load changes."
