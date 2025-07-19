SHELL := /bin/bash
LOG_DIR ?= logs
.PHONY: all shellrc utils nvim-plugins mason-packages

all: shellrc utils nvim-plugins mason-packages

shellrc: bash tcsh

utils: bat bd fd fzf git-extras lazygit node htop nvim rg tinty tmux rustup tree-sitter java yq

nvim-plugins: lazy.nvim telescope.nvim nvim-tree hop.nvim nvim-treesitter mason.nvim neoconf.nvim gitsigns.nvim nvim-cmp feline.nvim TrueZen.nvim Comment.nvim detour.nvim which-key.nvim tabby.nvim noice.nvim lazydev.nvim telescope-fzf-native.nvim nvim-base16 riscv-asm-vim verilog_systemverilog.vim

mason-packages: lua-language-server clangd svlangserver verible-verilog-ls vim-language-server pyright ltex-ls bash-language-server typescript-language-server vscode-json-language-server

$(LOG_DIR):
	@mkdir -p $(LOG_DIR)

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
lazy.nvim:
	@{ ./test-lua-package-exist.sh lazy 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

telescope.nvim:
	@{ ./test-lua-package-exist.sh telescope 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-tree:
	@{ ./test-lua-package-exist.sh nvim-tree 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

hop.nvim:
	@{ ./test-lua-package-exist.sh hop 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-treesitter:
	@{ ./test-lua-package-exist.sh nvim-treesitter 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

mason.nvim:
	@{ ./test-lua-package-exist.sh mason 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

neoconf.nvim:
	@{ ./test-lua-package-exist.sh neoconf 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

gitsigns.nvim:
	@{ ./test-lua-package-exist.sh gitsigns 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-cmp:
	@{ ./test-lua-package-exist.sh cmp 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

feline.nvim:
	@{ ./test-lua-package-exist.sh feline 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

TrueZen.nvim:
	@{ ./test-lua-package-exist.sh true-zen 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

Comment.nvim:
	@{ ./test-lua-package-exist.sh Comment 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

detour.nvim:
	@{ ./test-lua-package-exist.sh detour 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

which-key.nvim:
	@{ ./test-lua-package-exist.sh which-key 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

tabby.nvim:
	@{ ./test-lua-package-exist.sh tabby 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

noice.nvim:
	@{ ./test-lua-package-exist.sh noice 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

lazydev.nvim:
	@{ ./test-lua-package-exist.sh lazydev 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

# Test other neovim plugins
telescope-fzf-native.nvim:
	@{ ./test-fzf-native-build-success.sh 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

nvim-base16:
	@{ ./test-base16-colorscheme.sh 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

# Test vim plugins
riscv-asm-vim:
	@{ ./test-vim-package-exist.sh '*GetRiscvIndent' test.S 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

verilog_systemverilog.vim:
	@{ ./test-vim-package-exist.sh :VerilogDisableIndentAdd test.v 2> >(tee -a $(LOG_DIR)/$@.log >&2); } > $(LOG_DIR)/$@.log

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
