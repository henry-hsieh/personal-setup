import { expect, test } from "bun:test"
import { join } from "node:path"

const pluginDir = process.env.OPENCODE_TEST_PLUGIN_DIR ?? join(process.env.HOME!, ".config/opencode/plugins")
const { default: WaitPlugin } = await import(join(pluginDir, "wait/index.ts"))

interface EventSource {
  emit(event: unknown): void
  close(): void
  [Symbol.asyncIterator](): AsyncIterator<unknown>
}

function createEventSource(): EventSource {
  const queued: unknown[] = []
  let next: ((result: IteratorResult<unknown>) => void) | undefined
  let closed = false
  return {
    emit(event) {
      if (next) {
        const resolve = next
        next = undefined
        resolve({ value: event, done: false })
      } else {
        queued.push(event)
      }
    },
    close() {
      closed = true
      next?.({ value: undefined, done: true })
      next = undefined
    },
    [Symbol.asyncIterator]() {
      return {
        next() {
          const event = queued.shift()
          if (event !== undefined) return Promise.resolve({ value: event, done: false })
          if (closed) return Promise.resolve({ value: undefined, done: true })
          return new Promise((resolve) => { next = resolve })
        },
      }
    },
  }
}

test("v2 plugin registers wait and resumes it from events and a TUI inbox snapshot", async () => {
  const source = createEventSource()
  let waitTool: { execute(input: unknown, context: unknown): Promise<{ content: string }> } | undefined
  let rpcHandlers: { syncPending(input: unknown): Promise<unknown> } | undefined
  let disposed = false

  const cleanup = await WaitPlugin.setup({
    rpc: {
      register: async (_definition: unknown, handlers: typeof rpcHandlers) => {
        rpcHandlers = handlers
        return { dispose: async () => { disposed = true } }
      },
    },
    event: { subscribe: () => source },
    tool: {
      transform: async (transform: (editor: { add(tool: typeof waitTool): void }) => void) => {
        transform({ add: (tool) => { waitTool = tool } })
      },
    },
  } as never)

  expect(waitTool).toBeDefined()
  const signal = new AbortController().signal
  const pending = waitTool!.execute({ until: "user_message", seconds: 2 }, { sessionID: "s1", signal })
  source.emit({
    type: "session.inbox.enqueued",
    data: { sessionID: "other", inboxID: "msg_0001", item: { type: "user" } },
  })
  source.emit({
    type: "session.inbox.enqueued",
    data: { sessionID: "s1", inboxID: "msg_0002", item: { type: "user" } },
  })
  await expect(pending).resolves.toEqual({ content: "Wait completed: received user_message event" })

  await rpcHandlers!.syncPending({ sessionID: "s2", inboxIDs: ["msg_0003"] })
  await expect(
    waitTool!.execute({ until: "user_message", seconds: 2 }, { sessionID: "s2", signal }),
  ).resolves.toEqual({ content: "Wait completed: received user_message event" })

  await cleanup?.()
  source.close()
  expect(disposed).toBe(true)
})
