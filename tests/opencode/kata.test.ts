import { test, expect, afterEach } from "bun:test"
import { mkdtempSync, writeFileSync, unlinkSync } from "node:fs"
import { tmpdir } from "node:os"
import path from "node:path"

// Attention path requires KATA_REF at module load time.
process.env.KATA_REF = "abc4"
const { KataPlugin } = await import(
  "../../src/settings/.config/opencode/plugins/kata/kata.ts"
)

// Several tests mutate process-wide env (OPENCODE_PROJECT_DIR). Restore it
// after each test so a test never observes another test's workspace even if
// bun is later run with --concurrent.
const ORIGINAL_ENV = {
  KATA_REF: process.env.KATA_REF,
  OPENCODE_PROJECT_DIR: process.env.OPENCODE_PROJECT_DIR,
}
afterEach(() => {
  for (const key of ["KATA_REF", "OPENCODE_PROJECT_DIR"] as const) {
    const value = ORIGINAL_ENV[key]
    if (value === undefined) delete process.env[key]
    else process.env[key] = value
  }
})

function fakeShell(onCmd?: (cmd: string) => string) {
  const calls: string[] = []
  const tagged = (strings: TemplateStringsArray, ...values: unknown[]) => {
    const cmd = strings
      .reduce((a, s, i) => a + s + (i < values.length ? String(values[i]) : ""), "")
      .trim()
    calls.push(cmd)
    const stdout = onCmd ? onCmd(cmd) : ""
    const chainable: any = {
      quiet() {
        return chainable
      },
      nothrow() {
        return chainable
      },
      then(resolve: (v: any) => void) {
        resolve({ stdout, stderr: "", exitCode: 0 })
      },
    }
    return chainable
  }
  return { tagged: tagged as any, calls }
}

const client: any = {
  app: { log: async () => ({}) },
  session: { list: async () => ({ data: [] }) },
}

test("attention: start on first session, end on last, dedupes multiples", async () => {
  const { tagged, calls } = fakeShell()
  const hooks = await KataPlugin({ client, $: tagged })

  await hooks.event!({ event: { type: "session.created", properties: { info: { id: "s1" } } } })
  expect(calls.filter((c) => c.includes("attention-hook start"))).toHaveLength(1)

  await hooks.event!({ event: { type: "session.created", properties: { info: { id: "s2" } } } })
  expect(calls.filter((c) => c.includes("attention-hook start"))).toHaveLength(1)

  await hooks.event!({ event: { type: "session.deleted", properties: { info: { id: "s1" } } } })
  expect(calls.filter((c) => c.includes("attention-hook end"))).toHaveLength(0)

  await hooks.event!({ event: { type: "session.deleted", properties: { info: { id: "s2" } } } })
  expect(calls.filter((c) => c.includes("attention-hook end"))).toHaveLength(1)
})

test("contract: injected when .kata.toml present, cached across calls, absent otherwise", async () => {
  const withToml = mkdtempSync(path.join(tmpdir(), "kata-"))
  writeFileSync(path.join(withToml, ".kata.toml"), "")
  const withoutToml = mkdtempSync(path.join(tmpdir(), "kata-no-"))

  const quickstartCalls: string[] = []
  const { tagged } = fakeShell((cmd) => {
    if (cmd.includes("quickstart")) quickstartCalls.push(cmd)
    return "CONTRACT-BODY"
  })
  const hooks = await KataPlugin({ client, $: tagged })

  process.env.OPENCODE_PROJECT_DIR = withToml
  const out1 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "x", model: {} as any }, out1)
  expect(out1.system).toEqual(["CONTRACT-BODY"])
  expect(quickstartCalls).toHaveLength(1)

  const out2 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "y", model: {} as any }, out2)
  expect(out2.system).toEqual(["CONTRACT-BODY"])
  expect(quickstartCalls).toHaveLength(1)

  process.env.OPENCODE_PROJECT_DIR = withoutToml
  const out3 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "z", model: {} as any }, out3)
  expect(out3.system).toEqual([])
  expect(quickstartCalls).toHaveLength(1)
})

test("contract refresh when .kata.toml changes", async () => {
  const dir = mkdtempSync(path.join(tmpdir(), "kata-refresh-"))
  writeFileSync(path.join(dir, ".kata.toml"), "")
  process.env.OPENCODE_PROJECT_DIR = dir

  const quickstartCalls: string[] = []
  const { tagged } = fakeShell((cmd) => {
    if (cmd.includes("quickstart")) quickstartCalls.push(cmd)
    return "CONTRACT-BODY"
  })
  const hooks = await KataPlugin({ client, $: tagged })

  const out1 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "x", model: {} as any }, out1)
  expect(quickstartCalls).toHaveLength(1)

  // touch .kata.toml into the future so mtime changes
  const future = new Date(Date.now() + 60_000)
  require("node:fs").utimesSync(path.join(dir, ".kata.toml"), future, future)
  const out2 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "y", model: {} as any }, out2)
  expect(quickstartCalls).toHaveLength(2)
})

test("attention: missing properties does not throw and starts nothing", async () => {
  const { tagged, calls } = fakeShell()
  const hooks = await KataPlugin({ client, $: tagged })
  const startsBefore = calls.filter((c) => c.includes("attention-hook start")).length
  await expect(
    hooks.event!({ event: { type: "session.created", properties: undefined } }),
  ).resolves.toBeUndefined()
  // no extra start beyond the init-time one
  expect(calls.filter((c) => c.includes("attention-hook start"))).toHaveLength(startsBefore)
})

test("contract: empty quickstart result is retried, not cached", async () => {
  const withToml = mkdtempSync(path.join(tmpdir(), "kata-empty-"))
  writeFileSync(path.join(withToml, ".kata.toml"), "")
  process.env.OPENCODE_PROJECT_DIR = withToml

  const quickstartCalls: string[] = []
  const { tagged } = fakeShell((cmd) => {
    if (cmd.includes("quickstart")) quickstartCalls.push(cmd)
    return ""
  })
  const hooks = await KataPlugin({ client, $: tagged })

  const out1 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "x", model: {} as any }, out1)
  const out2 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "y", model: {} as any }, out2)
  expect(out1.system).toEqual([])
  expect(out2.system).toEqual([])
  expect(quickstartCalls).toHaveLength(2)
})

test("attention: failed session.list does not cause false end on untracked delete", async () => {
  const { tagged, calls } = fakeShell()
  const failingClient: any = {
    app: { log: async () => ({}) },
    session: { list: async () => { throw new Error("boom") } },
  }
  const hooks = await KataPlugin({ client: failingClient, $: tagged })
  const startsBefore = calls.filter((c) => c.includes("attention-hook start")).length
  // a real session arriving still starts attention
  await hooks.event!({ event: { type: "session.created", properties: { info: { id: "s1" } } } })
  expect(calls.filter((c) => c.includes("attention-hook start"))).toHaveLength(startsBefore + 1)
  // deleting an untracked (unseeded) session must NOT end attention
  await hooks.event!({ event: { type: "session.deleted", properties: { info: { id: "ghost" } } } })
  expect(calls.filter((c) => c.includes("attention-hook end"))).toHaveLength(0)
  // deleting the real one does end it
  await hooks.event!({ event: { type: "session.deleted", properties: { info: { id: "s1" } } } })
  expect(calls.filter((c) => c.includes("attention-hook end"))).toHaveLength(1)
})

test("contract: stops injecting after .kata.toml is removed", async () => {
  const dir = mkdtempSync(path.join(tmpdir(), "kata-rm-"))
  const toml = path.join(dir, ".kata.toml")
  writeFileSync(toml, "")
  process.env.OPENCODE_PROJECT_DIR = dir
  const { tagged } = fakeShell((cmd) => (cmd.includes("quickstart") ? "CONTRACT" : ""))
  const hooks = await KataPlugin({ client, $: tagged })

  const out1 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "x", model: {} as any }, out1)
  expect(out1.system).toEqual(["CONTRACT"])

  unlinkSync(toml)
  const out2 = { system: [] as string[] }
  await hooks["experimental.chat.system.transform"]!({ sessionID: "y", model: {} as any }, out2)
  expect(out2.system).toEqual([])
})
