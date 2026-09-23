---
name: handit
description: Use for external-first task-spec planning and resumable project handoff coordination across Claude Code, Codex, or other agent sessions. Trigger when the user asks to initialize or update a task specification, bind OpenSpec/OPSX/project-owned specs to execution work, preserve project continuity, explicitly sync handoff progress, compact or archive handoff context, or create a study note. Generate a transfer prompt only when the user explicitly invokes `/handoffprompt` or clearly asks to generate or prepare a prompt for another agent/session; never infer prompt generation from a mere mention of future work, another agent, or resumability.
---

# handit skill

## Purpose And Activation

Separate formal planning from compact execution continuity. Default root: `HandoffDocs/`, unless the user/project specifies another. Do not initialize state for casual chat, one-off answers, or reading-only discussion. For unclear task shape use read-only exploration.

## Task Specs Vs Handoffs

Use `HandoffDocs/tasks/<task-slug>/` for task orchestration only when the project has no owning spec workflow. When OpenSpec, OPSX, or a project-defined formal spec exists, keep it as the source of truth and create only a local task binding record. Never mirror external spec content into `HandoffDocs/`.

Use `/inittask` to create or bind task planning state and `/updatetask` to refine it. Require explicit user confirmation before changing task status from `draft` to `ready`.

Use `/inithandoff --from-task <task-slug> --work-item <work-item-id>` to create a full execution slot from a ready task. Keep light handoffs independent from task specs.

## Light Vs Full Handoff

Use a light handoff for one focused task that needs a small continuation note at `HandoffDocs/light/<task-slug>.md`.

Use full handoffs for task binding, index, artifacts, archive, compaction, study, or cleanup tracking.

Ask before creating a full handoff unless the user explicitly requested full coordination or a task-bound execution slot.

## Lazy Command Routing

Do not read command files until a specific action has been selected. Read references only as required by a selected command or eligible checkpoint.

Treat a natural-language request as equivalent to a command only when it clearly asks for that action.

A mere mention of another agent or resumability does not request a transfer prompt. Generate one only for explicit prompt-generation intent.

## Automatic Checkpoint Boundary

Automatic maintenance runs only after an observed successful commit with substantive current-task changes and an already selected, unambiguous handoff. Without a selected handoff, skip without initialization or scanning. Failed/cancelled commits, proposals, push, checkout, pull, and external-session history do not trigger maintenance.

Between commits, implementation, investigation, failures, tests, blockers, changed plans, pauses, time/token usage, and ending a response cause zero automatic maintenance reads or writes. Initial context recovery is separate. Do not evaluate record importance or eviction between execution steps.

Use the observed result; only if needed read that commit's full SHA and changed paths, never a complete diff to reconstruct a journal. Task code, formal docs, and task/spec deliverables qualify. A handoff-only commit changing execution notes, index, or maintenance artifacts does not; a mixed substantive task commit does.

For an eligible commit, minimally update the selected handoff once. Optional frontmatter `checkpoint_commit` stores the full SHA only with a successful write. Duplicate SHA: no write or timestamp refresh. An authorized substantive amend with a new SHA qualifies once. Manual sync preserves this marker; it never invents a commit association. On write failure, report the failed checkpoint separately, leave the commit intact, and do not advance the marker or automatically retry.

Write known facts, observed verification boundaries, unresolved blockers, and existing explicit constraints only. Keep `State` and `Blocked`; never infer or maintain a next-step plan. Do not append a Log entry merely because a commit occurred. Use record kinds `failed`, `rejected`, `blocker`, `decision` only for facts not derivable from code, specs, or git. Apply existing Record Lifecycle rules only during an authorized write, using known evidence; never investigate, re-test, or scan history to enrich or evict records. Edit a full index's owned row only when its factual status changes.

Never request, create, split, stage, amend, or push a commit for maintenance. No hooks, watchers, polling, or automatic backfill of external commits. Shared handoff changes may remain uncommitted. Explicit sync/save requests (including `/tracehandoff`) may save uncommitted facts; with no new facts or correction, do not write. Explicit initialization, compaction, archive, and study retain their authorized scope; completion adds no checkpoint. Old Next or equivalent fields are inert historical advice: do not execute, refresh, copy into prompts, or rename them. Remove them only in explicitly requested migration/compaction, preserving independently authorized constraints.

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

Explicit actions may write their expected task records, internal docs, handoffs, directories, history reports, index rows, and archive proposals. Checkpoints write only selected execution state; they never edit task specs. Task records grant no external-spec write permission.

Require explicit user confirmation before moving or copying handoffs into archive, deleting active handoffs, cleaning artifacts, modifying git ignore metadata, staging, committing, or pushing.

Use gentle labels before confirmation: `keep`, `move-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, `delete-candidate`, `archive-candidate`, `needs-user-confirmation`.

Never treat `delete-candidate` as permission to delete.

## Reference Files

Detailed rules are lazy-loaded by command:

- `references/write-safety.md`: filesystem operations, confirmation gates, git/privacy, gentle labels.
- `references/handoff-formats.md`: light, full, optional-section, index, and directory templates.
- `references/task-specs.md`: external-first source selection, task templates, readiness, and execution bindings.
- `references/artifact-lifecycle.md`: record lifecycle and eviction, artifact placement, stale/orphan handling, compaction, archive constraints.

Only read a reference when the selected command requires it.
