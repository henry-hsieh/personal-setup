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

BRIDGE="${PLUGIN_PATH}/node_modules/@cortexkit/aft-bridge/dist/onnx-runtime.js"
python3 "${SCRIPT_DIR}/precache-aft.py" "${BRIDGE}"
echo "[opencode] AFT embedding model + ONNX Runtime pre-downloaded"
