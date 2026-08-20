import type { Plugin, PluginModule } from "@opencode-ai/plugin"

interface WaitRequest {
  settle: (reason: "event" | "timeout") => void
  filter: (event: WaitEvent) => boolean
  timeout?: ReturnType<typeof setTimeout>
}

interface WaitEvent {
  type: string
  payload?: unknown
}

interface WaitOptions {
  until?: string
  seconds?: number
}

function matchesFilter(event: { type: string; properties?: unknown }, filter: (e: WaitEvent) => boolean): boolean {
  if (event.type === "tui.toast.show") {
    return filter({ type: "toast", payload: event.properties })
  }

  if (event.type === "message.updated") {
    const props = event.properties as { info?: { role?: string } } | undefined
    if (props?.info?.role === "user") {
      return filter({ type: "user_message", payload: event.properties })
    }
  }

  return filter({ type: event.type, payload: event.properties })
}

function createFilter(until: string): (event: WaitEvent) => boolean {
  switch (until) {
    case "toast":
      return (e) => e.type === "toast"
    case "user_message":
      return (e) => e.type === "user_message"
    case "any":
      return () => true
    default:
      return (e) => e.type === until
  }
}

// Short retention window for the recent-events buffer. This is only meant to
// cover the narrow race where an event is processed in the same tick as (or
// just before) a `wait` call registers, not to replay older history — a
// larger window risks settling a `wait` instantly against a stale, unrelated
// past event.
const EVENT_BUFFER_WINDOW_MS = 100
const EVENT_BUFFER_MAX_LENGTH = 50

const OpencodeWait: Plugin = async ({ client, $ }) => {
  const promiseRegistry = new Map<string, WaitRequest>()
  const recentEvents: Array<{ event: { type: string; properties?: unknown }; timestamp: number; seq: number }> = []
  let eventSeq = 0

  function pruneRecentEvents() {
    const cutoff = Date.now() - EVENT_BUFFER_WINDOW_MS
    while (recentEvents.length && recentEvents[0].timestamp < cutoff) recentEvents.shift()
    while (recentEvents.length > EVENT_BUFFER_MAX_LENGTH) recentEvents.shift()
  }

  function processEvent(event: { type: string; properties?: unknown }) {
    for (const request of promiseRegistry.values()) {
      if (matchesFilter(event, request.filter)) {
        request.settle("event")
      }
    }
  }

  return {
    event: async ({ event }) => {
      const seq = ++eventSeq
      recentEvents.push({ event, timestamp: Date.now(), seq })
      pruneRecentEvents()
      processEvent(event)
    },

    tool: {
      wait: {
        description:
          "Wait/pause execution for a specified time or until a system event occurs. " +
          "Use this INSTEAD OF bash sleep/sleep commands for any waiting needs. " +
          "Supports timed waits (e.g., 300 seconds), waiting for new user messages, " +
          "or waiting for TUI toast notifications. Returns immediately when the event " +
          "occurs or the timeout expires. Always prefer this tool over bash sleep for non-blocking waits.",
        args: {
          until: {
            type: "string",
            description:
              "Event type to wait for: 'toast' (TUI toast), 'user_message' (new user message), " +
              "'any' (any event), or a raw OpenCode event type (e.g. 'session.created', 'session.idle')",
            default: "any",
          },
          seconds: {
            type: "number",
            description:
              "Maximum time to wait in seconds. If 0 or omitted, waits indefinitely until an event occurs.",
            default: 0,
          },
        },
        async execute(args: WaitOptions) {
          const until = args.until ?? "any"
          const seconds = args.seconds ?? 0

          if (!Number.isFinite(seconds) || seconds < 0) {
            return "Error: seconds must be a non-negative finite number"
          }

          // Node's setTimeout takes a 32-bit signed integer delay in milliseconds.
          // Maximum valid delay is 2147483647 ms = 2147483.647 seconds.
          const MAX_SECONDS = 2147483.647
          if (seconds > MAX_SECONDS) {
            return `Error: seconds must not exceed ${MAX_SECONDS} (maximum setTimeout delay)`
          }
          const filter = createFilter(until)

          const id = crypto.randomUUID()
          // Capture the wait registration sequence before any async operations.
          // Only buffered events with a strictly greater sequence number will be
          // eligible for replay, preventing stale events from settling this wait.
          const registeredSeq = eventSeq

          return new Promise<string>((resolve) => {
            let settled = false
            let timeout: ReturnType<typeof setTimeout> | undefined

            const settle = (reason: "event" | "timeout") => {
              if (settled) return
              settled = true
              if (timeout) clearTimeout(timeout)
              promiseRegistry.delete(id)
              resolve(
                reason === "timeout"
                  ? `Wait completed: timed out after ${seconds} seconds`
                  : `Wait completed: received ${until} event`,
              )
            }

            const waitRequest: WaitRequest = { settle, filter }

            // Close the race where a matching event was processed just
            // before this wait registered: replay the recent-events buffer
            // and settle immediately if there's a matching event that arrived
            // after this wait call started (not stale events from before).
            pruneRecentEvents()
            const bufferedMatch = recentEvents.find(
              (entry) => entry.seq > registeredSeq && matchesFilter(entry.event, filter),
            )
            if (bufferedMatch) {
              settle("event")
              return
            }

            if (seconds > 0) {
              timeout = setTimeout(() => settle("timeout"), seconds * 1000)
              waitRequest.timeout = timeout
            }

            promiseRegistry.set(id, waitRequest)
          })
        },
      },
    },
  }
}

export default {
  id: "opencode-wait",
  server: OpencodeWait,
} satisfies PluginModule
