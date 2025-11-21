#!/usr/bin/env bash

# Directory path
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source ${ROOT_DIR}/src/utils.sh

# Download and update tmux plugins using tpm
tmux() {
  /usr/bin/env tmux --appimage-extract-and-run $@
}
export -f tmux
chmod +x $HOME/.config/tmux/plugins/tpm/bin/*_plugins
$HOME/.config/tmux/plugins/tpm/bin/install_plugins
$HOME/.config/tmux/plugins/tpm/bin/update_plugins

# Download and update themes using tinty
print_process_item "Install/update Tinty themes"
tinty install

# Download and update Neovim plugins using lazy.nvim
print_process_item "Install/update Neovim plugins"
nvim --headless -c "Lazy! sync" +qa

# Download and update language servers for Neovim using mason.nvim
print_process_item "Install/update Neovim mason tools"
nvim --headless -c "MasonToolsUpdateSync" +qa

# Ensure nvim-treesitter parsers are installed
print_process_item "Install/update Neovim tree-sitter parsers"
(export CFLAGS="$CFLAGS -std=c11"; cd $ROOT_DIR/src; nvim --headless -c 'lua dofile("install-ts-parser.lua")' +qa!)
# Relink with relative paths
pushd $HOME/.local/share/nvim/site/queries > /dev/null
for link in *; do
  if [ -L "$link" ]; then
    target=$(readlink "$link")
    if [[ "$target" = /* ]]; then
      ln -snrfT "$target" "$link"
    fi
  fi
done
popd > /dev/null

# Download blink.cmp fuzzy prebuilt binaries
print_process_item "Install Neovim blink.cmp prebuilt binaries"
blink_version=$(git -C $HOME/.local/share/nvim/lazy/blink.cmp describe --exact-match --tags)
if [[ "$blink_version" == "" ]]; then
  echo "blink.cmp is not on the release version"
  exit 1
fi
mkdir -p $HOME/.local/share/nvim/lazy/blink.cmp/target/release/
pushd $HOME/.local/share/nvim/lazy/blink.cmp/target/release/ > /dev/null
download_exe  https://github.com/Saghen/blink.cmp/releases/download/$blink_version/x86_64-unknown-linux-gnu.so libblink_cmp_fuzzy.so
download_file https://github.com/Saghen/blink.cmp/releases/download/$blink_version/x86_64-unknown-linux-gnu.so.sha256 libblink_cmp_fuzzy.so.sha256
printf "$blink_version" > version
popd > /dev/null

# Install Copilot CLI
npm install -g @github/copilot
# Rebuild node-pty
pushd /tmp > /dev/null
npm install @devm33/node-pty
rm -rf node_modules/\@devm33/node-pty/prebuilds
PYTHON=/usr/bin/python3.8 npm rebuild @devm33/node-pty --target=v18.20.8
cp -f node_modules/\@devm33/node-pty/build/Release/pty.node $HOME/.local/lib/node_modules/\@github/copilot/prebuilds/linux-x64/
popd

# Install latest svlangserver
npm install --prefix=$HOME/.local/share/nvim/mason/packages/svlangserver/ github:imc-trading/svlangserver

# Force install AI SDK dependencies for opencode
TEMP_CONFIG="/tmp/opencode-temp.json"
cat > "$TEMP_CONFIG" <<EOF
{
  "provider": {
    "fake-openai": {"npm": "@ai-sdk/openai", "options": {"baseURL": "http://fake"}, "models": {"gpt-4": {}}},
    "fake-anthropic": {"npm": "@ai-sdk/anthropic", "options": {"baseURL": "http://fake"}, "models": {"claude-3": {}}},
    "fake-groq": {"npm": "@ai-sdk/groq", "options": {"baseURL": "http://fake"}, "models": {"llama3": {}}},
    "fake-together": {"npm": "@ai-sdk/togetherai", "options": {"baseURL": "http://fake"}, "models": {"llama3": {}}},
    "fake-fireworks": {"npm": "@ai-sdk/fireworks", "options": {"baseURL": "http://fake"}, "models": {"llama3": {}}},
    "fake-deepseek": {"npm": "@ai-sdk/deepseek", "options": {"baseURL": "http://fake"}, "models": {"deepseek-chat": {}}},
    "fake-cerebras": {"npm": "@ai-sdk/cerebras", "options": {"baseURL": "http://fake"}, "models": {"llama3": {}}},
    "fake-xai": {"npm": "@ai-sdk/xai", "options": {"baseURL": "http://fake"}, "models": {"grok": {}}},
    "fake-google-vertex": {"npm": "@ai-sdk/google-vertex", "options": {"baseURL": "http://fake"}, "models": {"gemini": {}}},
    "fake-google-genai": {"npm": "@ai-sdk/google", "options": {"baseURL": "http://fake"}, "models": {"gemini": {}}},
    "fake-openai-compatible": {"npm": "@ai-sdk/openai-compatible", "options": {"baseURL": "http://fake"}, "models": {"compatible-model": {}}}
  }
}
EOF
export OPENCODE_CONFIG="$TEMP_CONFIG"
timeout 600 opencode run hello -m fake-openai/gpt-4 || true
timeout 600 opencode run hello -m fake-anthropic/claude-3 || true
timeout 600 opencode run hello -m fake-groq/llama3 || true
timeout 600 opencode run hello -m fake-together/llama3 || true
timeout 600 opencode run hello -m fake-fireworks/llama3 || true
timeout 600 opencode run hello -m fake-deepseek/deepseek-chat || true
timeout 600 opencode run hello -m fake-cerebras/llama3 || true
timeout 600 opencode run hello -m fake-xai/grok || true
timeout 600 opencode run hello -m fake-google-vertex/gemini || true
timeout 600 opencode run hello -m fake-google-genai/gemini || true
timeout 600 opencode run hello -m fake-openai-compatible/compatible-model || true
rm -f "$TEMP_CONFIG"
unset OPENCODE_CONFIG
