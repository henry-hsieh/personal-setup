#!/usr/bin/env bash

if [[ "$#" == 3 ]]; then
  nvim --headless -c "set ft=$3" -c "Lazy! load $1" -c "lua local ok, _ = pcall(require, \"$2\"); if ok then print(\"Test $1 pass\n\") else print(\"Test $1 fail\n\") vim.cmd('cq 1') end" -c "q"
elif [[ "$#" == 2 ]]; then
  nvim --headless -c "Lazy! load $1" -c "lua local ok, _ = pcall(require, \"$2\"); if ok then print(\"Test $1 pass\n\") else print(\"Test $1 fail\n\") vim.cmd('cq 1') end" -c "q"
else
  echo "usage: $0 lua_plugin_name lua_module_name [filetype]" > /dev/stderr
  echo "lua_plugin_name: The repository name of the plugin"
  echo "lua_module_name: The main lua filename of the plugin"
  echo "filetype: If the plugin is lazy-loaded by filetype, the filetype should be specified"
  exit 1
fi
