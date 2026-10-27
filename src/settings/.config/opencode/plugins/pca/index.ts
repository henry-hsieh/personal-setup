import { Message } from "@opencode/ai/effect"
import { Plugin } from "@opencode/plugin"
import type { SessionRequest } from "@opencode/plugin/promise/session"

export interface PreventConsecutiveAssistantOptions {
  enabled?: boolean
  strategy?: "merge" | "inject"
  models?: string[]
  syntheticMessage?: string
}

const DEFAULT_SYNTHETIC_MESSAGE = "[Note: previous assistant context preserved]"

function matchesModel(currentModel: string, patterns: string[]): boolean {
  return patterns.some((pattern) => {
    const escaped = pattern.replace(/[.+^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*")
    return new RegExp(`^${escaped}$`).test(currentModel)
  })
}

function claudeVersion(modelID: string): [number, number] | undefined {
  const id = modelID.toLowerCase()
  if (!id.includes("claude") && !id.includes("opus") && !id.includes("sonnet") && !id.includes("haiku")) return
  const match =
    /(?:opus|sonnet|haiku|claude)-(\d+)[-.p](\d{1,2})(?!\d)|(\d+)[-.p](\d{1,2})-(?:opus|sonnet|haiku|claude)/i.exec(id)
  if (!match) return
  return [Number(match[1] ?? match[3]), Number(match[2] ?? match[4])]
}

function supportsAssistantPrefill(modelID: string): boolean {
  const version = claudeVersion(modelID)
  if (!version) return true
  const [major, minor] = version
  return major < 4 || (major === 4 && minor < 6)
}

function syntheticUserMessage(text: string): Message {
  return new Message({
    id: crypto.randomUUID(),
    role: "user",
    content: [{ type: "text", text }],
  })
}

function mergeAssistantMessages(previous: Message, next: Message): Message {
  const content = [...previous.content]
  const lastTextIndex = content.findLastIndex((part) => part.type === "text")
  if (lastTextIndex !== -1 && next.content.some((part) => part.type === "text")) {
    const last = content[lastTextIndex]
    if (last.type === "text") content[lastTextIndex] = { ...last, text: `${last.text} ` }
  }
  return new Message({ ...previous, content: [...content, ...next.content] })
}

/** Preserve provider-owned message metadata instead of discarding it during a merge. */
function canMerge(next: Message): boolean {
  return next.metadata === undefined && next.providerMetadata === undefined && next.native === undefined
}

export function transformMessages(draft: SessionRequest, options: PreventConsecutiveAssistantOptions): void {
  if (options.enabled === false || draft.messages.length === 0) return
  const model = draft.model && `${draft.model.providerID}/${draft.model.id}`
  if (options.models?.length && (!model || !matchesModel(model, options.models))) return

  const strategy = options.strategy ?? "merge"
  const syntheticText = options.syntheticMessage ?? DEFAULT_SYNTHETIC_MESSAGE
  const needsTrailingSynthetic = !draft.model?.id || !supportsAssistantPrefill(draft.model.id)
  const transformed: Message[] = []

  for (const message of draft.messages) {
    const previous = transformed.at(-1)
    if (previous?.role === "assistant" && message.role === "assistant") {
      if (strategy === "merge" && canMerge(message)) {
        transformed[transformed.length - 1] = mergeAssistantMessages(previous, message)
        continue
      }
      if (syntheticText) transformed.push(syntheticUserMessage(syntheticText))
    }
    transformed.push(message)
  }

  if (transformed.at(-1)?.role === "assistant" && syntheticText && needsTrailingSynthetic) {
    transformed.push(syntheticUserMessage(syntheticText))
  }
  draft.messages.splice(0, draft.messages.length, ...transformed)
}

export default Plugin.define({
  id: "opencode-pca",
  async setup(ctx) {
    const options = ctx.options as PreventConsecutiveAssistantOptions
    await ctx.session.hook("context", (draft) => transformMessages(draft, options))
  },
})
