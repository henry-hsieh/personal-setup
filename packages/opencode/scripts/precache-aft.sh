#!/usr/bin/env bash
## Pre-download AFT's embedding model + ONNX Runtime into the release
## archive so the airgap environment serves them from cache on first use.

set -euo pipefail

PLUGIN="$1"
PLUGIN_PATH="$2"
SCRIPT_DIR="$3"

if [[ "${PLUGIN}" != @cortexkit/aft-opencode@* ]]; then
  exit 0
fi

# \b keeps this from matching INVALID_ORT_VERSION in the same file
ORT_VERSION=$(grep -oP '\bORT_VERSION\s*=\s*"\K[^"]+' \
  "${PLUGIN_PATH}/node_modules/@cortexkit/aft-bridge/dist/onnx-runtime.js" 2>/dev/null || true)
if [[ -n "${ORT_VERSION}" ]]; then
  AFT_MODEL_REF="$HOME/.local/share/cortexkit/aft/semantic/models/models--Qdrant--all-MiniLM-L6-v2-onnx/refs/main"
  AFT_ORT_DIR="$HOME/.local/share/cortexkit/aft/onnxruntime/${ORT_VERSION}"
  AFT_MARKER="${AFT_ORT_DIR}/.aft-onnx-installed"
  AFT_LIB="${AFT_ORT_DIR}/libonnxruntime.so.${ORT_VERSION}"
  AFT_PROVIDERS="${AFT_ORT_DIR}/libonnxruntime_providers_shared.so"
  if [[ ! -f "$AFT_MODEL_REF" || ! -f "$AFT_MARKER" || ! -f "$AFT_LIB" || ! -f "$AFT_PROVIDERS" ]]; then
    python3 "${SCRIPT_DIR}/precache-aft.py" "${ORT_VERSION}"
    echo "[opencode] AFT embedding model + ONNX Runtime ${ORT_VERSION} pre-downloaded"
  fi
else
  echo "[opencode] WARNING: could not determine AFT ONNX Runtime version; airgap pre-download skipped"
fi
