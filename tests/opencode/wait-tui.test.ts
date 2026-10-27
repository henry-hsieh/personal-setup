import { expect, test } from "bun:test"
import { join } from "node:path"

const pluginDir = process.env.OPENCODE_TEST_PLUGIN_DIR ?? join(process.env.HOME!, ".config/opencode/plugins")
const { default: WaitTui } = await import(join(pluginDir, "wait/tui.ts"))

test("TUI syncs user inbox entries for the active session family and new sessions", async () => {
  const synced: string[] = []
  const rpcCalls: Array<{ sessionID: string; inboxIDs: string[] }> = []
  const stopHandlers: Array<(event: unknown) => void> = []
  const inbox = new Map([
    ["root", [{ type: "user", id: "msg_root" }, { type: "synthetic", id: "msg_synthetic" }]],
    ["child", [{ type: "user", id: "msg_child" }]],
    ["new", [{ type: "user", id: "msg_new" }]],
  ])

  const context = {
    client: {
      rpc: () => ({
        syncPending: async (input: { sessionID: string; inboxIDs: string[] }) => {
          rpcCalls.push(input)
        },
      }),
    },
    data: {
      on: (_type: string, handler: (event: unknown) => void) => {
        stopHandlers.push(handler)
        return () => undefined
      },
      session: {
        family: () => ["root", "child"],
        pending: {
          sync: async (sessionID: string) => { synced.push(sessionID) },
          list: (sessionID: string) => inbox.get(sessionID) ?? [],
        },
      },
    },
    ui: { router: { current: () => ({ type: "session", sessionID: "root" }) } },
  }

  const cleanup = await WaitTui.setup(context as never)
  expect(synced).toEqual(["root", "child"])
  expect(rpcCalls).toEqual([
    { sessionID: "root", inboxIDs: ["msg_root"] },
    { sessionID: "child", inboxIDs: ["msg_child"] },
  ])

  stopHandlers[0]!({ data: { sessionID: "new" } })
  await new Promise((resolve) => setTimeout(resolve, 0))
  expect(rpcCalls.at(-1)).toEqual({ sessionID: "new", inboxIDs: ["msg_new"] })

  cleanup?.()
})
