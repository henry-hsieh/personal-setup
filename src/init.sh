#!/bin/bash

# Directory path
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source ${ROOT_DIR}/src/utils.sh

# Download and update tmux plugins using tpm
print_process_item "Install/update tmux plugins"
pushd ${ROOT_DIR}/build/tmux
tmux --appimage-extract
mv squashfs-root/AppRun squashfs-root/tmux
export PATH=${ROOT_DIR}/build/tmux/squashfs-root/:$PATH
popd
chmod +x $HOME/.tmux/plugins/tpm/bin/*_plugins
$HOME/.tmux/plugins/tpm/bin/install_plugins
$HOME/.tmux/plugins/tpm/bin/update_plugins

# Build libs with musl-gcc
export CC=musl-gcc

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
nvim --headless -c "TSUpdateSync" +qa
