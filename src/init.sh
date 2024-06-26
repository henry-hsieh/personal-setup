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
nvim --headless -c "TSUpdateSync" +qa
