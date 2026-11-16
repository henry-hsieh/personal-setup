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

test("release exclusion preserves installed TUI preferences", () => {
  const root = mkdtempSync(path.join(tmpdir(), "opencode-preferences-"))
  const source = path.join(root, "source")
  const target = path.join(root, "target")
  const fresh = path.join(root, "fresh")
  const relative = ".config/opencode/tui-preferences.jsonc"
  const repo = path.resolve(import.meta.dir, "../..")
  mkdirSync(path.join(source, ".config/opencode"), { recursive: true })
  mkdirSync(path.join(target, ".config/opencode"), { recursive: true })
  mkdirSync(fresh)
  writeFileSync(path.join(source, relative), "shipped preferences\n")
  writeFileSync(path.join(target, relative), "user preferences\n")
  writeFileSync(path.join(source, ".config/opencode/other.json"), "included\n")

  try {
    const evaluated = spawnSync("just", ["--evaluate", "static_exclude_flags"], { cwd: repo, encoding: "utf8" })
    expect(evaluated.status).toBe(0)
    const exclusions = evaluated.stdout.trim().split(/\s+/)
    const archive = path.join(root, "release.tar")
    expect(spawnSync("tar", [...exclusions, "-cf", archive, "-C", source, "."]).status).toBe(0)
    expect(spawnSync("tar", ["-xf", archive, "-C", fresh]).status).toBe(0)
    expect(existsSync(path.join(fresh, relative))).toBe(false)
    expect(spawnSync("tar", ["-xf", archive, "-C", target]).status).toBe(0)
    expect(readFileSync(path.join(target, relative), "utf8")).toBe("user preferences\n")
    expect(readFileSync(path.join(target, ".config/opencode/other.json"), "utf8")).toBe("included\n")

  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})

test.skipIf(!Bun.which("rsync"))("fast-test exclusion preserves installed TUI preferences", () => {
  const root = mkdtempSync(path.join(tmpdir(), "opencode-preferences-rsync-"))
  const source = path.join(root, "source")
  const target = path.join(root, "target")
  const relative = ".config/opencode/tui-preferences.jsonc"
  const repo = path.resolve(import.meta.dir, "../..")
  mkdirSync(path.join(source, ".config/opencode"), { recursive: true })
  mkdirSync(path.join(target, ".config/opencode"), { recursive: true })
  writeFileSync(path.join(source, relative), "shipped preferences\n")
  writeFileSync(path.join(target, relative), "user preferences\n")
  writeFileSync(path.join(source, ".config/opencode/other.json"), "included\n")

  try {
    const evaluated = spawnSync("just", ["--evaluate", "static_exclude_flags"], { cwd: repo, encoding: "utf8" })
    expect(evaluated.status).toBe(0)
    const exclusions = evaluated.stdout.trim().split(/\s+/)
    expect(spawnSync("rsync", ["-a", ...exclusions, `${source}/`, `${target}/`]).status).toBe(0)
    expect(readFileSync(path.join(target, relative), "utf8")).toBe("user preferences\n")
    expect(readFileSync(path.join(target, ".config/opencode/other.json"), "utf8")).toBe("included\n")
  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})
