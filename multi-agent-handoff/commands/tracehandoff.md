---
description: Update the current handoff topic with progress, blockers, and next steps
argument-hint: "[task-slug or update notes]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

Maintain the current task handoff under `HandoffDocs/handoffs/`.

Workflow:

1. Read `HandoffDocs/handoff.md`.
2. Identify the task from `$ARGUMENTS`, the user's wording, or the current session context.
3. If the task is ambiguous, list active tasks and ask which one to update.
4. Read the selected `HandoffDocs/handoffs/<task-slug>.md`.
   - Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or historical artifacts unless the selected task handoff explicitly references a specific file or the user asks.
5. Append a concise progress entry:
   - What changed or was learned
   - Files touched or inspected
   - Any `Context Panel` update needed because the slot topic, required files, optional files, or default reading exclusions changed
   - Verification run or skipped
   - Timestamped artifact paths under `HandoffDocs/artifacts/<task-slug>/`, if any
   - Extra files created outside `HandoffDocs/artifacts/<task-slug>/`, if any
   - Old timestamped artifacts encountered and whether they were trusted, verified, or treated as stale/orphan
   - Current blockers, if any
   - Next recommended step
6. Update this task's index row only when status, blocker, owner, scope, next action, archive proposal, or archive completion changed. Re-read `HandoffDocs/handoff.md` immediately before editing, change only the affected row, and preserve unrelated rows.
7. If the index edit cannot be merged safely, leave an index update request in the task handoff's `Handoff Back` and ask the user or coordinator to reconcile.

Put generated debugging or acceptance artifacts in timestamped files before recording them:

- Reports: `HandoffDocs/artifacts/<task-slug>/reports/YYYYMMDD-HHMMSS-short-title.md`
- Test scripts: `HandoffDocs/artifacts/<task-slug>/test-scripts/YYYYMMDD-HHMMSS-short-title.<ext>`
- Test results: `HandoffDocs/artifacts/<task-slug>/test-results/YYYYMMDD-HHMMSS-short-title.<ext>`
- Other temporary outputs: `HandoffDocs/artifacts/<task-slug>/misc/YYYYMMDD-HHMMSS-short-title.<ext>`

If any temporary document, script, test output, report, screenshot, fixture, dump, or scratch config was created outside `HandoffDocs/artifacts/<task-slug>/`, add it to the task handoff's `Extra File Index`. Do not index expected artifacts owned by another workflow unless they look misplaced or temporary.

| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |

Prefer creating handoff-owned process artifacts directly under `HandoffDocs/artifacts/<task-slug>/`. If a file already exists elsewhere, mark it as `move-candidate` before user confirmation. If a file should become part of the real project or belongs to another workflow's declared layout, mark it as `promote-candidate`, `keep`, or `external-owned` and explain why. Do not move, delete, or relocate files without explicit user confirmation.

When a timestamped file is more than 24 hours old, older than the most recent relevant source/config change, or not referenced by the active handoff, do not trust it automatically. Report its age and verify it against the active handoff, current source files, or a fresh command before relying on it. If it is not referenced by the active handoff, treat it as a possible orphan and add it to `Extra File Index` as `needs verification`, `ignored as stale`, or `confirmed orphan`.

Keep the `Context Panel` short. It should summarize the slot and file-reading boundaries, not duplicate the full progress log or every file ever touched.

Do not rewrite the whole handoff unless it is clearly stale or malformed.

End with one next-step hint. Suggest `/handoffprompt <task-slug>` if another agent should continue, `/archivehandoff <task-slug>` if the topic is ready to close, or `/study <topic>` if there is a learning worth capturing. Also include a natural-language alternative.
