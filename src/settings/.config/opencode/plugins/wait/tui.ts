import { Plugin } from "@opencode/plugin/tui"
import { WaitRpc } from "./rpc"

export default Plugin.define({
  id: "personal-setup.wait.tui",
  async setup(context) {
    const rpc = context.client.rpc(WaitRpc)
    let active = true

    const syncPending = async (sessionID: string): Promise<void> => {
      try {
        await context.data.session.pending.sync(sessionID)
        if (!active) return
        const inboxIDs = (context.data.session.pending.list(sessionID) ?? [])
          .filter((item) => item.type === "user")
          .map((item) => item.id)
        await rpc.syncPending({ sessionID, inboxIDs })
      } catch (error) {
        console.warn("[wait] Unable to sync pending session inbox", error)
      }
    }

    const stopCreated = context.data.on("session.created", (event) => {
      void syncPending(event.data.sessionID)
    })

    const route = context.ui.router.current()
    if (route.type === "session") {
      await Promise.all(context.data.session.family(route.sessionID).map(syncPending))
    }

    return () => {
      active = false
      stopCreated()
    }
  },
})
