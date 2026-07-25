---
description: Update task planning, source bindings, work items, or readiness
argument-hint: "<task-slug> [update or status]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read these before updating task state:

- `references/write-safety.md`
- `references/task-specs.md`

Update one existing `HandoffDocs/tasks/<task-slug>/task.md`. This command owns task orchestration state, not execution progress.

Workflow:

1. Resolve the task slug and requested update. If missing or ambiguous, list active task records and ask which one to update.
2. Read the task record and inspect only its declared required files.
3. Verify the current source binding:
   - For external ownership, confirm required paths still exist.
   - If a binding is missing or ambiguous, set coordination state to blocked and ask for correction.
   - Never replace a broken external binding with copied internal content.
4. Apply the requested update:
   - Internal owner: update `brief.md`, `spec.md`, optional `design.md`, `tasks.md`, or operational fields in `task.md`.
   - External owner: update only binding metadata, coordination state, and execution-binding rows. Leave requirements, design, and work items to the external workflow.
5. Apply status rules:
   - Change `draft` to `ready` only after explicit user confirmation in the current request.
   - Change `ready` to `in-progress` when an execution binding starts.
   - Use `blocked` only for a real orchestration blocker.
   - Use `done` only after the user or coordinator confirms the task outcome is complete.
6. Keep execution progress in handoff files. Do not copy handoff logs into task specs.
7. Update the task timestamp and preserve unrelated task content.

Report the files updated, resulting status, source owner, open decisions, and blockers. End after reporting the result.
