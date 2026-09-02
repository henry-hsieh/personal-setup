#!/usr/bin/env bash
## Pre-download Magic Context's local embedding model into the release
## archive so the airgap environment serves it from cache on first use.

set -euo pipefail

PLUGIN="$1"
PLUGIN_PATH="$2"

if [[ "${PLUGIN}" != @cortexkit/opencode-magic-context@* ]]; then
  exit 0
fi

MODEL_CACHE_DIR="$HOME/.local/share/cortexkit/magic-context/models"
MODEL_DIR="${MODEL_CACHE_DIR}/Xenova/all-MiniLM-L6-v2"
MODEL_URL="https://huggingface.co/Xenova/all-MiniLM-L6-v2/resolve/main"

# Magic Context bundles transformers at publish time, so it is not available
# in the installed plugin tree for this build-only download step. Downloading
# the cache artifacts directly also avoids pulling in native ONNX dependencies.
download_model_file() {
  local relative_path="$1"
  local target="${MODEL_DIR}/${relative_path}"
  local temporary_file="${target}.tmp.$$"

  if [[ -f "${target}" ]]; then
    return
  fi

  mkdir -p "$(dirname "${target}")"
  if curl --fail --silent --show-error --location --retry 3 --retry-delay 1 \
    --output "${temporary_file}" "${MODEL_URL}/${relative_path}"; then
    mv "${temporary_file}" "${target}"
  else
    rm -f "${temporary_file}"
    return 1
  fi
}

# Verify every artifact a partial download could leave missing, so a
# broken cache is healed instead of silently shipped to the airgap.
if [[ ! -f "${MODEL_DIR}/config.json" || ! -f "${MODEL_DIR}/tokenizer.json" \
  || ! -f "${MODEL_DIR}/tokenizer_config.json" || ! -f "${MODEL_DIR}/onnx/model.onnx" ]]; then
  for model_file in config.json tokenizer.json tokenizer_config.json onnx/model.onnx; do
    download_model_file "${model_file}"
  done
  echo "[opencode] magic-context embedding model pre-downloaded"
fi
