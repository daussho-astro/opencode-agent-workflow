import type { Plugin } from "@opencode-ai/plugin"

const allowedTargets: Record<string, string[] | "*"> = {
  orchestrator: "*",
  planner: ["explore"],
  general: ["explore", "executor"],
  "frontend-designer": ["explore", "executor"],
  reviewer: ["executor"],
  "ui-reviewer": ["executor"],
  "general-lite": [],
  "reviewer-lite": [],
  explore: [],
  executor: [],
  scout: [],
}

export const SubagentPolicy: Plugin = async () => {
  const sessionAgents = new Map<string, string>()

  return {
    "chat.params": async (input) => {
      sessionAgents.set(input.sessionID, input.agent)
    },

    "tool.execute.before": async (input, output) => {
      if (input.tool !== "task") return

      const caller = sessionAgents.get(input.sessionID)
      const target =
        output.args?.subagent_type ??
        output.args?.subagentType ??
        output.args?.agent ??
        output.args?.agentName

      if (!caller) {
        throw new Error("Subagent policy blocked task delegation: unknown caller")
      }

      if (typeof target !== "string") {
        throw new Error(`Subagent policy blocked task delegation: ${caller} -> unknown target`)
      }

      const allowed = allowedTargets[caller] ?? []
      if (allowed === "*" || allowed.includes(target)) return

      throw new Error(`Subagent policy blocked task delegation: ${caller} -> ${target}`)
    },
  }
}
