#!/bin/bash

# Download and update tmux plugins using tpm
chmod +x $HOME/.tmux/plugins/tpm/bin/*_plugins
$HOME/.tmux/plugins/tpm/bin/install_plugins
$HOME/.tmux/plugins/tpm/bin/update_plugins

# Download and update Neovim plugins using lazy.nvim
nvim --headless -c "Lazy! sync" +qa

# Download and update language servers for Neovim using mason.nvim
nvim --headless -c "MasonToolsUpdateSync" +qa

# Ensure nvim-treesitter parsers are installed
nvim --headless -c "TSUpdateSync" +qa
