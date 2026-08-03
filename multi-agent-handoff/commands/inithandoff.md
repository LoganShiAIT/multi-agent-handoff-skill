---
description: Create or select a light, full, or task-bound execution handoff
argument-hint: "[--light | --full | --from-task <task-slug> --work-item <id>] [topic]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read these before creating or selecting a handoff:

- `references/write-safety.md`
- `references/handoff-formats.md`
- `references/artifact-lifecycle.md` for `Record Lifecycle`, which governs what may enter `Log`

Read `references/task-specs.md` only for `--from-task`.

Initialize execution continuity after the task is understood.

Modes:

- `--light <slug>`: independent continuation note under `HandoffDocs/light/`.
- `--full <slug>`: unbound full execution handoff.
- `--from-task <task-slug> --work-item <id>`: task-bound full execution handoff.
- No explicit mode: use light unless the user explicitly requested full coordination.

Workflow:

1. Resolve mode, slug, and scope. If existing light/full candidates are ambiguous, list them and ask which one to select. Do not create state for casual chat or reading-only work.
2. Inspect the project briefly and avoid historical context.
3. For light:
   - Create or select `HandoffDocs/light/<slug>.md`; never overwrite an existing note during selection.
   - Use the light template.
   - Do not create task bindings, full index, artifacts, archive, or study state.
4. For unbound full:
   - Create or select `HandoffDocs/handoffs/<slug>.md`; never overwrite an existing handoff during selection.
   - Create the full index if missing and add only this execution row.
   - Complete frontmatter, the status block, `Scope`, and `Context`.
   - Omit `Task Binding` and every other optional section.
5. For `--from-task`:
   - Require both task slug and work-item ID.
   - Read `HandoffDocs/tasks/<task-slug>/task.md`.
   - Require task status `ready` or `in-progress`; if `draft` or `blocked`, stop and report the required state correction.
   - Resolve the declared work-item source and require the ID to exist.
   - Verify every required context path.
   - Normalize the execution slug as `<task-slug>--<lowercase-work-item-id>`.
   - If that handoff already exists, select it only after verifying its Task Binding matches the requested task/work item.
   - Create the full handoff and index row.
   - Set frontmatter `task` and `work_item`, add the `Task Binding` section, and list the task record plus required spec paths under `Context` as `Must read`.
   - Change task status from `ready` to `in-progress` and add one Execution Bindings row. Preserve spec content.
6. Determine whether project-local state is private/local or shared/team. Do not modify `.gitignore`, `.git/info/exclude`, stage, commit, or push without explicit authorization.
7. Before editing `HandoffDocs/handoff.md`, re-read it and make the smallest local change.
8. Use system-clock dates for frontmatter `updated`.
9. Create no artifact directories at initialization. Create each one when a file is actually written into it.
10. Leave `Log` empty. Records arrive from later work and are evicted under `Record Lifecycle`.
11. Never create or store a transfer prompt during initialization.

Report mode, execution slug, handoff path, task/work-item binding if any, and immediate execution focus. End after reporting.
