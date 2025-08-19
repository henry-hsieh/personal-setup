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
echo $blink_version > version
popd > /dev/null
