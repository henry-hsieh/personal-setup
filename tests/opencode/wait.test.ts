import { expect, test } from "bun:test"
import type { Hooks, PluginInput, ToolContext } from "@opencode-ai/plugin"

const CURRENT_MESSAGE_ID = "msg_0002"

type WaitMode = "timeout" | "user_message" | "toast"

interface MessageFixture {
  info: {
    id: string
    role: "user" | "assistant"
    sessionID: string
    time: { created: number; completed?: number }
  }
}

interface MessagesRequest {
  path: { id: string }
  query?: { limit?: number }
}

interface SetupOptions {
  messages?: MessageFixture[]
  messagesResponse?: Promise<{ data: MessageFixture[] }>
  onMessagesQuery?: (request: MessagesRequest) => void
}

interface TestContext {
  tool: ToolContext
  controller: AbortController
}

interface WaitDefinition {
  args: { until: { enum: readonly WaitMode[] } }
  execute(args: { until?: string; seconds?: number }, context: ToolContext): Promise<string>
}

interface TestEvent {
  type: string
  properties?: unknown
}

type SessionClient = PluginInput["client"]["session"]
type PluginEvent = Parameters<NonNullable<Hooks["event"]>>[0]["event"]

function history(queued = false): MessageFixture[] {
  const olderUser: MessageFixture = {
    info: { id: "msg_0001", role: "user", sessionID: "s1", time: { created: 1 } },
  }
  const currentAssistant: MessageFixture = {
    info: { id: CURRENT_MESSAGE_ID, role: "assistant", sessionID: "s1", time: { created: 2 } },
  }
  const queuedUser: MessageFixture = {
    info: { id: "msg_0003", role: "user", sessionID: "s1", time: { created: 3 } },
  }
  return queued ? [olderUser, currentAssistant, queuedUser] : [olderUser, currentAssistant]
}

async function setup(options: SetupOptions = {}): Promise<Hooks> {
  const messages = options.messages ?? history()
  const messagesResponse = options.messagesResponse ?? Promise.resolve({ data: messages })
  const client = {
    session: {
      messages: (async (request: MessagesRequest) => {
        options.onMessagesQuery?.(request)
        return messagesResponse
      }) as unknown as SessionClient["messages"],
    },
  }
  const waitModule = await import("../../src/settings/.config/opencode/plugins/wait/opencode-wait.ts")
  return waitModule.OpencodeWait({ client: client as unknown as PluginInput["client"] } as PluginInput)
}

function context(sessionID = "s1", messageID = CURRENT_MESSAGE_ID): TestContext {
  const controller = new AbortController()
  const tool: ToolContext = {
    sessionID,
    messageID,
    agent: "build",
    directory: process.cwd(),
    worktree: process.cwd(),
    abort: controller.signal,
    metadata() {},
    async ask() {},
  }
  return { tool, controller }
}

function waitDefinition(hooks: Hooks): WaitDefinition {
  return hooks.tool!.wait as unknown as WaitDefinition
}

async function emit(hooks: Hooks, event: TestEvent): Promise<void> {
  await hooks.event!({ event: event as PluginEvent })
}

async function remainsPending(promise: Promise<unknown>): Promise<boolean> {
  let settled = false
  void promise.finally(() => {
    settled = true
  })
  for (let index = 0; index < 4; index += 1) await Promise.resolve()
  return !settled
}

async function captureTimeout(action: () => Promise<string>): Promise<{ result: string; delay: number }> {
  const originalSetTimeout = globalThis.setTimeout
  let delay = -1
  globalThis.setTimeout = ((callback: Parameters<typeof setTimeout>[0], milliseconds?: number, ...args: unknown[]) => {
    delay = milliseconds ?? 0
    queueMicrotask(() => (callback as (...values: unknown[]) => void)(...args))
    return 0 as unknown as ReturnType<typeof setTimeout>
  }) as typeof setTimeout
  try {
    return { result: await action(), delay }
  } finally {
    globalThis.setTimeout = originalSetTimeout
  }
}

async function runQueuePeek(action: () => Promise<string>): Promise<{ result: string; delay: number }> {
  const originalSetTimeout = globalThis.setTimeout
  const originalClearTimeout = globalThis.clearTimeout
  const timers: Array<{ callback: () => void; delay: number }> = []
  globalThis.setTimeout = ((callback: Parameters<typeof setTimeout>[0], milliseconds?: number, ...args: unknown[]) => {
    timers.push({
      callback: () => (callback as (...values: unknown[]) => void)(...args),
      delay: milliseconds ?? 0,
    })
    return timers.length as unknown as ReturnType<typeof setTimeout>
  }) as typeof setTimeout
  globalThis.clearTimeout = (() => undefined) as typeof clearTimeout
  try {
    const promise = action()
    for (let index = 0; index < 4; index += 1) await Promise.resolve()
    const queuePeek = timers.find((timer) => timer.delay === 5_000)
    if (!queuePeek) throw new Error("queue peek timer was not scheduled")
    queuePeek.callback()
    return { result: await promise, delay: queuePeek.delay }
  } finally {
    globalThis.setTimeout = originalSetTimeout
    globalThis.clearTimeout = originalClearTimeout
  }
}

test("publishes only the supported wait modes", async () => {
  const wait = waitDefinition(await setup())
  expect(wait.args.until.enum).toEqual(["timeout", "user_message", "toast"])
})

test("rejects unsupported wait modes", async () => {
  const wait = waitDefinition(await setup())
  expect(await wait.execute({ until: "any", seconds: 1 }, context().tool)).toContain("until")
  expect(await wait.execute({ until: "session.idle", seconds: 1 }, context().tool)).toContain("until")
})

test("rejects invalid timeout values", async () => {
  const wait = waitDefinition(await setup())
  for (const seconds of [0, -1, Number.NaN, Number.POSITIVE_INFINITY, Number.NEGATIVE_INFINITY]) {
    expect(await wait.execute({ until: "timeout", seconds }, context().tool)).toContain("positive")
  }
  expect(await wait.execute({ until: "timeout", seconds: 3600.001 }, context().tool)).toContain("3600")
})

test("uses the default duration when arguments are omitted", async () => {
  const wait = waitDefinition(await setup())
  const captured = await captureTimeout(() => wait.execute({}, context().tool))
  expect(captured).toEqual({ result: "Wait completed: timed out after 300 seconds", delay: 300_000 })
})

test("accepts positive and maximum timeout values", async () => {
  const wait = waitDefinition(await setup())
  const positive = await captureTimeout(() => wait.execute({ until: "timeout", seconds: 1.25 }, context().tool))
  expect(positive).toEqual({ result: "Wait completed: timed out after 1.25 seconds", delay: 1_250 })

  const maximum = await captureTimeout(() => wait.execute({ until: "timeout", seconds: 3600 }, context().tool))
  expect(maximum).toEqual({ result: "Wait completed: timed out after 3600 seconds", delay: 3_600_000 })
})

test("detects queued users in the V1 history page", async () => {
  const requests: MessagesRequest[] = []
  const wait = waitDefinition(
    await setup({ messages: history(true), onMessagesQuery: (request) => requests.push(request) }),
  )
  const result = await runQueuePeek(() => wait.execute({ until: "timeout", seconds: 6 }, context().tool))
  expect(result).toEqual({ result: "Wait completed: received user_message event", delay: 5_000 })
  expect(requests[0]).toEqual({ path: { id: "s1" }, query: { limit: 100 } })
})

test("uses the bounded ID fallback without fetching the current message", async () => {
  const requests: MessagesRequest[] = []
  const messages: MessageFixture[] = [
    { info: { id: "msg_0001", role: "user", sessionID: "s1", time: { created: 1 } } },
    { info: { id: "msg_0003", role: "user", sessionID: "s1", time: { created: 3 } } },
  ]
  const wait = waitDefinition(await setup({ messages, onMessagesQuery: (request) => requests.push(request) }))
  const result = await runQueuePeek(() => wait.execute({ until: "timeout", seconds: 6 }, context().tool))
  expect(result.result).toBe("Wait completed: received user_message event")
  expect(requests).toHaveLength(1)
})

test("matches the TUI pending boundary with concurrent assistants", async () => {
  const messages: MessageFixture[] = [
    { info: { id: "msg_0001", role: "user", sessionID: "s1", time: { created: 1 } } },
    { info: { id: CURRENT_MESSAGE_ID, role: "assistant", sessionID: "s1", time: { created: 2 } } },
    { info: { id: "msg_0003", role: "user", sessionID: "s1", time: { created: 3 } } },
    { info: { id: "msg_0004", role: "assistant", sessionID: "s1", time: { created: 4 } } },
    { info: { id: "msg_0005", role: "user", sessionID: "s1", time: { created: 5 } } },
  ]
  const wait = waitDefinition(await setup({ messages }))
  const result = await runQueuePeek(() => wait.execute({ until: "timeout", seconds: 6 }, context().tool))
  expect(result.result).toBe("Wait completed: received user_message event")
})

test("does not queue a user before the latest incomplete assistant", async () => {
  const messages: MessageFixture[] = [
    { info: { id: "msg_0001", role: "user", sessionID: "s1", time: { created: 1 } } },
    { info: { id: CURRENT_MESSAGE_ID, role: "assistant", sessionID: "s1", time: { created: 2 } } },
    { info: { id: "msg_0003", role: "user", sessionID: "s1", time: { created: 3 } } },
    { info: { id: "msg_0004", role: "assistant", sessionID: "s1", time: { created: 4 } } },
  ]
  const wait = waitDefinition(await setup({ messages }))
  const result = await captureTimeout(() => wait.execute({ until: "timeout", seconds: 2 }, context().tool))
  expect(result.result).toBe("Wait completed: timed out after 2 seconds")
})

test("does not treat older user messages as queued", async () => {
  const hooks = await setup({ messages: history(false) })
  const ctx = context()
  const pending = waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, ctx.tool)
  expect(await remainsPending(pending)).toBe(true)
  ctx.controller.abort()
  expect(await pending).toBe("Wait completed: interrupted")
})

test("new current-session users interrupt every wait mode", async () => {
  for (const until of ["timeout", "user_message", "toast"] as const) {
    const hooks = await setup()
    const pending = waitDefinition(hooks).execute({ until, seconds: 2 }, context().tool)
    await emit(hooks, {
      type: "message.updated",
      properties: { info: { id: "msg_0003", role: "user", sessionID: "s1" } },
    })
    expect(await pending).toBe("Wait completed: received user_message event")
  }
})

test("accepts the session ID from the event properties", async () => {
  const hooks = await setup()
  const pending = waitDefinition(hooks).execute({ until: "user_message", seconds: 2 }, context().tool)
  await emit(hooks, {
    type: "message.updated",
    properties: { sessionID: "s1", info: { id: "msg_0003", role: "user" } },
  })
  expect(await pending).toBe("Wait completed: received user_message event")
})

test("updates the pending boundary when an assistant is removed", async () => {
  const hooks = await setup()
  const pending = waitDefinition(hooks).execute({ until: "user_message", seconds: 2 }, context().tool)
  await emit(hooks, {
    type: "message.updated",
    properties: { sessionID: "s1", info: { id: "msg_0004", role: "assistant" } },
  })
  await emit(hooks, {
    type: "message.updated",
    properties: { sessionID: "s1", info: { id: "msg_0003", role: "user" } },
  })
  expect(await remainsPending(pending)).toBe(true)
  await emit(hooks, {
    type: "message.removed",
    properties: { sessionID: "s1", messageID: "msg_0004" },
  })
  expect(await pending).toBe("Wait completed: received user_message event")
})

test("uses the latest incomplete assistant for concurrent waits", async () => {
  const hooks = await setup()
  const first = waitDefinition(hooks).execute({ until: "user_message", seconds: 2 }, context("s1", "msg_0002").tool)
  const second = waitDefinition(hooks).execute({ until: "user_message", seconds: 2 }, context("s1", "msg_0004").tool)
  await emit(hooks, {
    type: "message.updated",
    properties: { sessionID: "s1", info: { id: "msg_0003", role: "user" } },
  })
  expect(await remainsPending(first)).toBe(true)
  expect(await remainsPending(second)).toBe(true)
  await emit(hooks, {
    type: "message.updated",
    properties: { sessionID: "s1", info: { id: "msg_0005", role: "user" } },
  })
  expect(await first).toBe("Wait completed: received user_message event")
  expect(await second).toBe("Wait completed: received user_message event")
})

test("ignores stale and other-session user events", async () => {
  const hooks = await setup()
  const ctx = context()
  const pending = waitDefinition(hooks).execute({ until: "user_message", seconds: 2 }, ctx.tool)
  await emit(hooks, {
    type: "message.updated",
    properties: { info: { id: "msg_0003", role: "user", sessionID: "other" } },
  })
  await emit(hooks, {
    type: "message.updated",
    properties: { info: { id: "msg_0001", role: "user", sessionID: "s1" } },
  })
  await emit(hooks, {
    type: "message.updated",
    properties: { info: { role: "user", sessionID: "s1" } },
  })
  expect(await remainsPending(pending)).toBe(true)
  ctx.controller.abort()
  expect(await pending).toBe("Wait completed: interrupted")
})

test("registers before the queued-history request completes", async () => {
  let resolveHistory: (value: { data: MessageFixture[] }) => void = () => undefined
  const messagesResponse = new Promise<{ data: MessageFixture[] }>((resolve) => {
    resolveHistory = resolve
  })
  const hooks = await setup({ messagesResponse })
  const pending = waitDefinition(hooks).execute({ until: "user_message", seconds: 2 }, context().tool)
  await emit(hooks, {
    type: "message.updated",
    properties: { info: { id: "msg_0003", role: "user", sessionID: "s1" } },
  })
  expect(await pending).toBe("Wait completed: received user_message event")
  resolveHistory({ data: history(false) })
})

test("toasts wake only toast waits", async () => {
  const hooks = await setup()
  const toast = waitDefinition(hooks).execute({ until: "toast", seconds: 2 }, context().tool)
  const timerContext = context()
  const timer = waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, timerContext.tool)
  await emit(hooks, { type: "tui.toast.show", properties: { message: "ok" } })
  expect(await toast).toBe("Wait completed: received toast event")
  expect(await remainsPending(timer)).toBe(true)
  timerContext.controller.abort()
  expect(await timer).toBe("Wait completed: interrupted")
})

test("pre-aborted and active requests settle on interruption", async () => {
  const hooks = await setup()
  const preAborted = context()
  preAborted.controller.abort()
  expect(await waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, preAborted.tool)).toBe(
    "Wait completed: interrupted",
  )

  const active = context()
  const pending = waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, active.tool)
  active.controller.abort()
  expect(await pending).toBe("Wait completed: interrupted")
})

test("session deletion settles only that session's waits", async () => {
  const hooks = await setup()
  const first = waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, context("s1").tool)
  const secondContext = context("s2")
  const second = waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, secondContext.tool)
  await emit(hooks, { type: "session.deleted", properties: { info: { id: "s1" } } })
  expect(await first).toBe("Wait completed: session deleted")
  expect(await remainsPending(second)).toBe(true)
  secondContext.controller.abort()
  expect(await second).toBe("Wait completed: interrupted")
})

test("disposal settles every pending wait", async () => {
  const hooks = await setup()
  const first = waitDefinition(hooks).execute({ until: "timeout", seconds: 2 }, context("s1").tool)
  const second = waitDefinition(hooks).execute({ until: "toast", seconds: 2 }, context("s2").tool)
  await hooks.dispose!()
  expect(await first).toBe("Wait completed: plugin disposed")
  expect(await second).toBe("Wait completed: plugin disposed")
})
