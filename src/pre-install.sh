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
backup ".config/opencode/opencode.jsonc"
backup ".config/tmux/tmux.conf"
backup ".config/nvim/init.lua"

# --- C. Cleanup Old Artifacts ---
# These folders were overwritten by extraction, but we might want to prune
# stale files if the new structure is different.
echo "[Pre-Install] Cleaning up old artifacts in $INSTALL_DIR..."

# Remove only byte-for-byte matches for bridges shipped by the previous
# OpenCode package. Preserve locally edited files and other user commands.
while read -r expected relative; do
  artifact="$INSTALL_DIR/.config/opencode/$relative"
  if [[ -f "$artifact" && ! -L "$artifact" ]]; then
    actual=$(sha256sum "$artifact")
    if [[ "${actual%% *}" == "$expected" ]]; then
      rm -- "$artifact"
    fi
  fi
done <<'LEGACY_OPENCODE_ARTIFACTS'
be4d31ab1d76172bc0922557088ef34719372b2006e168a4c319730e07f6b16c commands/goal.md
d61de83fad6e66a125fad767b416ea07c3a1dae2f6c62717d3772e85ddf5b5ac commands/loop-ask.md
df889498f8c61235d36757943ab4b55a87dddcd3e83584c909f3be16688f4f2f commands/loop-clear.md
7aeaab84c66134aea31b26fd5c1a973b040b8dbe353a110273caf55744e4f397 commands/loop-cmd.md
f2313725245d803fbdd4559ad8e7f54a3d26acd0736dc7456a5ec5f8f9a560d7 commands/loop-command.md
19e2a675e77566a6dab4db9f5363ef5de25be974170b3b372c5251643c2d574d commands/loop-compact.md
19e2a675e77566a6dab4db9f5363ef5de25be974170b3b372c5251643c2d574d commands/loop-dev.md
85dc70f805a4db0b6fa50f0fea1b22f60c16319073a07360841906481466c95d commands/loop-doctor.md
ee3c5d31aafe876122e617e95d63059ec4fe94995b4d4048a74a401c39527db3 commands/loop-export.md
02a2d76e3f11fe665db22715627263bbe46c8ff597de61d97f91ca4658d0c647 commands/loop-help.md
298e57d6194719539d9f296b7f0cfe5f1e6be02fde310bb75c92fd1ec31d1abf commands/loop-init.md
2cdd4157f814337aeb2b82cabb1959ce11228cab1121c4ea3dedd6d6be7e4587 commands/loop-logs.md
3651f4f0a88bde40c30872a689d0b6023906d0053a935e9b53f02b22c7b3d091 commands/loop-now.md
7f87db61ae4d5c34424e5fa3cc963fcdae983a7529db40664b2449f1ebc4df86 commands/loop-pause.md
19e2a675e77566a6dab4db9f5363ef5de25be974170b3b372c5251643c2d574d commands/loop-progress.md
c6ecbc0f64a64e7c0d681af383eb146d9129620a1f7038d42fb292685182ee7b commands/loop-prompt.md
19e2a675e77566a6dab4db9f5363ef5de25be974170b3b372c5251643c2d574d commands/loop-remove.md
ce1b895050812ccd8b7ef2f56d3ce966522069a488b3e89f8bf0358f01678ba6 commands/loop-resume.md
19e2a675e77566a6dab4db9f5363ef5de25be974170b3b372c5251643c2d574d commands/loop-safe-dev.md
7652b41412f6bd70a41faf2f2288b3f037cdcf6e8930624530532eda5c6ad49e commands/loop-shell.md
a69af2485a4543244aaabadde542d20b9d193881993b24f79cb93b90aecd2db4 commands/loop-status.md
5a91dc12c78ddeb745d6665c46fc5020f208b427291c71fbe586c938f5d42ba3 commands/loop-stop.md
19e2a675e77566a6dab4db9f5363ef5de25be974170b3b372c5251643c2d574d commands/loop-testfix.md
ee1380a2169d3b22b7f837a7189192b87089650d2b7d50c4b5e8b23bbb637038 commands/loop.md
46f3f0b137118657083656ad53d92e3f39b657638a1b7331167ab1f708e70414 agents/opencode-loop-local.md
0859ddb574427d9cb2457bb5eab44d1b9c200a7816e6034e4f62d638fcc6b847 plugins/opencode-loop.ts
a453b8e307221766246b68956125d368016dca898e1e88580fad9a6daeb5c44f plugins/wait/opencode-wait.ts
81479d21561880dab9976998d7d0bf016971a971cf84e55d9916ff1ee47e9fff plugins/pca/opencode-pca.ts
f548cc9db9c35f0561d47e56da3946f8560401a0524e03592608a9f08c8d1115 plugins/kata/kata.ts
8f5b769bd77ef88154282a69c36c61c369ff6d2285e2c4396dbd61f9fdc5f7cc tui.jsonc
1927d3bb7bb54cc558c694cd3e1a7cc64027742af82e2d5c04c4e8c5267a3e45 tui.jsonc
LEGACY_OPENCODE_ARTIFACTS

rm -rf "$INSTALL_DIR/.local/share/personal-setup"
rm -rf "$INSTALL_DIR/.local/share/nvim/runtime"
rm -rf "$INSTALL_DIR/.local/share/scripts/zoxide-b.csh"
rm -rf "$INSTALL_DIR/.local/lib/node_modules/npm/"
rm -rf "$INSTALL_DIR/.local/lib/node_modules/corepack/"
rm -rf "$INSTALL_DIR/.local/share/tinted-theming/tinty/repos/shell"
rm -rf "$INSTALL_DIR/.local/share/tinted-theming/tinty/repos/base16-shell"
rm -rf "$INSTALL_DIR/.config/opencode/opencode.json"
rm -rf "$INSTALL_DIR/.config/opencode/opencode.jsonc"
rm -rf "$INSTALL_DIR/.config/opencode/package.json"
rm -rf "$INSTALL_DIR/.config/opencode/package-lock.json"
rm -rf "$INSTALL_DIR/.config/opencode/bun.lock"
rm -rf "$INSTALL_DIR/.config/opencode/node_modules"
rm -rf "$INSTALL_DIR/.cache/opencode"
rm -rf "$INSTALL_DIR/.config/opencode/opencode-workflows"

if [[ -d "$INSTALL_DIR/.config/opencode" ]]; then
  find "$INSTALL_DIR/.config/opencode" -type l -lname '../opencode-workflows/*' -delete
fi

echo "[Pre-Install] Ready to extract."

exit 0
