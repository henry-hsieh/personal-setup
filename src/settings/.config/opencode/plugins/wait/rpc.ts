import { Rpc } from "@opencode/plugin/rpc"

export const WaitRpc = Rpc.define({
  id: "personal-setup.wait",
  methods: {
    syncPending: {
      input: {
        type: "object",
        properties: {
          sessionID: { type: "string" },
          inboxIDs: { type: "array", items: { type: "string" } },
        },
        required: ["sessionID", "inboxIDs"],
        additionalProperties: false,
      },
      output: { type: "object", properties: {}, additionalProperties: false },
    },
  },
  events: {},
})
