---
description: Create or bind an external-first task specification before execution
argument-hint: "<task-slug> [task description]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read these before creating task state:

- `references/write-safety.md`
- `references/task-specs.md`

Create or select `HandoffDocs/tasks/<task-slug>/task.md` for an understood, concrete task. This command manages orchestration state and must not create an execution handoff.

Workflow:

1. Resolve a kebab-case task slug and task description from `$ARGUMENTS` and the user's request.
2. Inspect project instructions and targeted spec locations before choosing an owner.
3. Select the source using `references/task-specs.md`:
   - Prefer an explicit user or project-defined owner.
   - Otherwise bind one unambiguous OpenSpec, OPSX, or project-owned change/spec.
   - If several external candidates are plausible, stop and ask which candidate owns the task.
   - If no external source exists, choose internal ownership.
4. If `HandoffDocs/tasks/<task-slug>/task.md` already exists, read it and report the existing task instead of overwriting it.
5. Create `HandoffDocs/tasks/<task-slug>/`.
6. For external ownership:
   - Create only `task.md`.
   - Record workflow, root, stable change/spec ID, required files, and work-item source.
   - Verify referenced paths exist.
   - Do not copy external content into `HandoffDocs/`.
7. For internal ownership:
   - Create `task.md`, `brief.md`, `spec.md`, and `tasks.md`.
   - Create `design.md` only when technical decisions already require a durable design artifact.
8. Set status to `draft`. Do not mark the task `ready` during initialization.
9. Use system-clock timestamps and leave `Execution Bindings` empty.
10. Determine whether `HandoffDocs/` is private/local or shared/team. Do not modify git metadata without explicit authorization.

Report the task path, selected spec owner, created files, unresolved decisions, and current status. End after reporting the result.
