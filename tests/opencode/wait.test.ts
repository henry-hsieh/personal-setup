import { expect, test } from "bun:test"
import { join } from "node:path"

const pluginDir = process.env.OPENCODE_TEST_PLUGIN_DIR ?? join(process.env.HOME!, ".config/opencode/plugins")
const { WaitRuntime } = await import(join(pluginDir, "wait/index.ts"))

function context(sessionID = "s1") {
  const controller = new AbortController()
  return { controller, tool: { sessionID, signal: controller.signal } }
}

function userEvent(sessionID = "s1", inboxID = "msg_0003") {
  return { type: "session.inbox.enqueued", data: { sessionID, inboxID, item: { type: "user" } } }
}

async function remainsPending(promise: Promise<unknown>): Promise<boolean> {
  let settled = false
  void promise.then(() => { settled = true })
  for (let index = 0; index < 4; index += 1) await Promise.resolve()
  return !settled
}

test("validates supported modes and bounded durations", async () => {
  const runtime = new WaitRuntime()
  for (const until of ["any", "session.idle"]) {
    expect(await runtime.wait({ until }, context().tool)).toContain("until")
  }
  for (const seconds of [0, -1, Number.NaN, Number.POSITIVE_INFINITY]) {
    expect(await runtime.wait({ seconds }, context().tool)).toContain("positive")
  }
  expect(await runtime.wait({ seconds: 3600.001 }, context().tool)).toContain("3600")
  expect(await runtime.wait({ seconds: 0.001 }, context().tool)).toBe("Wait completed: timed out after 0.001 seconds")
})

test("new same-session user input interrupts every wait mode", async () => {
  for (const until of ["timeout", "user_message", "toast"]) {
    const runtime = new WaitRuntime()
    const pending = runtime.wait({ until, seconds: 2 }, context().tool)
    runtime.processEvent(userEvent())
    expect(await pending).toBe("Wait completed: received user_message event")
  }
})

test("catches user input queued before registration and forgets delivered input", async () => {
  const runtime = new WaitRuntime()
  runtime.processEvent(userEvent())
  expect(await runtime.wait({ seconds: 1 }, context().tool)).toBe("Wait completed: received user_message event")
  runtime.processEvent({ type: "session.inbox.delivered", data: { sessionID: "s1", inboxID: "msg_0003" } })
  const ctx = context()
  const pending = runtime.wait({ seconds: 2 }, ctx.tool)
  expect(await remainsPending(pending)).toBe(true)
  ctx.controller.abort()
  expect(await pending).toBe("Wait completed: interrupted")
})

test("recovers durable inbox snapshots without resurrecting delivered entries", async () => {
  const runtime = new WaitRuntime()
  runtime.syncPending("s1", ["msg_0003"])
  expect(await runtime.wait({ seconds: 1 }, context().tool)).toBe("Wait completed: received user_message event")

  runtime.processEvent({ type: "session.inbox.delivered", data: { sessionID: "s1", inboxID: "msg_0003" } })
  runtime.syncPending("s1", ["msg_0003"])
  const ctx = context()
  const pending = runtime.wait({ until: "user_message", seconds: 2 }, ctx.tool)
  expect(await remainsPending(pending)).toBe(true)
  ctx.controller.abort()
  expect(await pending).toBe("Wait completed: interrupted")
})

test("cancelled inbox entries and non-user items do not interrupt", async () => {
  const runtime = new WaitRuntime()
  runtime.processEvent(userEvent())
  runtime.processEvent({ type: "session.inbox.cancelled", data: { sessionID: "s1", inboxID: "msg_0003" } })
  runtime.processEvent({
    type: "session.inbox.enqueued",
    data: { sessionID: "s1", inboxID: "msg_0004", item: { type: "synthetic" } },
  })
  const ctx = context()
  const pending = runtime.wait({ seconds: 2 }, ctx.tool)
  expect(await remainsPending(pending)).toBe(true)
  ctx.controller.abort()
  expect(await pending).toBe("Wait completed: interrupted")
})

test("events from another session do not wake a wait", async () => {
  const runtime = new WaitRuntime()
  const ctx = context()
  const pending = runtime.wait({ until: "user_message", seconds: 2 }, ctx.tool)
  runtime.processEvent(userEvent("other"))
  expect(await remainsPending(pending)).toBe(true)
  runtime.processEvent(userEvent())
  expect(await pending).toBe("Wait completed: received user_message event")
})

test("toast wakes only toast waits", async () => {
  const runtime = new WaitRuntime()
  const toast = runtime.wait({ until: "toast", seconds: 2 }, context().tool)
  const timerContext = context("s2")
  const timer = runtime.wait({ until: "timeout", seconds: 2 }, timerContext.tool)
  runtime.processEvent({ type: "tui.toast.show", data: {} })
  expect(await toast).toBe("Wait completed: received toast event")
  expect(await remainsPending(timer)).toBe(true)
  timerContext.controller.abort()
  expect(await timer).toBe("Wait completed: interrupted")
})

test("abort, deletion and disposal settle the appropriate requests", async () => {
  const runtime = new WaitRuntime()
  const preAborted = context()
  preAborted.controller.abort()
  expect(await runtime.wait({}, preAborted.tool)).toBe("Wait completed: interrupted")
  const first = runtime.wait({ seconds: 2 }, context("s1").tool)
  const second = runtime.wait({ seconds: 2 }, context("s2").tool)
  runtime.processEvent({ type: "session.deleted", data: { sessionID: "s1" } })
  expect(await first).toBe("Wait completed: session deleted")
  expect(await remainsPending(second)).toBe(true)
  runtime.dispose()
  expect(await second).toBe("Wait completed: plugin disposed")
  expect(await runtime.wait({}, context().tool)).toBe("Wait completed: plugin disposed")
})
