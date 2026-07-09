#!/usr/bin/env bash
set -eo pipefail

# Safe installer for opencode-agent-workflow
# Default: never overwrite existing files.
# Use --overwrite only if you accept replacing existing config.

DRY_RUN=false
YES=false
OVERWRITE=false

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [--yes] [--overwrite] [--help]

Options:
  --dry-run    Print actions without copying files
  --yes        Non-interactive proceed for safe actions (does NOT imply overwrite)
  --overwrite  Explicitly overwrite existing files (timestamped backup created first)
  --help       Show this message and exit
EOF
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --yes) YES=true ;;
    --overwrite) OVERWRITE=true ;;
    --help) usage ;;
    *)
      echo "Unknown option: $arg" >&2
      usage
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${CONFIG_DIR}/backups/${TIMESTAMP}"

PROMPT_SRC_DIR="${SCRIPT_DIR}/prompts"
INSTR_SRC_DIR="${SCRIPT_DIR}/instructions"
COMMAND_SRC_DIR="${SCRIPT_DIR}/commands"
PLUGIN_SRC_DIR="${SCRIPT_DIR}/plugins"
SKILL_SRC_DIR="${SCRIPT_DIR}/skills"

# Helper functions
log() { echo "==> $*"; }
info() { echo "    $*"; }
warn() { echo "    WARN: $*" >&2; }
error() { echo "    ERROR: $*" >&2; }

# Validate repo JSON first
if [ -f "${SCRIPT_DIR}/opencode.json" ]; then
  if command -v python3 >/dev/null 2>&1; then
    if ! python3 -m json.tool "${SCRIPT_DIR}/opencode.json" >/dev/null 2>&1; then
      error "repo opencode.json is invalid JSON. Aborting."
      exit 1
    fi
  fi
fi

# Counters/summary
installed=()
skipped=()
backed_up=()

# Determine where opencode.json should go
install_json=false
install_json_path=""
template_json_path="${CONFIG_DIR}/opencode.workflow-template.json"

if [ -f "${CONFIG_DIR}/opencode.json" ]; then
  if [ "$OVERWRITE" = true ]; then
    install_json=true
    install_json_path="${CONFIG_DIR}/opencode.json"
  else
    # Do not overwrite existing opencode.json
    if [ -f "$template_json_path" ]; then
      skipped+=("$template_json_path (template already exists)")
    else
      install_json=true
      install_json_path="$template_json_path"
    fi
  fi
else
  install_json=true
  install_json_path="${CONFIG_DIR}/opencode.json"
fi

# Prompts and instructions
prompts_to_install=()
prompts_to_skip=()
instructions_to_install=()
instructions_to_skip=()
commands_to_install=()
commands_to_skip=()
plugins_to_install=()
plugins_to_skip=()
skills_to_install=()
skills_to_skip=()
packages_to_install=()
packages_to_skip=()

if [ -d "${PROMPT_SRC_DIR}" ]; then
  for src in "${PROMPT_SRC_DIR}"/*.md; do
    [ -e "$src" ] || continue
    name=$(basename "$src")
    dest="${CONFIG_DIR}/prompts/${name}"
    if [ -e "$dest" ]; then
      if [ "$OVERWRITE" = true ]; then
        prompts_to_install+=("$src")
      else
        prompts_to_skip+=("$dest")
      fi
    else
      prompts_to_install+=("$src")
    fi
  done
fi

if [ -d "${INSTR_SRC_DIR}" ]; then
  for src in "${INSTR_SRC_DIR}"/*.md; do
    [ -e "$src" ] || continue
    name=$(basename "$src")
    dest="${CONFIG_DIR}/instructions/${name}"
    if [ -e "$dest" ]; then
      if [ "$OVERWRITE" = true ]; then
        instructions_to_install+=("$src")
      else
        instructions_to_skip+=("$dest")
      fi
    else
      instructions_to_install+=("$src")
    fi
  done
fi

if [ -d "${COMMAND_SRC_DIR}" ]; then
  for src in "${COMMAND_SRC_DIR}"/*.md; do
    [ -e "$src" ] || continue
    name=$(basename "$src")
    dest="${CONFIG_DIR}/commands/${name}"
    if [ -e "$dest" ]; then
      if [ "$OVERWRITE" = true ]; then
        commands_to_install+=("$src")
      else
        commands_to_skip+=("$dest")
      fi
    else
      commands_to_install+=("$src")
    fi
  done
fi

if [ -d "${PLUGIN_SRC_DIR}" ]; then
  for src in "${PLUGIN_SRC_DIR}"/*; do
    [ -f "$src" ] || continue
    name=$(basename "$src")
    dest="${CONFIG_DIR}/plugins/${name}"
    if [ -e "$dest" ]; then
      if [ "$OVERWRITE" = true ]; then
        plugins_to_install+=("$src")
      else
        plugins_to_skip+=("$dest")
      fi
    else
      plugins_to_install+=("$src")
    fi
  done
fi

if [ -d "${SKILL_SRC_DIR}" ]; then
  while IFS= read -r src; do
    rel="${src#${SKILL_SRC_DIR}/}"
    dest="${CONFIG_DIR}/skills/${rel}"
    if [ -e "$dest" ]; then
      if [ "$OVERWRITE" = true ]; then
        skills_to_install+=("$src")
      else
        skills_to_skip+=("$dest")
      fi
    else
      skills_to_install+=("$src")
    fi
  done < <(find "${SKILL_SRC_DIR}" -type f)
fi

for src in "${SCRIPT_DIR}/package.json" "${SCRIPT_DIR}/package-lock.json"; do
  [ -e "$src" ] || continue
  name=$(basename "$src")
  dest="${CONFIG_DIR}/${name}"
  if [ -e "$dest" ]; then
    if [ "$OVERWRITE" = true ]; then
      packages_to_install+=("$src")
    else
      packages_to_skip+=("$dest")
    fi
  else
    packages_to_install+=("$src")
  fi
done

# Show plan
log "Opencode Agent Workflow Installer"
echo ""
echo "Source: ${SCRIPT_DIR}"
echo "Target: ${CONFIG_DIR}"
echo ""
echo "Planned actions:"
if [ "$install_json" = true ]; then
  echo "  INSTALL  opencode.json -> ${install_json_path}"
else
  echo "  SKIP     ${CONFIG_DIR}/opencode.json (exists, overwrite not enabled)"
  if [ -f "$template_json_path" ]; then
    echo "  SKIP     ${template_json_path} (also exists)"
  fi
fi

for src in "${prompts_to_install[@]}"; do
  echo "  INSTALL  prompts/$(basename "$src")"
done
for dest in "${prompts_to_skip[@]}"; do
  echo "  SKIP     ${dest} (exists)"
done

for src in "${instructions_to_install[@]}"; do
  echo "  INSTALL  instructions/$(basename "$src")"
done
for dest in "${instructions_to_skip[@]}"; do
  echo "  SKIP     ${dest} (exists)"
done

for src in "${commands_to_install[@]}"; do
  echo "  INSTALL  commands/$(basename "$src")"
done
for dest in "${commands_to_skip[@]}"; do
  echo "  SKIP     ${dest} (exists)"
done

for src in "${plugins_to_install[@]}"; do
  echo "  INSTALL  plugins/$(basename "$src")"
done
for dest in "${plugins_to_skip[@]}"; do
  echo "  SKIP     ${dest} (exists)"
done

for src in "${skills_to_install[@]}"; do
  rel="${src#${SKILL_SRC_DIR}/}"
  echo "  INSTALL  skills/${rel}"
done
for dest in "${skills_to_skip[@]}"; do
  echo "  SKIP     ${dest} (exists)"
done

for src in "${packages_to_install[@]}"; do
  echo "  INSTALL  $(basename "$src")"
done
for dest in "${packages_to_skip[@]}"; do
  echo "  SKIP     ${dest} (exists)"
done

if [ -f "${SCRIPT_DIR}/package.json" ]; then
  if command -v npm >/dev/null 2>&1; then
    echo "  RUN      npm install --prefix ${CONFIG_DIR}"
  else
    echo "  SKIP     npm install (npm not found)"
  fi
fi

if [ "$OVERWRITE" = true ]; then
  echo ""
  echo "Overwrite mode enabled. Existing files will be backed up to:"
  echo "  ${BACKUP_DIR}"
fi

if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "[DRY RUN] No changes made."
  exit 0
fi

# Confirmation
if [ "$YES" = false ]; then
  echo ""
  if [ "$OVERWRITE" = true ]; then
    read -r -p "Proceed with installation (overwrite enabled)? [y/N] " response
  else
    read -r -p "Proceed with installation? [y/N] " response
  fi
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) echo "Installation cancelled."; exit 1 ;;
  esac
fi

# Determine if backup is needed
need_backup=false
if [ "$OVERWRITE" = true ]; then
  if [ "$install_json_path" = "${CONFIG_DIR}/opencode.json" ] && [ -f "${CONFIG_DIR}/opencode.json" ]; then
    need_backup=true
  fi
  for src in "${prompts_to_install[@]}"; do
    dest="${CONFIG_DIR}/prompts/$(basename "$src")"
    [ -e "$dest" ] && need_backup=true && break
  done
  for src in "${instructions_to_install[@]}"; do
    dest="${CONFIG_DIR}/instructions/$(basename "$src")"
    [ -e "$dest" ] && need_backup=true && break
  done
  for src in "${commands_to_install[@]}"; do
    dest="${CONFIG_DIR}/commands/$(basename "$src")"
    [ -e "$dest" ] && need_backup=true && break
  done
  for src in "${plugins_to_install[@]}"; do
    dest="${CONFIG_DIR}/plugins/$(basename "$src")"
    [ -e "$dest" ] && need_backup=true && break
  done
  for src in "${skills_to_install[@]}"; do
    rel="${src#${SKILL_SRC_DIR}/}"
    dest="${CONFIG_DIR}/skills/${rel}"
    [ -e "$dest" ] && need_backup=true && break
  done
  for src in "${packages_to_install[@]}"; do
    dest="${CONFIG_DIR}/$(basename "$src")"
    [ -e "$dest" ] && need_backup=true && break
  done
fi

if [ "$need_backup" = true ]; then
  log "Creating backup at ${BACKUP_DIR}"
  mkdir -p "$BACKUP_DIR"
fi

# Backup helper
backup_if_exists() {
  local file="$1"
  if [ -e "$file" ]; then
    local rel="${file#${CONFIG_DIR}/}"
    local dir="${BACKUP_DIR}/$(dirname "$rel")"
    mkdir -p "$dir"
    cp -a "$file" "$dir/"
    backed_up+=("$rel")
  fi
}

# Install opencode.json
mkdir -p "$CONFIG_DIR"

if [ "$install_json" = true ]; then
  if [ "$OVERWRITE" = true ] && [ "$install_json_path" = "${CONFIG_DIR}/opencode.json" ] && [ -f "${CONFIG_DIR}/opencode.json" ]; then
    backup_if_exists "${CONFIG_DIR}/opencode.json"
  fi
  cp "${SCRIPT_DIR}/opencode.json" "$install_json_path"
  installed+=("$install_json_path")
else
  skipped+=("${CONFIG_DIR}/opencode.json")
  if [ -f "$template_json_path" ]; then
    skipped+=("$template_json_path")
  fi
fi

# Install prompts
if [ ${#prompts_to_install[@]} -gt 0 ]; then
  mkdir -p "${CONFIG_DIR}/prompts"
  for src in "${prompts_to_install[@]}"; do
    dest="${CONFIG_DIR}/prompts/$(basename "$src")"
    if [ "$OVERWRITE" = true ] && [ -e "$dest" ]; then
      backup_if_exists "$dest"
    fi
    cp "$src" "$dest"
    installed+=("$dest")
  done
fi

# Install instructions
if [ ${#instructions_to_install[@]} -gt 0 ]; then
  mkdir -p "${CONFIG_DIR}/instructions"
  for src in "${instructions_to_install[@]}"; do
    dest="${CONFIG_DIR}/instructions/$(basename "$src")"
    if [ "$OVERWRITE" = true ] && [ -e "$dest" ]; then
      backup_if_exists "$dest"
    fi
    cp "$src" "$dest"
    installed+=("$dest")
  done
fi

# Install commands
if [ ${#commands_to_install[@]} -gt 0 ]; then
  mkdir -p "${CONFIG_DIR}/commands"
  for src in "${commands_to_install[@]}"; do
    dest="${CONFIG_DIR}/commands/$(basename "$src")"
    if [ "$OVERWRITE" = true ] && [ -e "$dest" ]; then
      backup_if_exists "$dest"
    fi
    cp "$src" "$dest"
    installed+=("$dest")
  done
fi

# Install plugins
if [ ${#plugins_to_install[@]} -gt 0 ]; then
  mkdir -p "${CONFIG_DIR}/plugins"
  for src in "${plugins_to_install[@]}"; do
    dest="${CONFIG_DIR}/plugins/$(basename "$src")"
    if [ "$OVERWRITE" = true ] && [ -e "$dest" ]; then
      backup_if_exists "$dest"
    fi
    cp "$src" "$dest"
    installed+=("$dest")
  done
fi

# Install skills
if [ ${#skills_to_install[@]} -gt 0 ]; then
  for src in "${skills_to_install[@]}"; do
    rel="${src#${SKILL_SRC_DIR}/}"
    dest="${CONFIG_DIR}/skills/${rel}"
    if [ "$OVERWRITE" = true ] && [ -e "$dest" ]; then
      backup_if_exists "$dest"
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    installed+=("$dest")
  done
fi

# Install package manifest/lock for npm-based plugins
if [ ${#packages_to_install[@]} -gt 0 ]; then
  for src in "${packages_to_install[@]}"; do
    dest="${CONFIG_DIR}/$(basename "$src")"
    if [ "$OVERWRITE" = true ] && [ -e "$dest" ]; then
      backup_if_exists "$dest"
    fi
    cp "$src" "$dest"
    installed+=("$dest")
  done
fi

if [ -f "${CONFIG_DIR}/package.json" ]; then
  log "Installing npm dependencies"
  if command -v npm >/dev/null 2>&1; then
    npm install --prefix "${CONFIG_DIR}"
  else
    warn "npm command not found; install dependencies manually in ${CONFIG_DIR}"
  fi
fi

# Validate JSON if we installed opencode.json
if [ "$install_json" = true ] && [ -f "$install_json_path" ]; then
  log "Validating configuration"
  if command -v python3 >/dev/null 2>&1; then
    if python3 -m json.tool "$install_json_path" >/dev/null 2>&1; then
      info "JSON valid"
    else
      error "JSON validation failed for installed opencode.json"
      exit 1
    fi
  else
    info "python3 not found, skipping JSON validation"
  fi
fi

# Check opencode
log "Checking opencode CLI"
if command -v opencode >/dev/null 2>&1; then
  version="$(opencode --version 2>/dev/null || echo 'unknown')"
  info "opencode version: ${version}"
else
  warn "opencode command not found in PATH"
  info "Install opencode before using this workflow."
fi

# Summary
echo ""
log "Installation Summary"
echo ""

if [ ${#installed[@]} -gt 0 ]; then
  echo "Installed:"
  for f in "${installed[@]}"; do
    info "$f"
  done
  echo ""
fi

if [ ${#skipped[@]} -gt 0 ]; then
  echo "Skipped (existing):"
  for f in "${skipped[@]}"; do
    info "$f"
  done
  echo ""
fi

if [ ${#backed_up[@]} -gt 0 ]; then
  echo "Backed up (before overwrite):"
  for f in "${backed_up[@]}"; do
    info "${BACKUP_DIR}/${f}"
  done
  echo ""
fi

if [ -f "${CONFIG_DIR}/opencode.json" ] && [ "$install_json_path" = "$template_json_path" ]; then
  echo "Next steps:"
  echo "  - You already have ~/.config/opencode/opencode.json."
  echo "  - The repo config was saved as:"
  echo "      ${template_json_path}"
  echo "  - Merge agent/default_agent/instructions into your existing config manually,"
  echo "    or run with --overwrite if you accept replacing your existing config."
  echo ""
elif [ ! -f "${CONFIG_DIR}/opencode.json" ] && [ "$install_json_path" = "${CONFIG_DIR}/opencode.json" ]; then
  echo "Next steps:"
  echo "  - Authenticate providers:"
  echo "      opencode providers list"
  echo "  - Restart opencode to load the new configuration."
  echo ""
fi

if [ "$OVERWRITE" = true ] && [ ${#backed_up[@]} -gt 0 ]; then
  echo "Rollback: restore from backup if needed:"
  echo "  cp -r ${BACKUP_DIR}/* ~/.config/opencode/"
  echo ""
fi
