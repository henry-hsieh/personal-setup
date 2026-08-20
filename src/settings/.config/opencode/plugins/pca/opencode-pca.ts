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
   * - "inject"  : Inserts synthetic user messages between consecutive assistant messages. Also inserts at the tail when the provider does not support assistant prefill (e.g. Claude 4.6+).
   */
  strategy?: "merge" | "inject";

  /**
   * Model ID patterns to target (e.g. ["copilot/*", "claude-3-5*"]).
   * Uses glob-style matching (*). If empty or omitted, applies to all models.
   */
  models?: string[];

  /**
   * Text used when strategy is set to "inject". Defaults to "[Note: previous assistant context preserved]".
   */
  syntheticMessage?: string;
}

type MessageWithParts = {
  info: Message;
  parts: Part[];
};

const DEFAULT_SYNTHETIC_MESSAGE = "[Note: previous assistant context preserved]";

function matchesModel(currentModel: string, patterns: string[]) {
  return patterns.some((pattern) => {
    const escaped = pattern
      .replace(/[.+^${}()|[\]\\]/g, "\\$&")
      .replace(/\*/g, ".*");
    const regexp = new RegExp(`^${escaped}$`);
    return regexp.test(currentModel);
  });
}

/**
 * Extract the version [major, minor] from a Claude model ID.
 * Handles patterns like "claude-opus-4.6", "opus-4.6", "claude-4.6-sonnet",
 * "sonnet-4-6", "claude-sonnet-4p6", etc.
 * Date-suffixed IDs like "claude-sonnet-4-20250514" are not matched as
 * version components — the 8-digit date is not a minor version.
 */
function claudeVersion(modelID: string): [number, number] | undefined {
  const id = modelID.toLowerCase();
  if (
    !id.includes("claude") &&
    !id.includes("opus") &&
    !id.includes("sonnet") &&
    !id.includes("haiku")
  )
    return undefined;
  const match =
    /(?:opus|sonnet|haiku|claude)-(\d+)[-.p](\d{1,2})|(\d+)[-.p](\d{1,2})-(?:opus|sonnet|haiku|claude)/i.exec(
      id,
    );
  if (!match) return undefined;
  const major = Number(match[1] ?? match[3]);
  const minor = Number(match[2] ?? match[4]);
  return [major, minor];
}

/**
 * Determines if a model supports assistant message prefill.
 * Claude models >= 4.6 do not support prefill across all providers.
 */
function supportsAssistantPrefill(modelID: string): boolean {
  const ver = claudeVersion(modelID);
  if (!ver) return true;
  const [major, minor] = ver;
  if (major > 4 || (major === 4 && minor >= 6)) return false;
  return true;
}

function modelOf(messages: MessageWithParts[]): string | undefined {
  for (let i = messages.length - 1; i >= 0; i--) {
    const info = messages[i].info;
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

      const model = modelOf(output.messages);
      const modelID = model?.slice(model.indexOf("/") + 1);
      const needsTrailingSynthetic =
        modelID === undefined || !supportsAssistantPrefill(modelID);

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
        if (last && last.info.role === "assistant" && syntheticText && needsTrailingSynthetic) {
          output.messages.push(syntheticUserMessage(last, syntheticText));
        }
      } else if (strategy === "inject") {
        const sanitized: MessageWithParts[] = [];
        for (let i = 0; i < messages.length; i++) {
          const current = messages[i];
          const next = messages[i + 1];
          sanitized.push(current);
          if (current.info.role === "assistant" && next?.info.role === "assistant" && syntheticText) {
            sanitized.push(syntheticUserMessage(current, syntheticText));
          }
        }
        const last = sanitized[sanitized.length - 1];
        if (last && last.info.role === "assistant" && syntheticText && needsTrailingSynthetic) {
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
