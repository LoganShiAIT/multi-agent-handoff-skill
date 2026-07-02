---
name: multi-agent-handoff
description: Use for explore-first project handoff coordination across manual Claude Code, Codex, or agent sessions, especially when the user asks in natural language to preserve context, continue later, hand off to another agent/session, update progress, create a continuation note, summarize work for the next agent, compact long handoff context, prepare archival for stale work, or make a study/learning note. Supports read-only handoff exploration, light or full handoff initialization, progress updates, transfer prompts, compaction, study notes, and archive audits.
---

# Multi-Agent Handoff

## Purpose

Coordinate resumable project work across manual Claude Code, Codex, or other agent sessions. Start with exploration, then create either a light continuation note or a full project handoff only when the work benefits from durable context.

Default to `HandoffDocs/` as the project-local handoff root unless the project or user names a different root.

## Activation Boundary

Use this skill for concrete project work that benefits from continuity: code changes, investigation, debugging, validation, multi-agent delegation, artifact generation, blockers, compaction, archival, or work likely to continue across sessions.

Do not initialize handoff context for casual chat, one-off Q&A, pure concept explanation, early brainstorming before a task is chosen, or reading-only discussion that will not create decisions, files, progress, or follow-up work.

When the task shape is unclear, use `/explorehandoff` first. Exploration is read-only and must not create `HandoffDocs/`, edit handoff files, modify git metadata, or modify project files.

## Light Vs Full Handoff

Use a light handoff for one focused task that needs a small continuation note at `HandoffDocs/light/<task-slug>.md`.

Use a full handoff for project-level coordination that needs an index, per-task handoffs, artifacts, blockers, archive status, stale artifact trust rules, compaction, study notes, or cleanup tracking.

Ask before creating a full handoff unless the user explicitly requested full project handoff management.

## Lazy Command Routing

Do not read command files until a specific handoff action has been selected. Do not read reference files from `references/` until the selected command says they are required.

Slash commands are workflow gates, but users may express the same intent without slash commands. Treat natural-language handoff intent as equivalent to the matching command, then read only that command file.

Strong natural-language triggers include:

- Continuity setup: "record this so we can continue later", "make a continuation note", "set up handoff context", "initialize handoff", "keep project context", "track this task".
- Progress tracking: "update the handoff", "record what changed", "log this progress", "append current status", "note blockers / next steps".
- Transfer to another agent/session: "make a prompt for the next agent", "prepare handoff prompt", "summarize for a new session", "package this for Claude/Codex".
- Context hygiene: "compact the handoff", "this handoff is too long", "archive this task", "close/supersede this handoff", "avoid stale context".
- Learning capture: "make a study note", "write a learning note", "turn this task into a personal reflection/summary".

If the user asks a concrete project task and mentions another agent, a future session, resumability, continuity, handoff, progress record, blockers, artifacts, stale context, or cleanup, use this skill even without a slash command. If they only ask a one-off coding question or conceptual explanation with no continuity signal, do not start handoff work.

If a natural-language request asks to start or record handoff context but the task shape is unclear, route to `/explorehandoff` first. Route directly to `/inithandoff` only when the user clearly asks to create/select a handoff for an understood task.

Natural-language requests should route to the matching workflow:

- `/explorehandoff`: inspect the project and recommend no handoff, light handoff, or full handoff without writing files. Read `commands/explorehandoff.md`.
- `/inithandoff`: create or select a light or full project handoff after exploration. Read `commands/inithandoff.md`.
- `/tracehandoff`: update the current handoff with progress, blockers, validation, or next steps. Read `commands/tracehandoff.md`.
- `/compacthandoff`: create a historical report, then compact oversized active handoff context without closing the task. Read `commands/compacthandoff.md`.
- `/handoffprompt`: generate a prompt packet for another manually launched agent or fresh session. Read `commands/handoffprompt.md`.
- `/archivehandoff`: audit and archive a closed, superseded, abandoned, stale, or failed-experiment task. Read `commands/archivehandoff.md`.
- `/study`: create a personal HTML learning note from a task, knowledge point, reflection, or summary. Read `commands/study.md`.

After a handoff-related action, suggest only one next useful command plus a natural-language alternative, for example: `Next: /tracehandoff after the next code change, or just tell me "update the handoff".`

## Global Safety Rules

Never silently move, copy, delete, archive, relocate, stage, commit, push, or modify git metadata. These actions require explicit user confirmation.

Without explicit confirmation, agents may create or update expected light or full handoff documents, create expected handoff directories, create compact-history report artifacts for full handoffs, read/list/classify candidate files, update the full index through the local edit protocol, and add archive proposals, cleanup plans, or gentle labels to a full task handoff.

Require explicit user confirmation before:

- Moving or copying a task handoff into `archive/`.
- Deleting an active task handoff after archiving.
- Moving, deleting, relocating, or cleaning artifacts.
- Deleting or moving any file outside `HandoffDocs/artifacts/<task-slug>/`.
- Modifying `.gitignore`, `.git/info/exclude`, staging files, committing files, or pushing changes.

Use gentle labels before confirmation: `keep`, `move-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, `delete-candidate`, `archive-candidate`, `needs-user-confirmation`.

Never treat `delete-candidate` as permission to delete.

## Reference Files

Detailed rules are lazy-loaded by command:

- `references/write-safety.md`: filesystem operations, confirmation gates, git/privacy, gentle labels.
- `references/handoff-formats.md`: directory pattern, light template, full index and task templates.
- `references/artifact-lifecycle.md`: artifact placement, stale/orphan handling, compaction, archive constraints.

Only read these files when the selected command's `Required References` section says to read them.
