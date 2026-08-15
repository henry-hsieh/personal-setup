import type { Plugin, PluginModule } from "@opencode-ai/plugin";
import type { Message, Part } from "@opencode-ai/sdk";

export interface PreventConsecutiveAssistantOptions {
  /**
   * Set to false to bypass the plugin entirely. Defaults to true.
   */
  enabled?: boolean;

  /**
   * Strategy to prevent bad requests on strict providers:
   * - "merge"   : (Default) Combines consecutive assistant turns (including tool/block arrays) into 1 turn, separated by a space. 0 context loss.
   * - "inject"  : Inserts synthetic user messages between consecutive assistant messages and at the tail.
   */
  strategy?: "merge" | "inject";

  /**
   * Model ID patterns to target (e.g. ["copilot/*", "claude-3-5*"]).
   * Uses glob-style matching (*). If empty or omitted, applies to all models.
   */
  models?: string[];

  /**
   * Text used when strategy is set to "inject". Defaults to "Continue."
   */
  syntheticMessage?: string;
}

type MessageWithParts = {
  info: Message;
  parts: Part[];
};

const DEFAULT_SYNTHETIC_MESSAGE = "Continue.";

function matchesModel(currentModel: string, patterns: string[]) {
  return patterns.some((pattern) => {
    const escaped = pattern
      .replace(/[.+^${}()|[\]\\]/g, "\\$&")
      .replace(/\*/g, ".*");
    const regexp = new RegExp(`^${escaped}$`);
    return regexp.test(currentModel);
  });
}

function modelOf(messages: MessageWithParts[]): string | undefined {
  for (const msg of messages) {
    const info = msg.info;
    if (info.role === "user" && info.model) {
      return `${info.model.providerID}/${info.model.modelID}`;
    }
    if (info.role === "assistant") {
      return `${info.providerID}/${info.modelID}`;
    }
  }
  return undefined;
}

function mergeAssistantParts(
  messageID: string,
  prevParts: Part[],
  nextParts: Part[],
): Part[] {
  const merged = [...prevParts];
  const lastTextIndex = merged.reduce(
    (idx, part, i) => (part.type === "text" ? i : idx),
    -1,
  );
  const firstTextIndex = nextParts.findIndex((part) => part.type === "text");
  if (lastTextIndex !== -1 && firstTextIndex !== -1) {
    const lastTextPart = merged[lastTextIndex];
    if (lastTextPart.type === "text") {
      merged[lastTextIndex] = { ...lastTextPart, text: `${lastTextPart.text} ` };
    }
  }
  merged.push(...nextParts.map((part) => ({ ...part, messageID })));
  return merged;
}

function syntheticUserMessage(template: MessageWithParts, text: string): MessageWithParts {
  const base = template.info;
  const sessionID = base.sessionID;
  const now = Date.now();
  const messageID = crypto.randomUUID();
  const textPart: Part = {
    id: crypto.randomUUID(),
    sessionID,
    messageID,
    type: "text",
    text,
    synthetic: true,
  };
  return {
    info: {
      id: messageID,
      sessionID,
      role: "user",
      time: { created: now },
      agent: base.role === "user" ? base.agent : "",
      model:
        base.role === "user"
          ? base.model
          : { providerID: base.providerID, modelID: base.modelID },
    },
    parts: [textPart],
  };
}

const OpencodePca: Plugin = async (_ctx, options) => {
  const opts = (options ?? {}) as PreventConsecutiveAssistantOptions;
  const enabled = opts.enabled ?? true;
  const strategy = opts.strategy ?? "merge";
  const allowedModels = opts.models ?? [];
  const syntheticText = opts.syntheticMessage ?? DEFAULT_SYNTHETIC_MESSAGE;

  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      if (!enabled) return;

      if (allowedModels.length > 0) {
        const model = modelOf(output.messages);
        if (!model || !matchesModel(model, allowedModels)) return;
      }

      const messages = [...output.messages];
      if (messages.length === 0) return;

      if (strategy === "merge") {
        const merged: MessageWithParts[] = [];
        for (const msg of messages) {
          const prev = merged[merged.length - 1];
          if (prev && prev.info.role === "assistant" && msg.info.role === "assistant") {
            prev.parts = mergeAssistantParts(prev.info.id, prev.parts, msg.parts);
          } else {
            merged.push({ info: msg.info, parts: [...msg.parts] });
          }
        }
        output.messages.splice(0, output.messages.length, ...merged);

        const last = output.messages[output.messages.length - 1];
        if (last && last.info.role === "assistant" && syntheticText) {
          output.messages.push(syntheticUserMessage(last, syntheticText));
        }
      } else if (strategy === "inject") {
        const sanitized: MessageWithParts[] = [];
        for (let i = 0; i < messages.length; i++) {
          const current = messages[i];
          const next = messages[i + 1];
          sanitized.push(current);
          if (current.info.role === "assistant" && next?.info.role === "assistant") {
            sanitized.push(syntheticUserMessage(current, syntheticText));
          }
        }
        const last = sanitized[sanitized.length - 1];
        if (last && last.info.role === "assistant" && syntheticText) {
          sanitized.push(syntheticUserMessage(last, syntheticText));
        }
        output.messages.splice(0, output.messages.length, ...sanitized);
      }
    },
  };
};

export default {
  id: "opencode-pca",
  server: OpencodePca,
} satisfies PluginModule;
