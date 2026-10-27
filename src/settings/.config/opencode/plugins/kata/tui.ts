import { Plugin } from "@opencode/plugin/tui"
import { KataRpc } from "./rpc"

export default Plugin.define({
  id: "personal-setup.kata.tui",
  async setup(context) {
    const reference = process.env.KATA_REF
    if (!reference) return

    const rpc = context.client.rpc(KataRpc)
    const associate = async (sessionID: string): Promise<void> => {
      try {
        await rpc.setSessionContext({ sessionID, reference })
      } catch (error) {
        console.warn("[kata] Unable to associate session with KATA_REF", error)
      }
    }

    const currentLocation = context.location?.directory
    const stopCreated = context.data.on("session.created", (event) => {
      const eventLocation = event.location?.directory
      if (currentLocation && eventLocation && currentLocation !== eventLocation) return
      void associate(event.data.sessionID)
    })

    const route = context.ui.router.current()
    if (route.type === "session") {
      const sessions = context.data.session.family(route.sessionID)
      await Promise.all(sessions.map(associate))
    }

    return stopCreated
  },
})
