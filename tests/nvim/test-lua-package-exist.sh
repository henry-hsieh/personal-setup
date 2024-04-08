#!/usr/bin/env bash

if [[ "$#" == 2 ]]; then
  HOME=$(pwd) bash -c ".local/bin/nvim -u .config/nvim/init.lua --headless -c 'lua require(\"$1\"); vim.api.nvim_command(\"qall\")' +cq $2 && echo 'Test pass'"
elif [[ "$#" == 1 ]]; then
  HOME=$(pwd) bash -c ".local/bin/nvim -u .config/nvim/init.lua --headless -c 'lua require(\"$1\"); vim.api.nvim_command(\"qall\")' +cq && echo 'Test pass'"
else
  echo "usage: $0 lua_package_name [filename_to_trigger_lazy_ft]" > /dev/stderr
  exit 1
fi
