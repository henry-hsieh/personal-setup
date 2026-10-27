import { afterEach, expect, test } from "bun:test"
import { mkdtempSync, rmSync, utimesSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import path from "node:path"

const pluginDir = process.env.OPENCODE_TEST_PLUGIN_DIR ?? path.join(process.env.HOME!, ".config/opencode/plugins")
const { KataRuntime } = await import(path.join(pluginDir, "kata/index.ts"))
const { default: KataTui } = await import(path.join(pluginDir, "kata/tui.ts"))

const originalRef = process.env.KATA_REF
const temporaryDirectories: string[] = []

afterEach(() => {
  if (originalRef === undefined) delete process.env.KATA_REF
  else process.env.KATA_REF = originalRef
  for (const directory of temporaryDirectories.splice(0)) rmSync(directory, { recursive: true, force: true })
})

function workspace(): string {
  const directory = mkdtempSync(path.join(tmpdir(), "kata-v2-"))
  temporaryDirectories.push(directory)
  writeFileSync(path.join(directory, ".kata.toml"), "")
  return directory
}

test("attention starts on each reference's first session and ends on its last", async () => {
  const calls: Array<{ args: string[]; reference: string }> = []
  const runtime = new KataRuntime("kata-test", async (_binary, args, options) => {
    calls.push({ args, reference: options.reference })
    return ""
  })

  await runtime.setSessionContext("s1", { reference: "task-a" })
  await runtime.setSessionContext("s2", { reference: "task-a" })
  await runtime.setSessionContext("s3", { reference: "task-b" })
  expect(calls.filter(({ args }) => args.join(" ") === "attention-hook start")).toHaveLength(2)

  await runtime.removeSession("s1")
  expect(calls.filter(({ args }) => args.join(" ") === "attention-hook end")).toHaveLength(0)
  await runtime.removeSession("s2")
  expect(calls.filter(({ args }) => args.join(" ") === "attention-hook end")).toEqual([
    { args: ["attention-hook", "end"], reference: "task-a" },
  ])
  await runtime.removeSession("s3")
  expect(calls.filter(({ args }) => args.join(" ") === "attention-hook end")).toHaveLength(2)
})

test("context uses the session reference and caches by workspace config", async () => {
  const directory = workspace()
  const quickstarts: string[] = []
  const runtime = new KataRuntime("kata-test", async (_binary, args, options) => {
    if (args[0] === "quickstart") {
      quickstarts.push(options.reference)
      return `CONTRACT-${options.reference}`
    }
    return ""
  })
  await runtime.setSessionContext("s1", { reference: "task-a" })
  await runtime.setSessionContext("s2", { reference: "task-b" })

  const output = (sessionID: string) => {
    const system: string[] = []
    return runtime.injectContract(sessionID, directory, (text) => system.push(text)).then(() => system)
  }

  expect(await output("s1")).toEqual(["CONTRACT-task-a"])
  expect(await output("s1")).toEqual(["CONTRACT-task-a"])
  expect(await output("s2")).toEqual(["CONTRACT-task-b"])
  expect(quickstarts).toEqual(["task-a", "task-b"])

  const future = new Date(Date.now() + 60_000)
  utimesSync(path.join(directory, ".kata.toml"), future, future)
  expect(await output("s1")).toEqual(["CONTRACT-task-a"])
  expect(quickstarts).toHaveLength(3)

  rmSync(path.join(directory, ".kata.toml"))
  expect(await output("s1")).toEqual([])
})

test("empty contract output is retried and sessions without a reference are untouched", async () => {
  const directory = workspace()
  let attempts = 0
  const runtime = new KataRuntime("kata-test", async (_binary, args) => {
    if (args[0] !== "quickstart") return ""
    attempts += 1
    return attempts === 1 ? "" : "CONTRACT"
  })
  await runtime.setSessionContext("s1", { reference: "task-a" })

  const collect = async (sessionID: string) => {
    const system: string[] = []
    await runtime.injectContract(sessionID, directory, (text) => system.push(text))
    return system
  }
  expect(await collect("unknown")).toEqual([])
  expect(await collect("s1")).toEqual([])
  expect(await collect("s1")).toEqual(["CONTRACT"])
  expect(attempts).toBe(2)
})

test("TUI associates the current session family and new same-location sessions", async () => {
  const previousRef = process.env.KATA_REF
  process.env.KATA_REF = "task-current"
  const calls: Array<{ sessionID: string; reference: string }> = []
  let createdHandler: ((event: unknown) => void) | undefined
  let stopped = false
  const context = {
    client: {
      rpc: () => ({
        setSessionContext: async (input: { sessionID: string; reference: string }) => {
          calls.push(input)
        },
      }),
    },
    location: { directory: "/workspace" },
    data: {
      on: (type: string, handler: (event: unknown) => void) => {
        expect(type).toBe("session.created")
        createdHandler = handler
        return () => { stopped = true }
      },
      session: { family: () => ["root", "child"] },
    },
    ui: { router: { current: () => ({ type: "session", sessionID: "root" }) } },
  }

  try {
    const cleanup = await KataTui.setup(context as never)
    expect(calls).toEqual([
      { sessionID: "root", reference: "task-current" },
      { sessionID: "child", reference: "task-current" },
    ])

    createdHandler!({
      location: { directory: "/workspace" },
      data: { sessionID: "new-session" },
    })
    createdHandler!({
      location: { directory: "/other" },
      data: { sessionID: "other-session" },
    })
    await new Promise((resolve) => setTimeout(resolve, 0))
    expect(calls.at(-1)).toEqual({ sessionID: "new-session", reference: "task-current" })
    expect(calls).toHaveLength(3)

    cleanup?.()
    expect(stopped).toBe(true)
  } finally {
    if (previousRef === undefined) delete process.env.KATA_REF
    else process.env.KATA_REF = previousRef
  }
})
