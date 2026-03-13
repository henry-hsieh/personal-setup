#!/bin/bash

# ==============================================================================
# PHASE 3: POST-EXTRACT (Cleanup & Config)
# Executed by makeself AFTER extraction.
# ==============================================================================

INSTALL_DIR="$(pwd)"

echo "[Post-Install] Configuring environment..."

# --- A. Reset Neovim Plugins ---
if [[ -d "$INSTALL_DIR/.local/share/nvim/lazy" ]]; then
    echo "[Post-Install] Resetting Neovim plugins..."
    cd "$INSTALL_DIR/.local/share/nvim/lazy" || exit
    for d in */ ; do
      if [[ -d "$d/.git" || -f "$d/.git" ]]; then
          pushd "$d" > /dev/null
          git reset --hard HEAD > /dev/null
          git clean -fdq > /dev/null
          popd > /dev/null
      fi
    done
    # Return to root for consistency
    cd "$INSTALL_DIR" || exit
fi

# --- B. Restore Git Identity ---
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

echo -e "\n===================================================================="
echo -e "Installation completed successfully!"
echo -e "Please refer to following link for post-installation guides:"
echo -e "https://github.com/henry-hsieh/personal-setup/wiki/Environment-Setup"
echo -e "===================================================================="
