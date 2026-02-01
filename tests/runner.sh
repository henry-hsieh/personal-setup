#!/usr/bin/env bash

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Ensure test home binaries are in PATH
if [ -n "$HOME" ] && [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Aggregated status
EXIT_CODE=0
RUN_UTILS=true
RUN_NVIM=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --utils) RUN_NVIM=false; shift ;;
    --nvim) RUN_UTILS=false; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ "$RUN_UTILS" = true ]; then
  echo "=== Running CLI Utility Tests ==="
  if ! "$ROOT_DIR/tests/utils/runner.sh"; then
    EXIT_CODE=1
  fi
fi

if [ "$RUN_NVIM" = true ]; then
  echo ""
  echo "=== Running Neovim Plugin Tests ==="
  # Add ROOT_DIR to LUA_PATH so we can require('tests.nvim.manifest')
  export LUA_PATH="$ROOT_DIR/?.lua;$ROOT_DIR/?/init.lua;;$LUA_PATH"

  if ! nvim --headless -c "lua require('plenary.busted').run('$ROOT_DIR/tests/nvim/runner.lua')" -c "qa!"; then
    echo "Neovim tests failed"
    EXIT_CODE=1
  fi
fi

if [ $EXIT_CODE -eq 0 ]; then
  echo ""
  echo "All tests passed! 🎉"
else
  echo ""
  echo "Some tests failed. ❌"
fi

exit $EXIT_CODE
