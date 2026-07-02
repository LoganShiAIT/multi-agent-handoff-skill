---
description: Generate a prompt packet for a manually launched agent or fresh session
argument-hint: "<task-slug>"
allowed-tools: Read, Glob, Grep, LS
---

Use the `multi-agent-handoff` skill.

Generate a prompt packet for another manually launched agent or fresh session. This command does not launch an agent. It reads the task handoff and outputs text the user can paste into Claude Code, Codex, or another agent session.

Workflow:

1. Read `HandoffDocs/handoff.md`.
2. Resolve `$ARGUMENTS` to a task slug. If missing or ambiguous, list active tasks and ask which slug to package.
3. Read `HandoffDocs/handoffs/<task-slug>.md`.
4. Output a compact prompt packet with:
   - Task slug and handoff path
   - Mission and success criteria
   - Relevant context
- Scope boundaries
- Required update behavior
- Return format

Prompt packet template:

```markdown
You are working on `<task-slug>`.

First read `HandoffDocs/handoffs/<task-slug>.md`.

Mission:
- <copy or summarize mission>

Scope:
- Work only within the task boundaries in the handoff.
- Do not edit other handoff task files.
- You may update only your own task row in `HandoffDocs/handoff.md`; re-read the index immediately before editing, preserve unrelated rows, and make the smallest local edit.
- Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or old artifacts unless the handoff explicitly references a specific file.
- Treat `Compacted History` reports as historical detail. Read them only if the current handoff lacks context needed for the task or the user asks for older history.
- Treat old timestamped artifacts as potentially stale or orphaned. Report them and verify before relying on their contents.
- Do not move, delete, archive, or relocate files unless the user explicitly confirms that file operation.

Before returning:
- Append concise progress to `HandoffDocs/handoffs/<task-slug>.md`.
- Save generated reports, test scripts, test results, and temporary notes under timestamped paths in `HandoffDocs/artifacts/<task-slug>/`.
- Index any extra temporary files created outside `HandoffDocs/artifacts/<task-slug>/` in the handoff's `Extra File Index`.
- Index old relevant artifacts that are not referenced by the active handoff as possible stale/orphan files.
- Use gentle labels such as `move-candidate`, `delete-candidate`, or `needs-user-confirmation` before any confirmed cleanup action.
- Refresh the Handoff Back section with current state, next step, risks, and blockers.

Return:
- What you changed or found
- Files touched
- Verification run
- Remaining blockers
```

End by suggesting `/tracehandoff <task-slug>` for when that agent returns, or the natural-language alternative "update this handoff with the agent result".
