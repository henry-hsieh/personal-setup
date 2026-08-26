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
# Validate ownership, permissions, and symlink safety to prevent attacks.
ROOT=""
CURRENT_UID="$(id -u)"
for base in "/dev/shm/$USER_NAME" "/tmp/$USER_NAME"; do
  # Try to create base directory with restrictive permissions
  mkdir -p -m 0700 "$base" 2>/dev/null || true

  # Validate base directory: not a symlink, owned by us, mode 0700, writable
  if [ -L "$base" ] || [ ! -d "$base" ]; then
    continue
  fi
  base_owner="$(stat -c '%u' "$base" 2>/dev/null)" || continue
  if [ "$base_owner" != "$CURRENT_UID" ]; then
    continue
  fi
  # Ensure restrictive permissions (tighten if needed)
  chmod 0700 "$base" 2>/dev/null || continue
  if [ ! -w "$base" ]; then
    continue
  fi

  # Now validate the final storage directory
  storage_path="$base/$FAST_ROOT"
  mkdir -p -m 0700 "$storage_path" 2>/dev/null || true

  # Validate storage directory: not a symlink, owned by us, mode 0700, writable
  if [ -L "$storage_path" ] || [ ! -d "$storage_path" ]; then
    continue
  fi
  storage_owner="$(stat -c '%u' "$storage_path" 2>/dev/null)" || continue
  if [ "$storage_owner" != "$CURRENT_UID" ]; then
    continue
  fi
  # Ensure restrictive permissions (tighten if needed)
  chmod 0700 "$storage_path" 2>/dev/null || continue
  if [ ! -w "$storage_path" ]; then
    continue
  fi

  # All checks passed
  ROOT="$storage_path"
  break
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
