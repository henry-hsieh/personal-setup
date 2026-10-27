import { Rpc } from "@opencode/plugin/rpc"

export const KataRpc = Rpc.define({
  id: "personal-setup.kata",
  methods: {
    setSessionContext: {
      input: {
        type: "object",
        properties: {
          sessionID: { type: "string" },
          reference: { type: "string" },
        },
        required: ["sessionID", "reference"],
        additionalProperties: false,
      },
      output: { type: "object", properties: {}, additionalProperties: false },
    },
  },
  events: {},
})
