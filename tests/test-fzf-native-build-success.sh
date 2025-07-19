#!/usr/bin/env bash

nvim --headless -c "lua require(\"telescope\").load_extension(\"fzf\"); vim.api.nvim_command(\"qall\")" +cq && echo "Test telescope-fzf-native pass"
