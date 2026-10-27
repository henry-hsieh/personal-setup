import { expect, test } from "bun:test"
import { join } from "node:path"
import type { Message } from "@opencode/ai/effect"
import type { SessionRequest } from "@opencode/plugin/promise/session"

const pluginDir = process.env.OPENCODE_TEST_PLUGIN_DIR ?? join(process.env.HOME!, ".config/opencode/plugins")
const { transformMessages } = await import(join(pluginDir, "pca/index.ts"))

function message(role: "user" | "assistant", text: string, extra: Record<string, unknown> = {}): Message {
  return { role, content: [{ type: "text", text }], ...extra } as Message
}

function request(messages: Message[], model = "openai/gpt-5"): SessionRequest {
  const [providerID, id] = model.split("/")
  return { messages, model: { providerID, id } } as SessionRequest
}

test("merges consecutive assistant messages without dropping non-text content", () => {
  const first = {
    id: "first",
    role: "assistant",
    content: [{ type: "text", text: "First" }, { type: "reasoning", text: "reason" }],
  } as Message
  const second = {
    id: "second",
    role: "assistant",
    content: [{ type: "tool-call", id: "tool-1", name: "run", input: {} }, { type: "text", text: "Second" }],
  } as Message
  const draft = request([message("user", "hello"), first, second, message("user", "next")])
  transformMessages(draft, {})
  expect(draft.messages.map((entry) => entry.role)).toEqual(["user", "assistant", "user"])
  expect(draft.messages[1].constructor.name).toBe("Message")
  expect(draft.messages[1].content).toEqual([
    { type: "text", text: "First " },
    { type: "reasoning", text: "reason" },
    { type: "tool-call", id: "tool-1", name: "run", input: {} },
    { type: "text", text: "Second" },
  ])
  expect(first.content[0]).toEqual({ type: "text", text: "First" })
})

test("preserves provider-owned metadata when messages cannot be merged safely", () => {
  const second = message("assistant", "Second", { native: { provider: "state" } })
  const draft = request([message("assistant", "First"), second, message("user", "next")])
  transformMessages(draft, { strategy: "merge" })
  expect(draft.messages.map((entry) => entry.role)).toEqual(["assistant", "user", "assistant", "user"])
  expect(draft.messages[2]).toBe(second)
  expect(draft.messages[2].native).toEqual({ provider: "state" })
})

test("inject strategy separates assistants with the configured message", () => {
  const draft = request([message("assistant", "A"), message("assistant", "B"), message("user", "C")])
  transformMessages(draft, { strategy: "inject", syntheticMessage: "context retained" })
  expect(draft.messages.map((entry) => entry.role)).toEqual(["assistant", "user", "assistant", "user"])
  expect(draft.messages[1].content).toEqual([{ type: "text", text: "context retained" }])
})

test("adds a trailing user only for models without assistant prefill", () => {
  for (const model of ["anthropic/claude-opus-4.6", "copilot/claude-sonnet-4-6", "anthropic/claude-5.0-sonnet"]) {
    const draft = request([message("assistant", "summary")], model)
    transformMessages(draft, {})
    expect(draft.messages.map((entry) => entry.role)).toEqual(["assistant", "user"])
  }
  for (const model of ["anthropic/claude-sonnet-4-5", "anthropic/claude-sonnet-4-20250514", "openai/gpt-5"]) {
    const draft = request([message("assistant", "summary")], model)
    transformMessages(draft, {})
    expect(draft.messages.map((entry) => entry.role)).toEqual(["assistant"])
  }
})

test("respects the enabled flag and provider/model glob filters", () => {
  for (const options of [{ enabled: false }, { models: ["copilot/claude-*"] }]) {
    const draft = request([message("assistant", "A"), message("assistant", "B")], "anthropic/claude-opus-4.6")
    transformMessages(draft, options)
    expect(draft.messages.map((entry) => entry.role)).toEqual(["assistant", "assistant"])
  }
  const draft = request([message("assistant", "A"), message("assistant", "B")], "copilot/claude-sonnet-4-6")
  transformMessages(draft, { models: ["copilot/claude-*"] })
  expect(draft.messages.map((entry) => entry.role)).toEqual(["assistant", "user"])
})
