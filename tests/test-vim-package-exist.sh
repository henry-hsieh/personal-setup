#!/usr/bin/env bash

if [[ "$#" == 3 ]]; then
  nvim --headless -c "set ft=$3" -c "Lazy! load $1" -c "lua local ok = vim.fn.exists(\"$2\"); if ok > 0 then print(\"Test $1 pass\n\") else print(\"Test $1 fail\n\") vim.cmd('cq 1') end" -c "q"
elif [[ "$#" == 2 ]]; then
  nvim --headless -c "Lazy! load $1" -c "lua local ok = vim.fn.exists(\"$2\"); if ok > 0 then print(\"Test $1 pass\n\") else print(\"Test $1 fail\n\") vim.cmd('cq 1') end" -c "q"
else
  echo "usage: $0 vim_plugin_name vim_plugin_command [filetype]" > /dev/stderr
  echo "vim_plugin_name: The repository name of the plugin"
  echo "vim_plugin_command: The command to test whether the plugin works"
  echo "filetype: If the plugin is lazy-loaded by filetype, the filetype should be specified"
  exit 1
fi
