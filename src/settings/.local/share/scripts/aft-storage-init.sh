#!/usr/bin/env bash
# ==============================================================================
# Provision AFT storage on fast local storage (cortexkit/aft#263).
#
# Relocates AFT's runtime storage universe (SQLite DB, trigram/semantic/callgraph
# indexes, writer leases) off slow or network-mounted home directories by
# pointing AFT_STORAGE_DIR at tmpfs. The heavy read-mostly asset subtrees
# (embedding model, ONNX Runtime) stay in the persistent legacy data dir and are
# borrowed into the fast root via symlinks.
#
# Usage: called from .bash_profile / .login. Prints the resolved root on stdout;
# exits non-zero silently when no fast location is writable.
# ==============================================================================
set -euo pipefail

USER_NAME="${USER:-$(id -un)}"
FAST_ROOT="aft-storage"
LEGACY="$HOME/.local/share/cortexkit/aft"

# Pick the fastest writable base: /dev/shm first, /tmp as fallback.
ROOT=""
for base in "/dev/shm/$USER_NAME" "/tmp/$USER_NAME"; do
  if mkdir -p "$base/$FAST_ROOT" 2>/dev/null && [ -w "$base/$FAST_ROOT" ]; then
    ROOT="$base/$FAST_ROOT"
    break
  fi
done
if [ -z "$ROOT" ]; then
  exit 1
fi

# Idempotent fill-if-absent provisioning.
if [ ! -e "$ROOT/semantic/models" ]; then
  mkdir -p "$ROOT/semantic"
  if [ -d "$LEGACY/semantic/models" ]; then
    ln -sfn "$LEGACY/semantic/models" "$ROOT/semantic/models"
  fi
fi
if [ ! -e "$ROOT/onnxruntime" ] && [ -d "$LEGACY/onnxruntime" ]; then
  ln -sfn "$LEGACY/onnxruntime" "$ROOT/onnxruntime"
fi

printf '%s\n' "$ROOT"
