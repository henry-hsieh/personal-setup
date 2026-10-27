import { expect, test } from "bun:test"
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync, existsSync } from "node:fs"
import { tmpdir } from "node:os"
import path from "node:path"
import { spawnSync } from "node:child_process"

test("upgrade removes an unmodified managed bridge and preserves user changes", () => {
  const root = mkdtempSync(path.join(tmpdir(), "opencode-upgrade-"))
  const commands = path.join(root, ".config/opencode/commands")
  const config = path.join(root, ".config/opencode")
  mkdirSync(commands, { recursive: true })
  const goal = path.join(commands, "goal.md")
  const userLoop = path.join(commands, "loop.md")
  const tui = path.join(config, "tui.jsonc")
  writeFileSync(goal, `---
description: Set or manage a persistent evidence-verified goal
---

<!-- managed-by:@bybrawe/opencode-goal -->
OpenCode Goals command bridge. The OpenCode Goals plugin should intercept this command before model execution.
If this text reaches the model, do not perform the requested work. Tell the user the OpenCode Goals plugin did not load, then ask them to reinstall/update with npx -y @bybrawe/opencode-goal@latest and fully restart OpenCode.

Requested /goal arguments:
$ARGUMENTS
`)
  writeFileSync(userLoop, "user customized loop command\n")
  writeFileSync(
    tui,
    '{\n  "plugin": [\n    "@cortexkit/opencode-magic-context@0.49.25",\n    "@cortexkit/aft-opencode@0.62.0"\n  ]\n}\n',
  )

  try {
    const result = spawnSync("bash", [path.resolve(import.meta.dir, "../../src/pre-install.sh")], {
      cwd: root,
      encoding: "utf8",
    })
    expect(result.status).toBe(0)
    expect(existsSync(goal)).toBe(false)
    expect(existsSync(tui)).toBe(false)
    expect(readFileSync(userLoop, "utf8")).toBe("user customized loop command\n")
  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})
