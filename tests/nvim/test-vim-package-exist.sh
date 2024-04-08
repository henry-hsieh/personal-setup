#!/usr/bin/env bash

if [[ "$#" == 2 ]]; then
  HOME=$(pwd) bash -c ".local/bin/nvim -u .config/nvim/init.lua --headless -c 'if exists(\"$1\") | qall | endif | echoerr \"$1 not found\"' +cq $2 && echo 'Test pass'"
elif [[ "$#" == 1 ]]; then
  HOME=$(pwd) bash -c ".local/bin/nvim -u .config/nvim/init.lua --headless -c 'if exists(\"$1\") | qall | endif | echoerr \"$1 not found\"' +cq && echo 'Test pass'"
else
  echo "usage: $0 vim_plugin_exist [filename_to_trigger_lazy_ft]" > /dev/stderr
  exit 1
fi
