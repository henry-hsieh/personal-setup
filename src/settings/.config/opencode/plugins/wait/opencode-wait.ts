import type { Plugin, PluginModule } from "@opencode-ai/plugin"

const WAIT_MODES = ["timeout", "user_message", "toast"] as const
const DEFAULT_SECONDS = 300
const MAX_SECONDS = 3600
const MESSAGE_LOOKBACK = 100
const QUEUE_PEEK_DELAY_MS = 5_000

type WaitMode = (typeof WAIT_MODES)[number]
type WaitReason = "user_message" | "toast" | "timeout" | "aborted" | "session_deleted" | "disposed"

interface WaitOptions {
  until?: string
  seconds?: number
}

interface WaitRequest {
  sessionID: string
  messageID: string
  until: WaitMode
  settle: (reason: WaitReason) => void
  timeout?: ReturnType<typeof setTimeout>
  queuePeek?: ReturnType<typeof setTimeout>
  abort?: () => void
}

interface MessageInfo {
  id?: string
  role?: string
  sessionID?: string
  time?: { created?: number; completed?: number }
}

type SessionMessages = Map<string, MessageInfo>

function messageInfo(message: unknown): MessageInfo | undefined {
  if (!message || typeof message !== "object") return
  const entry = message as { info?: unknown }
  const info = entry.info ?? message
  if (!info || typeof info !== "object") return
  return info as MessageInfo
}

function isAfter(candidate: MessageInfo, current: MessageInfo): boolean {
  const candidateCreated = candidate.time?.created
  const currentCreated = current.time?.created
  if (candidateCreated !== undefined && currentCreated !== undefined && candidateCreated !== currentCreated) {
    return candidateCreated > currentCreated
  }
  return candidate.id !== undefined && current.id !== undefined && candidate.id > current.id
}

function compareMessages(left: MessageInfo, right: MessageInfo): number {
  if (isAfter(left, right)) return 1
  if (isAfter(right, left)) return -1
  return 0
}

function orderedMessages(messages: SessionMessages): MessageInfo[] {
  return [...messages.values()].sort(compareMessages)
}

function mergeMessage(messages: SessionMessages, info: MessageInfo): void {
  if (!info.id) return
  const previous = messages.get(info.id)
  messages.set(info.id, {
    ...previous,
    ...info,
    time: { ...previous?.time, ...info.time },
  })
}

function hasQueuedUserMessageInHistory(messages: MessageInfo[], sessionID: string): boolean {
  const completed = messages.findLastIndex(
    (message) => message.role === "assistant" && message.time?.completed !== undefined,
  )
  const pending = messages.findLastIndex(
    (message, index) =>
      index > completed && message.role === "assistant" && message.time?.completed === undefined,
  )
  if (pending === -1) return false
  return messages.some(
    (message, index) => index > pending && message.role === "user" && message.sessionID === sessionID,
  )
}

export const OpencodeWait: Plugin = async ({ client }) => {
  const promiseRegistry = new Map<string, WaitRequest>()
  const messageCache = new Map<string, SessionMessages>()

  function ensureSessionMessages(sessionID: string, currentMessageID?: string): SessionMessages {
    let messages = messageCache.get(sessionID)
    if (!messages) {
      messages = new Map()
      messageCache.set(sessionID, messages)
    }
    if (currentMessageID && !messages.has(currentMessageID)) {
      mergeMessage(messages, { id: currentMessageID, role: "assistant", sessionID })
    }
    return messages
  }

  function pruneSessionMessages(sessionID: string): void {
    const messages = messageCache.get(sessionID)
    if (!messages || messages.size <= MESSAGE_LOOKBACK) return

    const keep = new Set(
      orderedMessages(messages)
        .slice(-MESSAGE_LOOKBACK)
        .flatMap((message) => (message.id ? [message.id] : [])),
    )
    for (const request of promiseRegistry.values()) {
      if (request.sessionID === sessionID) keep.add(request.messageID)
    }
    for (const id of messages.keys()) {
      if (!keep.has(id)) messages.delete(id)
    }
  }

  function processEvent(event: { type: string; properties?: unknown }) {
    const properties = event.properties as
      | {
          info?: MessageInfo
          sessionID?: string
          messageID?: string
          id?: string
        }
      | undefined
    const eventSessionID = properties?.sessionID ?? properties?.info?.sessionID
    const eventInfo = messageInfo(properties?.info)

    if (event.type === "message.updated" && eventSessionID && eventInfo) {
      const messages = messageCache.get(eventSessionID)
      if (messages) mergeMessage(messages, { ...eventInfo, sessionID: eventInfo.sessionID ?? eventSessionID })
      pruneSessionMessages(eventSessionID)
    }
    if (event.type === "message.removed" && eventSessionID) {
      const messageID = properties?.messageID ?? properties?.info?.id ?? properties?.id
      if (messageID) messageCache.get(eventSessionID)?.delete(messageID)
    }

    for (const request of promiseRegistry.values()) {
      if (
        (event.type === "message.updated" || event.type === "message.removed") &&
        eventSessionID === request.sessionID &&
        hasQueuedUserMessageInHistory(
          orderedMessages(ensureSessionMessages(request.sessionID, request.messageID)),
          request.sessionID,
        )
      ) {
        request.settle("user_message")
        continue
      }
      if (event.type === "tui.toast.show" && request.until === "toast") {
        request.settle("toast")
        continue
      }
      if (event.type === "session.deleted" && properties?.info?.id === request.sessionID) {
        request.settle("session_deleted")
        continue
      }
      if (event.type === "server.instance.disposed") request.settle("disposed")
    }
  }

  async function hasQueuedUserMessage(sessionID: string, currentMessageID: string): Promise<boolean> {
    // V1 returns the newest limited page in chronological order, matching the TUI.
    const response = await client.session.messages({
      path: { id: sessionID },
      query: { limit: MESSAGE_LOOKBACK },
    })
    const messages = ensureSessionMessages(sessionID, currentMessageID)
    for (const message of response.data ?? []) {
      const info = messageInfo(message)
      if (info) mergeMessage(messages, { ...info, sessionID: info.sessionID ?? sessionID })
    }
    pruneSessionMessages(sessionID)
    return hasQueuedUserMessageInHistory(orderedMessages(messages), sessionID)
  }

  return {
    event: async ({ event }) => {
      processEvent(event)
    },

    dispose: async () => {
      for (const request of [...promiseRegistry.values()]) request.settle("disposed")
    },

    tool: {
      wait: {
        description:
          "Pause until a bounded timeout, a current-session user message, or a TUI toast. " +
          "Current-session user messages always interrupt the wait, including timeout and toast waits. " +
          "Use this instead of shell sleep commands when no other useful work is available.",
        args: {
          until: {
            type: "string",
            enum: WAIT_MODES,
            description: "Wait mode: 'timeout', 'user_message', or 'toast'",
            default: "timeout",
          },
          seconds: {
            type: "number",
            exclusiveMinimum: 0,
            maximum: MAX_SECONDS,
            description: `Maximum wait in seconds. Defaults to ${DEFAULT_SECONDS}; must be greater than 0 and no more than ${MAX_SECONDS}.`,
            default: DEFAULT_SECONDS,
          },
        },
        async execute(args: WaitOptions, context) {
          const until = args.until ?? "timeout"
          const seconds = args.seconds ?? DEFAULT_SECONDS

          if (!WAIT_MODES.includes(until as WaitMode)) {
            return `Error: until must be one of: ${WAIT_MODES.join(", ")}`
          }
          if (!Number.isFinite(seconds) || seconds <= 0) {
            return "Error: seconds must be a positive finite number"
          }
          if (seconds > MAX_SECONDS) {
            return `Error: seconds must not exceed ${MAX_SECONDS}`
          }

          const id = crypto.randomUUID()
          return new Promise<string>((resolve) => {
            let settled = false
            let timeout: ReturnType<typeof setTimeout> | undefined
            const request: WaitRequest = {
              sessionID: context.sessionID,
              messageID: context.messageID,
              until: until as WaitMode,
              settle,
            }

            function settle(reason: WaitReason) {
              if (settled) return
              settled = true
              if (timeout !== undefined) clearTimeout(timeout)
              if (request.queuePeek !== undefined) clearTimeout(request.queuePeek)
              if (request.abort) context.abort.removeEventListener("abort", request.abort)
              promiseRegistry.delete(id)
              if (![...promiseRegistry.values()].some((entry) => entry.sessionID === request.sessionID)) {
                messageCache.delete(request.sessionID)
              }
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

            request.settle = settle
            request.abort = () => settle("aborted")
            if (context.abort.aborted) {
              settle("aborted")
              return
            }

            context.abort.addEventListener("abort", request.abort, { once: true })
            promiseRegistry.set(id, request)
            ensureSessionMessages(context.sessionID, context.messageID)

            // Let the event hook handle new messages immediately. A one-shot,
            // delayed history peek catches input queued before registration without
            // adding a request for waits that finish quickly.
            request.queuePeek = setTimeout(() => {
              void hasQueuedUserMessage(context.sessionID, context.messageID)
                .then((queued) => {
                  if (queued) settle("user_message")
                })
                .catch(() => undefined)
            }, QUEUE_PEEK_DELAY_MS)

            timeout = setTimeout(() => settle("timeout"), seconds * 1000)
            request.timeout = timeout
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
