import { Plugin } from "@opencode/plugin"
import type { ToolContext } from "@opencode/plugin/promise/tool"
import { WaitRpc } from "./rpc"

const WAIT_MODES = ["timeout", "user_message", "toast"] as const
const DEFAULT_SECONDS = 300
const MAX_SECONDS = 3600

type WaitMode = (typeof WAIT_MODES)[number]
type WaitReason = "user_message" | "toast" | "timeout" | "aborted" | "session_deleted" | "disposed"

interface WaitOptions {
  until?: string
  seconds?: number
}

interface WaitRequest {
  sessionID: string
  until: WaitMode
  settle: (reason: WaitReason) => void
}

interface WaitEvent {
  type: string
  data?: {
    message?: string
    sessionID?: string
    inboxID?: string
    item?: { type?: string }
  }
}

/** Track v2's pending user inbox entries independently for each session. */
export class WaitRuntime {
  private readonly requests = new Set<WaitRequest>()
  private readonly pending = new Map<string, Set<string>>()
  private readonly closed = new Map<string, Set<string>>()
  private disposed = false

  processEvent(event: WaitEvent): void {
    const sessionID = event.data?.sessionID
    const inboxID = event.data?.inboxID
    if (event.type === "session.inbox.enqueued" && sessionID && inboxID && event.data?.item?.type === "user") {
      let entries = this.pending.get(sessionID)
      if (!entries) {
        entries = new Set()
        this.pending.set(sessionID, entries)
      }
      entries.add(inboxID)
    } else if (
      (event.type === "session.inbox.delivered" || event.type === "session.inbox.cancelled") &&
      sessionID &&
      inboxID
    ) {
      const entries = this.pending.get(sessionID)
      entries?.delete(inboxID)
      if (entries?.size === 0) this.pending.delete(sessionID)
      let closed = this.closed.get(sessionID)
      if (!closed) {
        closed = new Set()
        this.closed.set(sessionID, closed)
      }
      closed.add(inboxID)
      if (closed.size > 1000) closed.delete(closed.values().next().value!)
    } else if (event.type === "session.deleted" && sessionID) {
      this.pending.delete(sessionID)
      this.closed.delete(sessionID)
    }

    for (const request of this.requests) {
      if (
        event.type === "session.inbox.enqueued" &&
        event.data?.item?.type === "user" &&
        sessionID === request.sessionID
      ) {
        request.settle("user_message")
      } else if (event.type === "tui.toast.show" && request.until === "toast") {
        request.settle("toast")
      } else if (event.type === "session.deleted" && sessionID === request.sessionID) {
        request.settle("session_deleted")
      }
    }
  }

  /** Merge a TUI snapshot to recover inbox items that predate server startup. */
  syncPending(sessionID: string, inboxIDs: string[]): void {
    if (this.disposed) return
    const entries = this.pending.get(sessionID) ?? new Set<string>()
    const closed = this.closed.get(sessionID)
    for (const inboxID of inboxIDs) {
      if (!closed?.has(inboxID)) entries.add(inboxID)
    }
    if (entries.size === 0) {
      this.pending.delete(sessionID)
      return
    }
    this.pending.set(sessionID, entries)
    for (const request of this.requests) {
      if (request.sessionID === sessionID) request.settle("user_message")
    }
  }

  async wait(args: WaitOptions, context: Pick<ToolContext, "sessionID" | "signal">): Promise<string> {
    const until = args.until ?? "timeout"
    const seconds = args.seconds ?? DEFAULT_SECONDS
    if (!WAIT_MODES.includes(until as WaitMode)) return `Error: until must be one of: ${WAIT_MODES.join(", ")}`
    if (!Number.isFinite(seconds) || seconds <= 0) return "Error: seconds must be a positive finite number"
    if (seconds > MAX_SECONDS) return `Error: seconds must not exceed ${MAX_SECONDS}`
    if (this.disposed) return "Wait completed: plugin disposed"
    if (context.signal.aborted) return "Wait completed: interrupted"

    return new Promise<string>((resolve) => {
      let settled = false
      let timeout: ReturnType<typeof setTimeout> | undefined
      const request: WaitRequest = { sessionID: context.sessionID, until: until as WaitMode, settle }
      const abort = () => settle("aborted")

      function settle(reason: WaitReason): void {
        if (settled) return
        settled = true
        if (timeout !== undefined) clearTimeout(timeout)
        context.signal.removeEventListener("abort", abort)
        runtime.requests.delete(request)
        switch (reason) {
          case "user_message":
          case "toast":
            resolve(`Wait completed: received ${reason} event`)
            break
          case "timeout":
            resolve(`Wait completed: timed out after ${seconds} seconds`)
            break
          case "aborted":
            resolve("Wait completed: interrupted")
            break
          case "session_deleted":
            resolve("Wait completed: session deleted")
            break
          case "disposed":
            resolve("Wait completed: plugin disposed")
            break
        }
      }

      const runtime = this
      this.requests.add(request)
      context.signal.addEventListener("abort", abort, { once: true })
      if (context.signal.aborted) {
        settle("aborted")
      } else if (this.pending.get(context.sessionID)?.size) {
        settle("user_message")
      } else {
        timeout = setTimeout(() => settle("timeout"), seconds * 1000)
      }
    })
  }

  dispose(): void {
    this.disposed = true
    for (const request of [...this.requests]) request.settle("disposed")
    this.pending.clear()
    this.closed.clear()
  }
}

export default Plugin.define({
  id: "opencode-wait",
  async setup(ctx) {
    const runtime = new WaitRuntime()
    const controller = new AbortController()
    const rpc = await ctx.rpc.register(WaitRpc, {
      syncPending: async (input) => {
        const { sessionID, inboxIDs } = input as { sessionID: string; inboxIDs: string[] }
        runtime.syncPending(sessionID, inboxIDs)
        return {}
      },
    })
    const events = ctx.event.subscribe({
      signal: controller.signal,
      types: [
        "session.inbox.enqueued",
        "session.inbox.delivered",
        "session.inbox.cancelled",
        "session.deleted",
        "tui.toast.show",
      ],
    })
    void (async () => {
      try {
        for await (const event of events) runtime.processEvent(event)
      } catch (error) {
        if (!controller.signal.aborted) console.error("[opencode-wait] event subscription failed:", error)
        runtime.dispose()
      }
    })()

    await ctx.tool.transform((editor) => {
      editor.add({
        name: "wait",
        description:
          "Pause until a bounded timeout, a current-session user message, or a TUI toast. " +
          "Current-session user messages always interrupt the wait, including timeout and toast waits. " +
          "Use this instead of shell sleep commands when no other useful work is available.",
        input: {
          type: "object",
          properties: {
            until: { type: "string", enum: WAIT_MODES, default: "timeout" },
            seconds: { type: "number", exclusiveMinimum: 0, maximum: MAX_SECONDS, default: DEFAULT_SECONDS },
          },
          additionalProperties: false,
        },
        options: { codemode: false },
        execute: async (input, context) => ({ content: await runtime.wait(input as WaitOptions, context) }),
      })
    })
    return () => {
      controller.abort()
      runtime.dispose()
      void rpc.dispose()
    }
  },
})
