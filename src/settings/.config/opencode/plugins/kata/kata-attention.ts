import type { Plugin } from "@opencode-ai/plugin"

const KATA_REF = process.env.KATA_REF
const KATA_BIN = process.env.KATA_BIN ?? "kata"

export const KataAttention: Plugin = async ({ client, $ }) => {
  if (!KATA_REF) return {}

  await client.app.log({
    body: {
      service: "kata-attention",
      level: "info",
      message: "plugin init: KATA_REF set",
      extra: { kataRef: KATA_REF, kataBin: KATA_BIN },
    },
  })

  const sessions = new Set<string>()
  let attentionActive = false

  const hook = (cmd: "start" | "end") =>
    $`${KATA_BIN} attention-hook ${cmd}`.quiet().nothrow()

  const setAttention = async (active: boolean) => {
    if (attentionActive === active) return
    attentionActive = active
    await hook(active ? "start" : "end")
  }

  const sessionID = (event: { properties?: unknown }) =>
    (event.properties as { info?: { id?: string } }).info?.id

  try {
    const { data } = await client.session.list()
    for (const existing of data ?? []) sessions.add(existing.id)
  } catch {
    // seed best-effort; event accounting still balances new sessions
  }
  await setAttention(true)

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
  }
}
