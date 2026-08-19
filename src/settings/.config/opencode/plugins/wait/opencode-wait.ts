import type { Plugin, PluginModule } from "@opencode-ai/plugin"

interface WaitRequest {
  resolve: (value: void) => void
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

const OpencodeWait: Plugin = async ({ client, $ }) => {
  const promiseRegistry = new Map<string, WaitRequest>()

  function processEvent(event: { type: string; properties?: unknown }) {
    const toDelete: string[] = []

    for (const [id, request] of promiseRegistry) {
      if (matchesFilter(event, request.filter)) {
        if (request.timeout) clearTimeout(request.timeout)
        request.resolve()
        toDelete.push(id)
      }
    }

    for (const id of toDelete) {
      promiseRegistry.delete(id)
    }
  }

  return {
    event: async ({ event }) => {
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

          if (seconds < 0) {
            return "Error: seconds must be non-negative"
          }
          const filter = createFilter(until)

          const id = crypto.randomUUID()

          return new Promise<string>((resolve, reject) => {
            let timeout: ReturnType<typeof setTimeout> | undefined

            const cleanup = () => {
              if (timeout) clearTimeout(timeout)
              promiseRegistry.delete(id)
            }

            const waitRequest: WaitRequest = {
              resolve: () => {
                cleanup()
                resolve(`Wait completed: received ${until} event`)
              },
              filter,
            }

            if (seconds > 0) {
              timeout = setTimeout(() => {
                promiseRegistry.delete(id)
                resolve(`Wait completed: timed out after ${seconds} seconds`)
              }, seconds * 1000)
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
