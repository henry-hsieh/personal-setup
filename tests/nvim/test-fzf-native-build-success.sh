#!/usr/bin/env bash

HOME=$(pwd) bash -c ".local/bin/nvim -u .config/nvim/init.lua --headless -c 'lua require(\"telescope\").load_extension(\"fzf\"); vim.api.nvim_command(\"qall\")' +cq $2 && echo 'Test pass'"
