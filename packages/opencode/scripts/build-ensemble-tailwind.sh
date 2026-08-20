#!/usr/bin/env bash
## Compile Ensemble's browser-loaded Tailwind CSS at release build time.

set -euo pipefail

PLUGIN="$1"
PLUGIN_PATH="$2"
SCRIPT_DIR="$3"

if [[ "${PLUGIN}" != @hueyexe/opencode-ensemble@* ]]; then
  exit 0
fi

ENSEMBLE_PATH="${PLUGIN_PATH}/node_modules/${PLUGIN%@*}"
TAILWIND_CDN_VERSION=$(python3 -c '
import re
from urllib.request import Request, urlopen

request = Request("https://cdn.tailwindcss.com", headers={"User-Agent": "curl/8.0"})
with urlopen(request, timeout=30) as response:
  source = response.read().decode("utf-8")

name_match = re.search(r"tailwindcss v\$\{([A-Za-z_$][A-Za-z0-9_$]*)\}", source)
if name_match is None:
  raise SystemExit("could not find the Tailwind version variable")

version_pattern = (
  r"(?<![A-Za-z0-9_$])"
  + re.escape(name_match.group(1))
  + r"\s*=\s*\"(\d+(?:\.\d+){2}(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?)\""
)
version_match = re.search(version_pattern, source)
if version_match is None:
  raise SystemExit("could not find the Tailwind version")

print(version_match.group(1))
')
if [[ -z "${TAILWIND_CDN_VERSION}" ]]; then
  echo "[opencode] ERROR: could not determine the Tailwind version served by cdn.tailwindcss.com"
  exit 1
fi
if [[ ! "${TAILWIND_CDN_VERSION}" =~ ^3\. ]]; then
  echo "[opencode] ERROR: Ensemble dashboard Tailwind build requires v3 (got ${TAILWIND_CDN_VERSION})"
  exit 1
fi
python3 "${SCRIPT_DIR}/patch-ensemble-dashboard.py" prepare "${ENSEMBLE_PATH}"
(
  cd "${ENSEMBLE_PATH}"
  bun x --bun "tailwindcss@${TAILWIND_CDN_VERSION}" \
  --config .personal-setup-tailwind.config.cjs \
  --input src/.personal-setup-dashboard.css \
  --output src/dashboard-tailwind.css \
  --minify
)
python3 "${SCRIPT_DIR}/patch-ensemble-dashboard.py" apply "${ENSEMBLE_PATH}"
rm -f "${ENSEMBLE_PATH}/.personal-setup-tailwind.config.cjs" \
  "${ENSEMBLE_PATH}/src/.personal-setup-dashboard.css"
echo "[opencode] Ensemble dashboard Tailwind CSS embedded for airgap use"
