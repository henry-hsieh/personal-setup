import type { Plugin, PluginModule } from "@opencode-ai/plugin"
import fs from "node:fs"
import path from "node:path"

const KATA_REF = process.env.KATA_REF
const KATA_BIN = process.env.KATA_BIN ?? "kata"

export const KataPlugin: Plugin = async ({ client, $ }) => {
  if (!KATA_REF) return {}

  await client.app.log({
    body: {
      service: "kata",
      level: "info",
      message: "plugin init: KATA_REF set",
      extra: { kataRef: KATA_REF, kataBin: KATA_BIN },
    },
  })

  // --- attention harness (kata attention-hook start/end) ---
  const sessions = new Set<string>()
  let attentionActive = false

  const attentionHook = (cmd: "start" | "end") =>
    $`${KATA_BIN} attention-hook ${cmd}`.quiet().nothrow()

  const setAttention = async (active: boolean) => {
    if (attentionActive === active) return
    attentionActive = active
    await attentionHook(active ? "start" : "end")
  }

  const sessionID = (event: { properties?: unknown }) => {
    const props = event.properties as { info?: { id?: string } } | undefined
    return props?.info?.id
  }

  try {
    const { data } = await client.session.list()
    for (const existing of data ?? []) sessions.add(existing.id)
  } catch {
    // seed best-effort; if it fails we cannot trust the count, so don't
    // assume attention state from an empty set (avoids a false end later).
  }
  if (sessions.size > 0) await setAttention(true)

  // --- contract injection (kata quickstart --format contract) ---
  // Mirrors kata's Claude/Codex SessionStart hook: when the workspace is a
  // kata project (.kata.toml present) inject the marker-free agent contract
  // into the system prompt. opencode's system.transform fires every request,
  // so the contract survives compaction. Cached by .kata.toml mtime.
  let cachedContract: string | null = null
  let cachedMtime = -1

  const injectContract = async (output: { system: string[] }) => {
    const projectDir = process.env.OPENCODE_PROJECT_DIR ?? process.cwd()
    const toml = path.join(projectDir, ".kata.toml")
    let mtime: number
    try {
      mtime = fs.statSync(toml).mtimeMs
    } catch {
      return // .kata.toml absent (or removed between checks)
    }
    if (mtime !== cachedMtime || cachedContract === null) {
      const res = await $`${KATA_BIN} quickstart --format contract --workspace ${projectDir}`
        .quiet()
        .nothrow()
      const contract = (res.stdout ?? "").trim()
      // Only cache a non-empty result; an empty one (e.g. kata briefly
      // unavailable) must be retried on the next request rather than pinned.
      if (contract) {
        cachedContract = contract
        cachedMtime = mtime
      } else {
        cachedContract = null
      }
    }
    if (cachedContract) output.system.push(cachedContract)
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.created") {
        const id = sessionID(event)
        if (!id) return
        if (sessions.size === 0) await setAttention(true)
        sessions.add(id)
      } else if (event.type === "session.deleted") {
        const id = sessionID(event)
        if (!id) return
        sessions.delete(id)
        if (sessions.size === 0) await setAttention(false)
      }
    },
    "experimental.chat.system.transform": async (_input, output) => {
      await injectContract(output)
    },
  }
}

export default { id: "kata", server: KataPlugin } satisfies PluginModule
