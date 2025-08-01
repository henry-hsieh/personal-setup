SHELL := /bin/bash
LOG_DIR ?= logs
.PHONY: all shellrc utils nvim-plugins mason-packages nvim-fresh-start

all: shellrc utils nvim-plugins mason-packages

shellrc: bash tcsh

utils: bat bd fd fzf git-extras lazygit node htop nvim rg tinty tmux rustup tree-sitter java yq

nvim-plugins: lazy.nvim telescope.nvim nvim-tree.lua nvim-treesitter mason.nvim neoconf.nvim gitsigns.nvim nvim-cmp feline.nvim TrueZen.nvim Comment.nvim detour.nvim which-key.nvim tabby.nvim noice.nvim lazydev.nvim telescope-fzf-native.nvim nvim-notify flash.nvim tinted-nvim riscv-asm-vim verilog_systemverilog.vim vim-fugitive

mason-packages: lua-language-server clangd svlangserver verible-verilog-ls vim-language-server pyright ltex-ls bash-language-server typescript-language-server vscode-json-language-server

$(LOG_DIR):
	@mkdir -p $(LOG_DIR)

nvim-fresh-start:
	@nvim --headless +qa!

# Test shell RC scripts
bash: | $(LOG_DIR)
	@{ "$@" -i -c 'echo "Test bash pass"' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tcsh: | $(LOG_DIR)
	@{ prompt="dummy" "$@" -i -c 'echo "Test tcsh pass"' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

# Test utils
bat: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

bd: | $(LOG_DIR)
	@{ "$@" -? 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

fd: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

fzf: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

git-extras: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

lazygit: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

node: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

htop: | $(LOG_DIR)
	@{ "$@" --appimage-extract-and-run --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

rg: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tinty: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tmux: | $(LOG_DIR)
	@{ $(HOME)/.local/bin/$@ --appimage-extract-and-run -V 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

rustup: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tree-sitter: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

java: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

yq: | $(LOG_DIR)
	@{ "$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

# Test neovim lua plugins
lazy.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test lazy.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

telescope.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test telescope.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

telescope-fzf-native.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test telescope load_extension '{"fzf"}' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-tree.lua: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test nvim-tree.api tree.open 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-treesitter: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test nvim-treesitter.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

mason.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test mason.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

neoconf.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test neoconf.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

gitsigns.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test gitsigns.actions reset_buffer 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-cmp: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test cmp complete 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

feline.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test feline generate_statusline 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

TrueZen.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test true-zen minimalist 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

Comment.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test Comment.api call "{'toggle.linewise', 'g@'}" 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

detour.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test detour Detour 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

which-key.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test which-key.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tabby.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test tabby update  2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

noice.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test noice.health check 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

lazydev.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.lua lazydev find_workspace lua 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-notify: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test notify notify '{"test",0,{}}' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

flash.nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test flash toggle 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tinted-nvim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-lua-plugin.lua")' +qa! -- $@.test tinted-highlighter set_highlights '{require("tinted-colorscheme").colors,"",false,{}}' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

# Test vim plugins
riscv-asm-vim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-vim-plugin.lua")' +qa! -- $@.S '*GetRiscvIndent' ':let dummy=GetRiscvIndent()' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

verilog_systemverilog.vim: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-vim-plugin.lua")' +qa! -- $@.v '*GetVerilogSystemVerilogIndent' ':let dummy=GetVerilogSystemVerilogIndent()' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

vim-fugitive: | $(LOG_DIR) nvim-fresh-start
	@{ nvim --headless -c 'lua dofile("test-vim-plugin.lua")' +qa! -- $@.v '*FugitiveGitDir' ':let dummy=FugitiveGitDir()' 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

# Test mason packages
lua-language-server: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

clangd: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

svlangserver: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

verible-verilog-ls: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

vim-language-server: | $(LOG_DIR)
	@{ ./test-lsp-stdio.ts $(HOME)/.local/share/nvim/mason/bin/"$@" 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log && echo "Test $@ pass" >> $(LOG_DIR)/$@.log

pyright: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

ltex-ls: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

bash-language-server: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

typescript-language-server: | $(LOG_DIR)
	@{ $(HOME)/.local/share/nvim/mason/bin/"$@" --version 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

vscode-json-language-server: | $(LOG_DIR)
	@{ ./test-lsp-stdio.ts $(HOME)/.local/share/nvim/mason/bin/"$@" 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log && echo "Test $@ pass" >> $(LOG_DIR)/$@.log
