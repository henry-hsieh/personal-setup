#!/bin/bash

# ==============================================================================
# PHASE 3: POST-EXTRACT (Cleanup & Config)
# Executed by makeself AFTER extraction.
# ==============================================================================

INSTALL_DIR="$(pwd)"

echo "[Post-Install] Configuring environment..."

function reset_git_repos() {
  for d in */ ; do
    if [[ -d "$d/.git" || -f "$d/.git" ]]; then
      pushd "$d" > /dev/null || exit 1
      git reset --hard HEAD > /dev/null || exit 1
      git clean -fdq > /dev/null || exit 1
      popd > /dev/null || exit 1
    fi
  done
}

# --- Reset Neovim Plugins ---
if [[ -d "$INSTALL_DIR/.local/share/nvim/lazy" ]]; then
    echo "[Post-Install] Resetting Neovim plugins..."
    cd "$INSTALL_DIR/.local/share/nvim/lazy" || exit
    reset_git_repos
    # Return to root for consistency
    cd "$INSTALL_DIR" || exit
fi

# --- Reset Tinty Plugins ---
if [[ -d "$INSTALL_DIR/.local/share/tinted-theming/tinty/repos" ]]; then
    echo "[Post-Install] Resetting Tinty plugins..."
    cd "$INSTALL_DIR/.local/share/tinted-theming/tinty/repos" || exit
    reset_git_repos
    # Return to root for consistency
    cd "$INSTALL_DIR" || exit
fi

# --- Restore Git Identity ---
GIT_CONFIG_BACKUP="$INSTALL_DIR/.config/git/config~"
TARGET_GIT_CONFIG="$INSTALL_DIR/.config/git/config"

if [[ -f "$GIT_CONFIG_BACKUP" ]]; then
    OLD_NAME=$(git config --file "$GIT_CONFIG_BACKUP" user.name)
    OLD_EMAIL=$(git config --file "$GIT_CONFIG_BACKUP" user.email)

    if [[ ! -z "$OLD_NAME" ]]; then
        git config --file "$TARGET_GIT_CONFIG" user.name "$OLD_NAME"
    fi
    if [[ ! -z "$OLD_EMAIL" ]]; then
        git config --file "$TARGET_GIT_CONFIG" user.email "$OLD_EMAIL"
    fi
fi

# --- Configure Magic Context ---
MC_SOURCE="$INSTALL_DIR/.config/personal-setup/magic-context.jsonc"
MC_TARGET="$INSTALL_DIR/.config/cortexkit/magic-context.jsonc"
if [[ -f "$MC_SOURCE" ]]; then
    echo "[Post-Install] Configuring Magic Context..."

    # Mirror the shell profile's OPENCODE_CONFIG override when present
    CUSTOM_CONFIG="$INSTALL_DIR/.config/opencode/custom.json"
    if [[ -f "$CUSTOM_CONFIG" ]]; then
        export OPENCODE_CONFIG="$CUSTOM_CONFIG"
    fi

    # Pick the first available model, preferring the target's custom config
    FIRST_MODEL=""
    if [[ -n "${OPENCODE_CONFIG:-}" ]]; then
        FIRST_MODEL=$("$INSTALL_DIR/.local/bin/yq" -r '
            .provider | to_entries
            | map(select((.value | has("models")) and ((.value.models | keys | length) > 0)))
            | map(.key + "/" + (.value.models | keys | .[0]))
            | .[0] // ""
        ' "$OPENCODE_CONFIG" 2>/dev/null)
    fi
    if [[ -z "$FIRST_MODEL" ]]; then
        FIRST_MODEL=$(HOME="$INSTALL_DIR" XDG_CONFIG_HOME="$INSTALL_DIR/.config" XDG_DATA_HOME="$INSTALL_DIR/.data" XDG_CACHE_HOME="$INSTALL_DIR/.cache" OPENCODE_CONFIG_DIR="$INSTALL_DIR/.config/opencode" "$INSTALL_DIR/.local/bin/opencode" models --pure 2>/dev/null | grep -v '^opencode/' | head -n1)
    fi
    if [[ -z "$FIRST_MODEL" ]]; then
        FIRST_MODEL=$(HOME="$INSTALL_DIR" XDG_CONFIG_HOME="$INSTALL_DIR/.config" XDG_DATA_HOME="$INSTALL_DIR/.data" XDG_CACHE_HOME="$INSTALL_DIR/.cache" OPENCODE_CONFIG_DIR="$INSTALL_DIR/.config/opencode" "$INSTALL_DIR/.local/bin/opencode" models --pure 2>/dev/null | head -n1)
    fi

    if [[ -n "$FIRST_MODEL" ]]; then
        for agent in historian dreamer sidekick; do
            CURRENT=$("$INSTALL_DIR/.local/bin/yq" -r ".${agent}.model // \"\"" "$MC_SOURCE")
            if [[ -z "$CURRENT" ]]; then
                "$INSTALL_DIR/.local/bin/yq" -o=json -i ".${agent}.model = \"${FIRST_MODEL}\"" "$MC_SOURCE"
            fi
        done
    fi

    # Symlink into magic-context's user config path, only if absent
    if [[ ! -e "$MC_TARGET" && ! -L "$MC_TARGET" ]]; then
        mkdir -p "$(dirname "$MC_TARGET")"
        ln -s ../personal-setup/magic-context.jsonc "$MC_TARGET"
    fi
fi

# --- Configure AFT ---
AFT_SOURCE="$INSTALL_DIR/.config/personal-setup/aft.jsonc"
AFT_TARGET="$INSTALL_DIR/.config/cortexkit/aft.jsonc"
if [[ -f "$AFT_SOURCE" ]]; then
    echo "[Post-Install] Configuring AFT..."

    # Symlink into AFT's user config path, only if absent
    if [[ ! -e "$AFT_TARGET" && ! -L "$AFT_TARGET" ]]; then
        mkdir -p "$(dirname "$AFT_TARGET")"
        ln -s ../personal-setup/aft.jsonc "$AFT_TARGET"
    fi
fi

echo -e "\n===================================================================="
echo -e "Installation completed successfully!"
echo -e "Please refer to following link for post-installation guides:"
echo -e "https://github.com/henry-hsieh/personal-setup/wiki/Environment-Setup"
echo -e "===================================================================="
