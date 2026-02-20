#!/bin/bash

# ==============================================================================
# PHASE 1: PRE-EXTRACT (Safety Checks & Backups)
# Executed by makeself BEFORE extraction.
# ==============================================================================

# Placeholder: Set by build script
NEW_TMUX_VERSION="${1:-0}"

# Makeself executes this script inside the target directory.
INSTALL_DIR="$(pwd)"
EXISTING_TMUX="$INSTALL_DIR/.local/bin/tmux"

# --- A. Tmux Policy Check ---

function check_tmux_running() {
    local bin="$1"
    # 1. Try standard execution
    if "$bin" list-sessions &> /dev/null; then return 0; fi
    # 2. Fallback: AppImage extract-and-run
    if "$bin" --appimage-extract-and-run list-sessions &> /dev/null; then return 0; fi
    return 1
}

function get_tmux_version() {
    local bin="$1"
    local output
    output=$("$bin" -V 2>/dev/null)
    if [[ -z "$output" ]]; then
        output=$("$bin" --appimage-extract-and-run -V 2>/dev/null)
    fi
    echo "$output" | awk '{print $2}'
}

if [[ -x "$EXISTING_TMUX" ]] && check_tmux_running "$EXISTING_TMUX"; then
    echo "[Pre-Install] Detected running Tmux sessions in $INSTALL_DIR..."
    RUNNING_VER=$(get_tmux_version "$EXISTING_TMUX")

    if [[ "$RUNNING_VER" == "$NEW_TMUX_VERSION" ]]; then
        echo "  Versions match ($RUNNING_VER). Performing lazy update strategy."
        mv "$EXISTING_TMUX" "${EXISTING_TMUX}.old"
    else
        echo -e "\n\033[0;31mError: Tmux version mismatch!\033[0m"
        echo "  Running version:    $RUNNING_VER"
        echo "  Installing version: $NEW_TMUX_VERSION"
        exit 1
    fi
fi

# --- B. Backups ---
# We must backup NOW because extraction will happen immediately after this script exits.
echo "[Pre-Install] Backing up configuration in $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

function backup() {
    file="$INSTALL_DIR/$1"
    if [[ -f "$file" ]]; then
        cp "$file" "$file~"
    fi
}

backup ".bashrc"
backup ".cshrc"
backup ".config/git/config"
backup ".config/opencode/opencode.json"
backup ".config/tmux/tmux.conf"
backup ".config/nvim/init.lua"

# --- C. Cleanup Old Artifacts ---
# These folders were overwritten by extraction, but we might want to prune
# stale files if the new structure is different.
echo "[Pre-Install] Cleaning up old artifacts in $INSTALL_DIR..."
rm -rf "$INSTALL_DIR/.local/share/personal-setup"
rm -rf "$INSTALL_DIR/.local/share/nvim/runtime"
rm -rf "$INSTALL_DIR/.local/lib/node_modules/npm/"
rm -rf "$INSTALL_DIR/.local/lib/node_modules/corepack/"
rm -rf "$INSTALL_DIR/.cache/opencode"
rm -rf "$INSTALL_DIR/.config/opencode/opencode-workflows"

if [[ -d "$INSTALL_DIR/.config/opencode" ]]; then
  find "$INSTALL_DIR/.config/opencode" -type l -lname '../opencode-workflows/*' -delete
fi

echo "[Pre-Install] Ready to extract."

exit 0
