#!/usr/bin/env bash

if [[ "$#" == 2 ]]; then
  nvim --headless -c "if exists(\"$1\") | qall | endif | echoerr \"$1 not found\"" +cq $2 && echo "Test $1 pass"
elif [[ "$#" == 1 ]]; then
  nvim --headless -c "if exists(\"$1\") | qall | endif | echoerr \"$1 not found\"" +cq && echo "Test $1 pass"
else
  echo "usage: $0 vim_plugin_exist [filename_to_trigger_lazy_ft]" > /dev/stderr
  exit 1
fi
