#!/usr/bin/env bash

set -e

# CLI Test Runner
# Reads test configuration from packages/*/package.yaml

if ! command -v yq >/dev/null 2>&1; then
  echo "Error: yq is required for the test runner."
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/packages"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Ensure test home binaries are in PATH if running in coordinator
if [ -n "$HOME" ] && [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

MAX_JOBS=${PARALLEL:-$(nproc)}

# Test result formatting
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

# Internal test executor (runs in subshell)
# Outputs: STATUS|MESSAGE|DETAILS (one line)
execute_test() {
  local name="$1"
  local type="$2"
  local bin="$3"
  local args="$4"
  local cmd="$5"
  local indent="$6"

  if [ "$type" = "false" ]; then
    echo "SKIP|$indent$name (skipped)|"
    return
  fi

  case "$type" in
    version-check)
      local binary="${bin:-$name}"
      local arguments="${args:-"--version"}"
      if command -v "$binary" >/dev/null 2>&1; then
        local output
        if output=$($binary $arguments 2>&1 </dev/null); then
          echo "PASS|$indent$name ($binary $arguments)|"
        else
          # Flatten multi-line output for the status line
          local flat_output=$(echo "$output" | tr '\n' ' ')
          echo "FAIL|$indent$name ($binary $arguments returned non-zero)|$flat_output"
        fi
      else
        echo "FAIL|$indent$name ($binary not found in PATH)|"
      fi
      ;;
    cmd)
      local output
      if output=$(eval "$cmd" 2>&1 </dev/null); then
        echo "PASS|$indent$name ($cmd)|"
      else
        local flat_output=$(echo "$output" | tr '\n' ' ')
        echo "FAIL|$indent$name ($cmd failed)|$flat_output"
      fi
      ;;
    lsp-stdio)
      local binary="${bin:-$name}"
      if command -v "$binary" >/dev/null 2>&1; then
        local output
        if output=$(node "$ROOT_DIR/tests/test-lsp-stdio.ts" "$binary" 2>&1 </dev/null); then
          echo "PASS|$indent$name (LSP handshake)|"
        else
          local flat_output=$(echo "$output" | tr '\n' ' ')
          echo "FAIL|$indent$name (LSP handshake failed)|$flat_output"
        fi
      else
        echo "FAIL|$indent$name ($binary not found in PATH)|"
      fi
      ;;
    nvim-plugin)
      echo "SKIP|$indent$name (handled by nvim test suite)|"
      ;;
    *)
      echo "SKIP|$indent$name (unknown test type: $type)|"
      ;;
  esac
}

# Discovery state
TEST_LIST_FILE="$TEMP_DIR/tests.list"
touch "$TEST_LIST_FILE"

add_test() {
  echo "$1|$2|$3|$4|$5|$6" >> "$TEST_LIST_FILE"
}

discover_subpackages() {
  local pkg_yaml="$1"
  local indent="$2"

  local kind=$(yq eval '.subpackages | kind' "$pkg_yaml")
  if [ "$kind" = "scalar" ]; then return; fi

  local num_subpackages=0
  if [ "$kind" = "seq" ]; then
    num_subpackages=$(yq eval '.subpackages | length' "$pkg_yaml")
  elif [ "$kind" = "map" ]; then
    num_subpackages=1
  fi

  for (( i=0; i<$num_subpackages; i++ )); do
    local selector=".subpackages"
    [ "$kind" = "seq" ] && selector=".subpackages[$i]"

    local manifest=$(yq eval "$selector.manifest" "$pkg_yaml")
    local manifest_type=$(yq eval "$selector.manifest_type" "$pkg_yaml")
    local default_type=$(yq eval "$selector.test_defaults.type // \"version-check\"" "$pkg_yaml")
    local default_args=$(yq eval "($selector.test_defaults.args // []) | join(\" \")" "$pkg_yaml")

    if [ "$manifest_type" = "npm" ]; then
      local manifest_path="$ROOT_DIR/$manifest"
      if [ -f "$manifest_path" ]; then
        # Use -r for raw output to avoid quoted keys
        local subs=$(yq eval '(.dependencies // {}) + (.devDependencies // {}) | keys | .[]' -r "$manifest_path" 2>/dev/null || true)
        for sub in $subs; do
          # Check for overrides in subpackages.packages array
          local override_bin=$(yq eval "$selector.packages[] | select(.name == \"$sub\") | .bin // \"\"" "$pkg_yaml")
          local override_type=$(yq eval "$selector.packages[] | select(.name == \"$sub\") | .test.type // \"\"" "$pkg_yaml")
          local final_type="${override_type:-$default_type}"

          add_test "$sub" "$final_type" "$override_bin" "$default_args" "" "  $indent"
        done
      fi
    elif [ "$manifest_type" = "lua" ]; then
      local manifest_path="$ROOT_DIR/$manifest"
      if [ -f "$manifest_path" ]; then
        # Use Lua to parse manifest and extract package names
        local subs
        subs=$(nvim --headless -l "$ROOT_DIR/tests/utils/parse-lua-manifest.lua" "$manifest_path" 2>/dev/null) || true
        for sub in $subs; do

          # Check for overrides in subpackages.packages array
          local override_bin=$(yq eval "$selector.packages[] | select(.name == \"$sub\") | .bin // \"\"" "$pkg_yaml")
          local override_type=$(yq eval "$selector.packages[] | select(.name == \"$sub\") | .test.type // \"\"" "$pkg_yaml")
          local final_type="${override_type:-$default_type}"

          add_test "$sub" "$final_type" "$override_bin" "$default_args" "" "  $indent"
        done
      fi
    elif [ "$manifest_type" = "inline" ]; then
      local num_packages=$(yq eval "$selector.packages | length" "$pkg_yaml")
      for (( j=0; j<$num_packages; j++ )); do
        local sub_name=$(yq eval "$selector.packages[$j].name" "$pkg_yaml")
        local sub_bin=$(yq eval "$selector.packages[$j].bin // \"\"" "$pkg_yaml")
        local sub_type=$(yq eval "$selector.packages[$j].test.type // \"$default_type\"" "$pkg_yaml")
        add_test "$sub_name" "$sub_type" "$sub_bin" "$default_args" "" "  $indent"
      done
    fi
  done
}

# 1. Discovery
for pkg_yaml in "$PACKAGES_DIR"/*/package.yaml; do
  pkg_name=$(basename "$(dirname "$pkg_yaml")")

  # Default to version-check if no test field, unless test is false
  is_false=$(yq eval '.test == false' "$pkg_yaml")
  if [ "$is_false" = "true" ]; then
    test_type="false"
  else
    test_type=$(yq eval '.test.type // "version-check"' "$pkg_yaml")
  fi

  test_bin=$(yq eval '.test.bin // ""' "$pkg_yaml")
  test_args=$(yq eval '(.test.args // []) | join(" ")' "$pkg_yaml")
  test_cmd=$(yq eval '.test.cmd // ""' "$pkg_yaml")

  add_test "$pkg_name" "$test_type" "$test_bin" "$test_args" "$test_cmd" ""
  discover_subpackages "$pkg_yaml" ""
done

# 2. Execution (Parallel)
pids=()
results=()
idx=0
while IFS='|' read -r name type bin args cmd indent <&3; do
  res_file="$TEMP_DIR/res_$idx"
  execute_test "$name" "$type" "$bin" "$args" "$cmd" "$indent" > "$res_file" 2>&1 </dev/null &
  pids+=($!)
  results+=("$res_file")

  if [ ${#pids[@]} -ge $MAX_JOBS ]; then
    wait "${pids[0]}" || true
    pids=("${pids[@]:1}")
  fi
  idx=$((idx + 1))
done 3< "$TEST_LIST_FILE"

# Wait for remaining
for pid in "${pids[@]}"; do
  wait "$pid" || true
done

# 3. Report
PASSED=0
FAILED=0
SKIPPED=0
FAILED_LIST=""

echo "=== CLI Utility Tests ==="
for res_file in "${results[@]}"; do
  if [ ! -f "$res_file" ]; then continue; fi
  if ! IFS='|' read -r status msg details < "$res_file"; then
    continue
  fi

  case "$status" in
    PASS)
      log_pass "$msg"
      PASSED=$((PASSED + 1))
      ;;
    FAIL)
      log_fail "$msg"
      [ -n "$details" ] && echo -e "      ${RED}Error:${NC} $details"
      FAILED=$((FAILED + 1))
      FAILED_LIST="$FAILED_LIST\n  - $msg"
      ;;
    SKIP)
      log_skip "$msg"
      SKIPPED=$((SKIPPED + 1))
      ;;
  esac
done

echo ""
echo -e "Summary: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, ${YELLOW}$SKIPPED skipped${NC}."

if [ -n "$FAILED_LIST" ]; then
  echo -e "\nFailed tests:$FAILED_LIST"
fi

[ $FAILED -eq 0 ]
