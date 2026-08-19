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

# Verify every artifact a partial download could leave missing, so a
# broken cache is healed instead of silently shipped to the airgap.
if [[ ! -f "${MODEL_DIR}/config.json" || ! -f "${MODEL_DIR}/tokenizer.json" \
  || ! -f "${MODEL_DIR}/tokenizer_config.json" || ! -f "${MODEL_DIR}/onnx/model.onnx" ]]; then
  PRECACHE_SCRIPT='import { env, pipeline } from "@huggingface/transformers";
  env.cacheDir = process.env.MODEL_CACHE_DIR;
  const pipe = await pipeline("feature-extraction", "Xenova/all-MiniLM-L6-v2", { dtype: "fp32" });
  pipe.dispose?.();
  console.log("[opencode] magic-context embedding model pre-downloaded");'
  MODEL_CACHE_DIR="${MODEL_CACHE_DIR}" bun -e "$PRECACHE_SCRIPT"
fi
