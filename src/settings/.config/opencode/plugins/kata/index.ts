import { execFile } from "node:child_process"
import { statSync } from "node:fs"
import path from "node:path"
import { Plugin } from "@opencode/plugin"
import { KataRpc } from "./rpc"

interface SessionContext {
  reference: string
}

interface CachedContract {
  mtime: number
  text: string
}

type CommandRunner = (
  binary: string,
  args: string[],
  options: { cwd: string; reference: string },
) => Promise<string>

function runCommand(
  binary: string,
  args: string[],
  options: { cwd: string; reference: string },
): Promise<string> {
  return new Promise((resolve, reject) => {
    execFile(
      binary,
      args,
      {
        cwd: options.cwd,
        env: { ...process.env, KATA_REF: options.reference },
        encoding: "utf8",
        maxBuffer: 2 * 1024 * 1024,
      },
      (error, stdout) => {
        if (error) reject(error)
        else resolve(stdout.trim())
      },
    )
  })
}

/** Session-scoped kata context, independent of the long-lived server's environment. */
export class KataRuntime {
  private readonly sessions = new Map<string, SessionContext>()
  private readonly sessionsByReference = new Map<string, Set<string>>()
  private readonly contracts = new Map<string, CachedContract>()

  constructor(
    private readonly binary = process.env.KATA_BIN ?? "kata",
    private readonly run: CommandRunner = runCommand,
  ) {}

  sessionContext(sessionID: string): SessionContext | undefined {
    return this.sessions.get(sessionID)
  }

  async setSessionContext(sessionID: string, context: SessionContext): Promise<void> {
    if (!sessionID || !context.reference) return
    if (this.sessions.get(sessionID)?.reference === context.reference) return
    await this.removeSession(sessionID)

    let sessions = this.sessionsByReference.get(context.reference)
    if (!sessions) {
      sessions = new Set()
      this.sessionsByReference.set(context.reference, sessions)
    }
    const firstSession = sessions.size === 0
    sessions.add(sessionID)
    this.sessions.set(sessionID, context)
    if (firstSession) await this.attentionHook("start", context.reference)
  }

  async removeSession(sessionID: string): Promise<void> {
    const context = this.sessions.get(sessionID)
    if (!context) return
    this.sessions.delete(sessionID)

    const sessions = this.sessionsByReference.get(context.reference)
    sessions?.delete(sessionID)
    if (sessions?.size === 0) {
      this.sessionsByReference.delete(context.reference)
      await this.attentionHook("end", context.reference)
    }
  }

  async injectContract(sessionID: string, projectDir: string, append: (text: string) => void): Promise<void> {
    const context = this.sessions.get(sessionID)
    if (!context) return

    const configPath = path.join(projectDir, ".kata.toml")
    let mtime: number
    try {
      mtime = statSync(configPath).mtimeMs
    } catch {
      this.contracts.delete(this.cacheKey(projectDir, context.reference))
      return
    }

    const key = this.cacheKey(projectDir, context.reference)
    let cached = this.contracts.get(key)
    if (!cached || cached.mtime !== mtime) {
      let text: string
      try {
        text = await this.run(
          this.binary,
          ["quickstart", "--format", "contract", "--workspace", projectDir],
          { cwd: projectDir, reference: context.reference },
        )
      } catch {
        return
      }
      text = text.trim()
      if (!text) return
      cached = { mtime, text }
      this.contracts.set(key, cached)
    }
    append(cached.text)
  }

  private cacheKey(projectDir: string, reference: string): string {
    return `${projectDir}\0${reference}`
  }

  private async attentionHook(action: "start" | "end", reference: string): Promise<void> {
    try {
      await this.run(this.binary, ["attention-hook", action], { cwd: process.cwd(), reference })
    } catch {
      // Attention state is best-effort; it must not break a session request.
    }
  }
}

export default Plugin.define({
  id: "kata",
  async setup(ctx) {
    const runtime = new KataRuntime()
    const rpc = await ctx.rpc.register(KataRpc, {
      setSessionContext: async (input) => {
        const { sessionID, reference } = input as { sessionID: string; reference: string }
        await runtime.setSessionContext(sessionID, { reference })
        return {}
      },
    })

    const controller = new AbortController()
    const events = ctx.event.subscribe({ signal: controller.signal, types: ["session.deleted"] })
    void (async () => {
      try {
        for await (const event of events) {
          if (event.type === "session.deleted") await runtime.removeSession(event.data.sessionID)
        }
      } catch (error) {
        if (!controller.signal.aborted) console.error("[kata] event subscription failed:", error)
      }
    })()

    const contextHook = await ctx.session.hook("context", async (event) => {
      const sessionContext = runtime.sessionContext(event.sessionID)
      if (!sessionContext) return
      const session = await ctx.session.get({ sessionID: event.sessionID })
      const projectDir = session?.location?.directory
      if (!projectDir) return
      await runtime.injectContract(event.sessionID, projectDir, (text) => {
        event.system.push({ type: "text", text })
      })
    })

    return async () => {
      controller.abort()
      await Promise.all([rpc.dispose(), contextHook.dispose()])
    }
  },
})
