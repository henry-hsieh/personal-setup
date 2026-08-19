#!/usr/bin/env bash
## Download and pin OpenCode Ensemble skills from a specific commit
## for reproducibility in airgap environments.

set -euo pipefail

ENSEMBLE_SKILLS_SHA="5cb44fa16cde546453626eb9d7dcfa6eb0157068"
SKILLS_DIR="$HOME/.config/opencode/skills/opencode-ensemble"
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "${STAGING_DIR}"' EXIT

curl -fsSL --connect-timeout 10 --max-time 60 --retry 3 \
  "https://api.github.com/repos/hueyexe/opencode-ensemble/tarball/${ENSEMBLE_SKILLS_SHA}" \
  -o "${STAGING_DIR}/ensemble.tar.gz"
tar xzf "${STAGING_DIR}/ensemble.tar.gz" -C "${STAGING_DIR}"
ENSEMBLE_EXTRACTED="$(find "${STAGING_DIR}" -maxdepth 1 -type d -name "hueyexe-opencode-ensemble-*" | head -1)"
if [[ -z "${ENSEMBLE_EXTRACTED}" ]]; then
  echo "[opencode] ERROR: failed to extract ensemble skills tarball"
  exit 1
fi
STAGING_SKILLS="${ENSEMBLE_EXTRACTED}/skills/opencode-ensemble/"
if [[ ! -d "${STAGING_SKILLS}" ]]; then
  echo "[opencode] ERROR: skills directory not found in tarball"
  exit 1
fi
rm -rf "${SKILLS_DIR}"
mkdir -p "$(dirname "${SKILLS_DIR}")"
cp -r "${STAGING_SKILLS}" "${SKILLS_DIR}"
echo "[opencode] Ensemble skills pinned at ${ENSEMBLE_SKILLS_SHA}"
