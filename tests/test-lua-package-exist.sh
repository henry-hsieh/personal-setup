#!/usr/bin/env bash

if [[ "$#" == 2 ]]; then
  nvim --headless -c "lua require(\"$1\"); vim.api.nvim_command(\"qall\")" +cq $2 && echo "Test $1 pass"
elif [[ "$#" == 1 ]]; then
  nvim --headless -c "lua require(\"$1\"); vim.api.nvim_command(\"qall\")" +cq && echo "Test $1 pass"
else
  echo "usage: $0 lua_package_name [filename_to_trigger_lazy_ft]" > /dev/stderr
  exit 1
fi
