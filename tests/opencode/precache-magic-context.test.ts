import { expect, test } from "bun:test"
import { chmodSync, existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join, resolve } from "node:path"

const SCRIPT = resolve(import.meta.dir, "../../packages/opencode/scripts/precache-magic-context.sh")
const PLUGIN = "@cortexkit/opencode-magic-context@0.41.1"
const MODEL_FILES = ["config.json", "tokenizer.json", "tokenizer_config.json", "onnx/model.onnx"]

test("precache downloads model files without the runtime transformers package", () => {
  const root = mkdtempSync(join(tmpdir(), "precache-magic-context-"))
  const binDir = join(root, "bin")
  const fakeCurl = join(binDir, "curl")
  mkdirSync(binDir, { recursive: true })
  writeFileSync(
    fakeCurl,
    `#!/usr/bin/env bash
set -euo pipefail
OUTPUT=""
while [[ $# -gt 0 ]]; do
  if [[ "$1" == --output ]]; then
    OUTPUT="$2"
    shift 2
  else
    shift
  fi
done
mkdir -p "$(dirname "$OUTPUT")"
printf fixture > "$OUTPUT"
`,
  )
  chmodSync(fakeCurl, 0o755)

  try {
    const result = Bun.spawnSync(["bash", SCRIPT, PLUGIN, join(root, "plugin")], {
      env: {
        ...process.env,
        HOME: root,
        PATH: `${binDir}:${process.env.PATH ?? ""}`,
      } as Record<string, string>,
      stdout: "pipe",
      stderr: "pipe",
    })

    expect(result.exitCode).toBe(0)
    const modelDir = join(root, ".local/share/cortexkit/magic-context/models/Xenova/all-MiniLM-L6-v2")
    for (const file of MODEL_FILES) {
      expect(existsSync(join(modelDir, file))).toBe(true)
    }
  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})
