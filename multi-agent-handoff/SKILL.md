---
name: multi-agent-handoff
description: Use for external-first task-spec planning and resumable project handoff coordination across Claude Code, Codex, or other agent sessions. Trigger when the user asks to initialize or update a task specification, bind OpenSpec/OPSX/project-owned specs to execution work, preserve project continuity, explicitly sync handoff progress, compact or archive handoff context, or create a study note. Generate a transfer prompt only when the user explicitly invokes `/handoffprompt` or clearly asks to generate or prepare a prompt for another agent/session; never infer prompt generation from a mere mention of future work, another agent, or resumability.
---

# Multi-Agent Handoff

## Purpose

Coordinate task planning separately from execution continuity. Treat formal task specs as orchestration truth and handoff files as compact execution state.

Default to `HandoffDocs/` as the project-local root unless the project or user names a different root.

## Activation Boundary

Use this skill for concrete project work that benefits from specifications, continuity, multi-agent coordination, artifacts, blockers, compaction, archival, or resumable execution.

Do not initialize task or handoff state for casual chat, one-off Q&A, pure concept explanation, early brainstorming before a task is chosen, or reading-only discussion without durable decisions or follow-up work.

When task shape is unclear, use `/explorehandoff` first. Keep exploration read-only.

## Task Specs Vs Handoffs

Use `HandoffDocs/tasks/<task-slug>/` for task orchestration only when the project has no owning spec workflow. When OpenSpec, OPSX, or a project-defined formal spec exists, keep it as the source of truth and create only a local task binding record. Never mirror external spec content into `HandoffDocs/`.

Use `/inittask` to create or bind task planning state and `/updatetask` to refine it. Require explicit user confirmation before changing task status from `draft` to `ready`.

Use `/inithandoff --from-task <task-slug> --work-item <work-item-id>` to create a full execution slot from a ready task. Keep light handoffs independent from task specs.

## Light Vs Full Handoff

Use a light handoff for one focused task that needs a small continuation note at `HandoffDocs/light/<task-slug>.md`.

Use a full handoff for execution that needs task binding, an index, per-slot handoffs, artifacts, blockers, archive status, stale-artifact trust rules, compaction, study notes, or cleanup tracking.

Ask before creating a full handoff unless the user explicitly requested full coordination or a task-bound execution slot.

## Lazy Command Routing

Do not read command files until a specific action has been selected. Do not read reference files until the selected command says they are required.

Treat a natural-language request as equivalent to a command only when it clearly asks for that action.

Strong natural-language triggers include:

- Task planning: "initialize this task", "write the task spec", "bind this OpenSpec change", "update the task plan", "mark this task ready".
- Continuity setup: "make a continuation note", "set up handoff context", "initialize handoff", "keep project context".
- Explicit progress sync: "update the handoff", "record what changed in the handoff", "append current status".
- Explicit prompt generation: "generate a prompt for the next agent", "prepare the handoff prompt", "package transfer instructions for Claude/Codex".
- Context hygiene: "compact the handoff", "archive this task", "close this handoff", "avoid stale context".
- Learning capture: "make a study note", "write a learning note", "turn this task into a reflection".

Mere mention of another agent, a future session, handoff, or resumability may activate continuity handling but must not generate a prompt. Generate a prompt only for explicit prompt-generation intent.

Keep routine minimal handoff maintenance separate from command routing. After meaningful implementation, investigation, failure, validation, blocker, or next-step changes, update the active handoff concisely without presenting that maintenance as `/tracehandoff`. Use `/tracehandoff` only for an explicit user request to synchronize or backfill progress.

Route selected actions as follows:

- `/explorehandoff`: inspect whether work needs no state, task planning, a light handoff, or a full handoff. Read `commands/explorehandoff.md`.
- `/inittask`: create or bind a task spec record before execution. Read `commands/inittask.md`.
- `/updatetask`: refine task planning, bindings, work items, or readiness. Read `commands/updatetask.md`.
- `/inithandoff`: create or select a light, full, or task-bound execution handoff. Read `commands/inithandoff.md`.
- `/tracehandoff`: explicitly synchronize requested progress into an existing handoff. Read `commands/tracehandoff.md`.
- `/compacthandoff`: compact oversized active handoff context into historical reports. Read `commands/compacthandoff.md`.
- `/handoffprompt`: generate an on-demand transfer prompt without saving it. Read `commands/handoffprompt.md`.
- `/archivehandoff`: audit and archive a closed or superseded full execution handoff. Read `commands/archivehandoff.md`.
- `/study`: create a personal HTML learning note. Read `commands/study.md`.

Treat commands as independent actions, not a wizard. Finish after reporting the requested result. Mention another command only when the current action cannot complete until the user performs a required state transition. Never proactively recommend prompt generation or explicit progress sync.

## Global Safety Rules

Never silently move, copy, delete, archive, relocate, stage, commit, push, or modify git metadata. These actions require explicit user confirmation.

Without explicit confirmation, agents may create or update expected task records, internal task documents, light or full handoff documents, expected directories, compact-history reports, index rows, and archive proposals. Creating a task record does not grant permission to edit an external spec workflow.

Require explicit user confirmation before moving or copying handoffs into archive, deleting active handoffs, cleaning artifacts, modifying git ignore metadata, staging, committing, or pushing.

Use gentle labels before confirmation: `keep`, `move-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, `delete-candidate`, `archive-candidate`, `needs-user-confirmation`.

Never treat `delete-candidate` as permission to delete.

## Reference Files

Detailed rules are lazy-loaded by command:

- `references/write-safety.md`: filesystem operations, confirmation gates, git/privacy, gentle labels.
- `references/handoff-formats.md`: light, full, task-binding, index, and directory templates.
- `references/task-specs.md`: external-first source selection, task templates, readiness, and execution bindings.
- `references/artifact-lifecycle.md`: artifact placement, stale/orphan handling, compaction, archive constraints.

Only read a reference when the selected command requires it.
