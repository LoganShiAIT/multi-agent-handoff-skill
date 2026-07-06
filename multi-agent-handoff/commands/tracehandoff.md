---
description: Update a light or full handoff topic with progress and next steps
argument-hint: "[--light | --full] [task-slug or update notes]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read `references/write-safety.md` before updating any handoff.

For full handoffs, also read `references/artifact-lifecycle.md` before recording artifacts, stale/orphan candidates, cleanup labels, or index changes.

Maintain the current light handoff under `HandoffDocs/light/` or full task handoff under `HandoffDocs/handoffs/`.

Workflow:

1. Identify the task and mode from `$ARGUMENTS`, the user's wording, current session context, and existing files:
   - Prefer explicit `--light` or `--full`.
   - If `HandoffDocs/light/<task-slug>.md` exists and no full handoff is named, treat it as light.
   - If `HandoffDocs/handoffs/<task-slug>.md` or `HandoffDocs/handoff.md` points to the slug, treat it as full.
   - If ambiguous, list matching light and full tasks and ask which one to update.
2. For light, read `HandoffDocs/light/<task-slug>.md`.
3. For full, read `HandoffDocs/handoff.md`, then read the selected `HandoffDocs/handoffs/<task-slug>.md`.
   - Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or historical artifacts unless the selected full task handoff explicitly references a specific file or the user asks.
4. Append a concise progress entry:
   - What changed or was learned
   - Files touched or inspected
   - Verification run or skipped
   - Current blockers, if any
   - Next recommended step
5. For light:
   - Update only the light file's `Progress` and `Next` sections.
   - Do not create artifacts, update the full index, scan stale artifacts, compact, archive, or create study notes.
   - If the task now needs multi-agent coordination, artifacts, blockers, archive, stale context handling, or cross-session project state, recommend creating a full handoff and ask before doing so.
6. For full:
   - Include timestamped artifact paths under `HandoffDocs/artifacts/<task-slug>/`, if any.
   - Include extra files created outside `HandoffDocs/artifacts/<task-slug>/`, if any.
   - Include old timestamped artifacts encountered and whether they were trusted, verified, or treated as stale/orphan.
   - Update the `Context Panel` if the task's topic, required files, optional context, or default reading exclusions changed. A stale panel is a context leak for the next reader.
   - Update this task's index row only when status, blocker, owner, scope, next action, archive proposal, or archive completion changed. Re-read `HandoffDocs/handoff.md` immediately before editing, change only the affected row, and preserve unrelated rows.
   - If the index edit cannot be merged safely, leave an index update request in the task handoff's `Handoff Back` and ask the user or coordinator to reconcile.

For full handoffs, put generated debugging or acceptance artifacts in timestamped files before recording them:

- Reports: `HandoffDocs/artifacts/<task-slug>/reports/YYYYMMDD-HHMMSS-short-title.md`
- Test scripts: `HandoffDocs/artifacts/<task-slug>/test-scripts/YYYYMMDD-HHMMSS-short-title.<ext>`
- Test results: `HandoffDocs/artifacts/<task-slug>/test-results/YYYYMMDD-HHMMSS-short-title.<ext>`
- Other temporary outputs: `HandoffDocs/artifacts/<task-slug>/misc/YYYYMMDD-HHMMSS-short-title.<ext>`

For full handoffs, if any temporary document, script, test output, report, screenshot, fixture, dump, or scratch config was created outside `HandoffDocs/artifacts/<task-slug>/`, add it to the task handoff's `Extra File Index`. Do not index expected artifacts owned by another workflow unless they look misplaced or temporary.

| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |

For full handoffs, prefer creating handoff-owned process artifacts directly under `HandoffDocs/artifacts/<task-slug>/`. If a file already exists elsewhere, mark it as `move-candidate` before user confirmation. If a file should become part of the real project or belongs to another workflow's declared layout, mark it as `promote-candidate`, `keep`, or `external-owned` and explain why. Do not move, delete, or relocate files without explicit user confirmation.

For full handoffs, when a timestamped file is more than 24 hours old, older than the most recent relevant source/config change, or not referenced by the active handoff, do not trust it automatically. Report its age and verify it against the active handoff, current source files, or a fresh command before relying on it. If it is not referenced by the active handoff, treat it as a possible orphan and add it to `Extra File Index` as `needs verification`, `ignored as stale`, or `confirmed orphan`.

Do not rewrite the whole handoff unless it is clearly stale or malformed.

End with one next-step hint. Suggest `/handoffprompt <task-slug>` if another agent should continue. Suggest `/archivehandoff <task-slug>` or `/study <topic>` only for full handoffs. Also include a natural-language alternative.
