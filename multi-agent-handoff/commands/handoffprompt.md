---
description: Generate a transfer prompt packet from a light or full handoff
argument-hint: "[--light | --full] <task-slug>"
allowed-tools: Read, Glob, Grep, LS
---

Use the `multi-agent-handoff` skill.

## Required References

None by default. This command reads selected handoff files and emits a prompt packet; do not load `references/` files unless the selected handoff explicitly points to one or the user asks.

Generate a prompt packet for another manually launched agent or fresh session. This command does not launch an agent. It reads a light or full task handoff and outputs text the user can paste into Claude Code, Codex, or another agent session.

Workflow:

1. Resolve `$ARGUMENTS` to mode and task slug:
   - Prefer explicit `--light` or `--full`.
   - If `HandoffDocs/light/<task-slug>.md` exists and no full handoff is named, use light.
   - If `HandoffDocs/handoffs/<task-slug>.md` or `HandoffDocs/handoff.md` points to the slug, use full.
   - If missing or ambiguous, list matching light and full tasks and ask which slug to package.
2. For light, read `HandoffDocs/light/<task-slug>.md`.
3. For full, read `HandoffDocs/handoff.md` and `HandoffDocs/handoffs/<task-slug>.md`.
4. Output a compact prompt packet with:
   - Task slug and handoff path
   - Mission and success criteria
   - Relevant context
   - Scope boundaries
   - Required update behavior
   - Return format

Full prompt packet template:

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

Light prompt packet template:

```markdown
You are working from light handoff `<task-slug>`.

First read `HandoffDocs/light/<task-slug>.md`.

Mission:
- <copy or summarize intent and goal>

Scope:
- Keep the work within the light handoff's scope.
- Update only `HandoffDocs/light/<task-slug>.md` before returning.
- Do not create full handoff index, artifacts, archive, study notes, or cleanup records unless the user explicitly asks.
- If the work becomes multi-agent, cross-session, artifact-heavy, blocked, or needs archival, recommend creating a full handoff instead of silently expanding the light file.

Before returning:
- Append concise progress to the light handoff.
- Refresh the Next section with current next step, verification, and risks.

Return:
- What you changed or found
- Files touched
- Verification run
- Whether full handoff tracking is now recommended
```

End by suggesting `/tracehandoff <task-slug>` for when that agent returns, or the natural-language alternative "update this handoff with the agent result".
