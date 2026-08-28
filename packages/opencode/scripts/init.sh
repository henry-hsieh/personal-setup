#!/usr/bin/env bash
## Main orchestrator for opencode post-install initialization.
## Called by the build system as: bash {pkg_dir}/scripts/init.sh {version}

set -euo pipefail

VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Shell completions
opencode completion > "$HOME/.local/share/bash-completion/completions/opencode.bash"

# 2. Install @opencode-ai/plugin and its plugins
OPENCODE_CONFIG_DIR="$HOME/.config/opencode/"
rm -rf "$OPENCODE_CONFIG_DIR"/node_modules/
rm -rf "$OPENCODE_CONFIG_DIR"/package.json
rm -rf "$OPENCODE_CONFIG_DIR"/package-lock.json
rm -rf "$OPENCODE_CONFIG_DIR"/bun.lock
cd "${OPENCODE_CONFIG_DIR}"
bun add --exact "@opencode-ai/plugin@${VERSION}"
npm install --package-lock-only

# Install OpenCode plugins
OPENCODE_PLUGIN_DIR="$HOME/.cache/opencode/packages/"
rm -rf "$HOME/.cache/opencode/"
mkdir -p "$OPENCODE_PLUGIN_DIR"
PLUGIN_LIST=$(cpp -P "$HOME/.config/opencode/opencode.jsonc" | yq -r '.plugin[] | select(type == "!!str")')
if [[ -z "$PLUGIN_LIST" ]]; then
  echo "[opencode] WARNING: no plugins found in opencode.jsonc"
  exit 1
fi
for plugin in $PLUGIN_LIST; do
  PLUGIN_PATH="${OPENCODE_PLUGIN_DIR}/${plugin}"
  mkdir -p "${PLUGIN_PATH}"
  cd "${PLUGIN_PATH}"
  bun add --exact "${plugin}"
  npm install --package-lock-only

  # Pre-download Magic Context's local embedding model
  bash "${SCRIPT_DIR}/precache-magic-context.sh" "${plugin}" "${PLUGIN_PATH}"

  # Pre-download AFT's embedding model + ONNX Runtime
  bash "${SCRIPT_DIR}/precache-aft.sh" "${plugin}" "${PLUGIN_PATH}" "${SCRIPT_DIR}"

  # Compile Ensemble's browser-loaded Tailwind CSS
  bash "${SCRIPT_DIR}/build-ensemble-tailwind.sh" "${plugin}" "${PLUGIN_PATH}" "${SCRIPT_DIR}"

  if [[ "${plugin}" == @bybrawe/opencode-goal@* ]]; then
    rm -rf /tmp/opencode-goal
    env OPENCODE_CONFIG_DIR=/tmp/opencode-goal npx -y "${plugin}"
    cp -r /tmp/opencode-goal/commands/ "$OPENCODE_CONFIG_DIR/"
  fi
  if [[ "${plugin}" == @bybrawe/opencode-loop@* ]]; then
    rm -rf /tmp/opencode-loop
    env OPENCODE_CONFIG_DIR=/tmp/opencode-loop npx -y "${plugin}" --loop-only --without-loop-goals
    cp -rf /tmp/opencode-loop/commands/ "$OPENCODE_CONFIG_DIR/"
    cp -rf /tmp/opencode-loop/agents/ "$OPENCODE_CONFIG_DIR/"
  fi
done

# 3. Install pre-pinned OpenCode agent skills (see skills.yaml)
python3 "${SCRIPT_DIR}/install-skills.py"
