---
name: multi-agent-handoff
description: Use when coordinating manually launched multi-agent work, preserving task context across Claude Code or Codex sessions, resuming a previous task thread, creating or updating handoff files, tracking agent progress, or preventing parallel agents from overwriting one shared context document.
---

# Multi-Agent Handoff

## Overview

Use one index handoff plus many focused task handoffs to coordinate manually launched agents. The index shows what is active, blocked, done, or archived; each small handoff owns the context and progress for one agent task.

This template uses `HandoffDocs/handoff.md` plus `HandoffDocs/handoffs/` as the default project-local handoff structure. If adapting it for a specific user or team, replace the default handoff root while keeping the same index-plus-task-files pattern.

For Claude Code, pair this skill with slash commands such as `/inithandoff`, `/tracehandoff`, and `/handoffprompt`. The commands provide explicit moments to initialize, update, and package handoff context instead of relying on a user-level prompt to remember timing.

## Directory Pattern

Use this structure inside a project-local handoff root:

```text
HandoffDocs/
|-- handoff.md
|-- handoffs/
|   |-- <task-slug>.md
|   `-- ...
|-- archive/
|   `-- YYYY-MM/
|       `-- <task-slug>.md
|-- study/
|   `-- <study-scope>/
|       `-- YYYYMMDD-HHMMSS-short-title.html
`-- artifacts/
    `-- <task-slug>/
        |-- reports/
        |-- test-scripts/
        |-- test-results/
        `-- misc/
```

Default to `HandoffDocs/`. Treat `<HANDOFF_ROOT>` as a placeholder only when adapting the template to a different directory.

Alternative roots:

- `handoff/` or `.handoff/` for a generic project-local system.
- A documented project directory when handoffs are intended to be shared team artifacts.

`handoff.md` is the coordination index only. Put detailed active context in `handoffs/<task-slug>.md`. Use kebab-case slugs such as `api-auth-investigation`, `frontend-table-refactor`, or `migration-test-failures`.

Keep `handoffs/` for active or resumable task handoffs only. Move closed, stale, superseded, or failed-experiment task files to `archive/YYYY-MM/`. Put debugging and acceptance byproducts under `artifacts/<task-slug>/` instead of project root.

`archive/`, `study/`, and historical `artifacts/` are not default operational context. Do not read them during normal task startup or continuation unless the user explicitly asks, the active task handoff links to a specific file, or a command such as `/archivehandoff` or `/study` requires it.

## Command Roles

Use commands as explicit workflow gates:

- `/inithandoff`: Enter a project, inspect its structure, combine that with the user's current request, then create or select the handoff topic.
- `/tracehandoff`: Manually update the current topic after work, investigation, agent returns, blockers, or changed next steps.
- `/handoffprompt`: Generate a strict prompt packet for another manually launched agent or fresh session. It does not launch the agent; it produces the text to paste into that agent/session.
- `/archivehandoff`: Audit the task and workspace, prepare an archive plan, then close or quarantine a task handoff only after the user confirms file moves or deletion.
- `/study`: Create a personal HTML learning note from a task case, knowledge point, personal reflection, or summary.

The command files are optional helpers. The skill body remains the source of truth for behavior.

## Activation Boundary

Do not create or update handoff files for every conversation.

Create or select a handoff only when there is a concrete project task that benefits from continuity, such as code changes, investigation, debugging, validation, multi-agent delegation, artifact generation, or work likely to continue across sessions.

Do not initialize handoff for:

- Casual chat
- One-off Q&A
- Concept explanation without project action
- Brainstorming before the user chooses a concrete task
- Reading-only discussion that will not create decisions, progress, files, or follow-up work

If the user casually mentions an idea but has not turned it into a task, discuss normally. If it starts becoming actionable, ask whether to create or attach a handoff topic.

## Command Suggestion Protocol

Slash commands are workflow shortcuts, not the only way to use this system. Users may forget or prefer natural language.

At the end of any handoff-related action, proactively suggest the next useful command and a natural-language alternative. Keep it to one short line, for example:

- `Next: /tracehandoff after the next code change, or just tell me "update the handoff".`
- `Next: /handoffprompt <slug> if you want to start another agent, or ask me to "make a prompt for the next agent".`
- `Next: /archivehandoff <slug> when this topic is done, or say "archive this handoff".`
- `Next: /study <topic> if this taught you something worth keeping, or say "make a study note".`

Do not nag or list every command. Suggest only the single command that matches the current state.

## Filesystem Operations Checklist

Use this checklist instead of duplicating directory rules in commands:

- Initialize root: create `HandoffDocs/`, `HandoffDocs/handoffs/`, `HandoffDocs/archive/`, `HandoffDocs/study/`, and `HandoffDocs/artifacts/`.
- Initialize task: create `HandoffDocs/handoffs/<task-slug>.md` and `HandoffDocs/artifacts/<task-slug>/{reports,test-scripts,test-results,misc}/`.
- Archive task: create `HandoffDocs/archive/YYYY-MM/` only after the user confirms the archive action.
- Create study note: create `HandoffDocs/study/<study-scope>/` before writing the HTML note, unless a user/project-specific personal notes policy overrides the study location.
- Never assume `HandoffDocs/` is private. Choose private/local or shared/team policy first.

## Confirmation Boundary For File Operations

Archive audit is allowed to inspect, classify, and propose actions. It must not silently move, delete, or relocate files.

Without explicit user confirmation, agents may:

- Create or update handoff documents under `HandoffDocs/`.
- Create expected handoff directories.
- Read, list, and classify candidate files.
- Update `HandoffDocs/handoff.md` using the Index Update Protocol.
- Add archive proposals, cleanup plans, and gentle labels to the task handoff.

Require explicit user confirmation before:

- Moving a task handoff from `handoffs/` to `archive/`.
- Copying a task handoff into `archive/` as the final archive record.
- Deleting the active task handoff after archiving.
- Moving, deleting, or relocating artifacts.
- Deleting or moving any file outside `HandoffDocs/artifacts/<task-slug>/`.
- Modifying `.gitignore`, `.git/info/exclude`, staging files, committing files, or pushing changes.

Use gentle labels before confirmation:

```text
keep
move-candidate
promote-candidate
external-owned
ignore-as-stale-candidate
orphan-candidate
delete-candidate
archive-candidate
needs-user-confirmation
```

Use final action labels only after the action is actually confirmed and completed:

```text
kept
moved
promoted
external-owned
ignored-as-stale
confirmed-orphan
deleted-confirmed
archived-confirmed
```

Never treat `delete-candidate` as permission to delete. A file may be proposed for deletion when it was clearly created by the current task and indexed, but actual deletion always requires explicit user confirmation.

## External Workflow Ownership

Respect other skills, frameworks, and project workflows that define their own file layout. Their artifacts belong where that workflow says they belong.

Examples include spec systems, architecture docs, formal design docs, permanent tests, generated app code, release notes, migration files, and any skill-specific outputs with an established directory.

Rules:

- Do not move external workflow artifacts into `HandoffDocs/`.
- Do not archive external workflow artifacts with `/archivehandoff`.
- Do not classify expected external workflow files as scattered temporary files.
- Do reference external artifacts by path in the active task handoff when they matter.
- If an external workflow's artifact conflicts with the handoff, treat the external workflow artifact as the stronger source of truth and mark the handoff as needing clarification.

Use this priority when sources disagree:

```text
External workflow formal artifacts > current source code/config > active task handoff > active artifacts explicitly referenced by handoff > archive/study/historical artifacts
```

## Index Template

Use `handoff.md` as a compact dashboard:

```markdown
# Handoff Index

## Active
| Slug | Owner | Status | Scope | Next Action | Updated |
| --- | --- | --- | --- | --- | --- |
| [api-auth-investigation](handoffs/api-auth-investigation.md) | agent-a | in-progress | Auth failures in API tests | Verify token refresh path | 2026-07-01 |

## Blocked
| Slug | Owner | Blocker | Needed |
| --- | --- | --- | --- |

## Done
| Slug | Result | Follow-up |
| --- | --- | --- |

## Archived
| Slug | Archived At | Reason | Replacement |
| --- | --- | --- | --- |
```

Keep each index row to one line of operational signal. Do not store long analysis, logs, or full agent transcripts in the index. Keep archived rows short; the archive file holds the final summary.

## Index Update Protocol

`handoff.md` is a shared coordination file. Every agent may update it for real-time coordination, but only through local, minimal edits.

Agents may update their own task row when status, blocker, owner, scope, next action, archive proposal, or archive completion changes. They should not rewrite unrelated rows or reorganize the whole index unless the user explicitly asks.

Before editing `handoff.md`:

1. Re-read `HandoffDocs/handoff.md` immediately before editing.
2. Change only the affected row or the minimal relevant section.
3. Preserve unrelated rows exactly.
4. If the file changed since the agent last read it, merge locally rather than overwrite.
5. If a conflict cannot be resolved safely, update the task handoff with an index update request and ask the user or coordinator to reconcile.

A coordinator may still exist as the agent that splits tasks, resolves conflicts, and performs broad cleanup, but coordinator status is not required for a task owner to keep its own index row current.

## Task Handoff Template

Create one file per manually launched agent task:

```markdown
# <Task Title>

## Metadata
- Slug:
- Owner / Agent:
- Status: planned | in-progress | blocked | done | archived
- Created:
- Last Updated:
- Branch / Worktree:
- Related Files:

## Mission
- Goal:
- Out of Scope:
- Success Criteria:

## Context Packet
- User request:
- Relevant project facts:
- Commands already run:
- Files already inspected:

## Progress Log
-

## Findings and Decisions
-

## Artifacts
- Reports:
- Test scripts:
- Test results:
- Other byproducts:

## Study Notes
Personal learning notes generated from this task.

| Path | Topic | Key Lesson | Created |
| --- | --- | --- | --- |

## Extra File Index
Track every non-source or temporary file created outside `HandoffDocs/artifacts/<task-slug>/`. Do not index expected artifacts that belong to another workflow's declared file layout unless they are suspicious, temporary, or misplaced.

| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |

## Handoff Back
- Current state:
- Next recommended step:
- Risks / blockers:
- Prompt for the next agent:
```

Keep task handoffs factual and incremental. Write enough for another agent to continue without replaying the whole conversation, but avoid dumping raw logs unless the log is the artifact.

## Artifact Placement And Extra File Indexing

During debugging, validation, acceptance testing, or program modification, put generated process artifacts under `HandoffDocs/artifacts/<task-slug>/` with timestamped names. Do this for temporary documents, validation scripts, exploratory test scripts, test outputs, test reports, debug dumps, screenshots, and investigation notes.

Use these folders:

```text
HandoffDocs/artifacts/<task-slug>/
|-- reports/
|   `-- YYYYMMDD-HHMMSS-short-title.md
|-- test-scripts/
|   `-- YYYYMMDD-HHMMSS-short-title.<ext>
|-- test-results/
|   `-- YYYYMMDD-HHMMSS-short-title.<ext>
`-- misc/
    `-- YYYYMMDD-HHMMSS-short-title.<ext>
```

Prefer local timestamp format `YYYYMMDD-HHMMSS`. If the artifact is large, keep the handoff entry to a short conclusion plus the artifact path. Do not paste long logs, generated reports, or raw test output into `handoffs/<task-slug>.md`.

Do not put deliverable source code, permanent test files, official project docs, formal spec artifacts, or intentionally committed scripts in `HandoffDocs/artifacts/`. Those belong in the normal project tree or the owning workflow's directory.

## Timestamp Trust Rules

Treat timestamps as trust signals, not just labels for humans. When an agent sees an older artifact, report its age and treat its content as potentially stale until confirmed by the active handoff, current source files, or fresh verification.

Treat an artifact as a stale candidate if any of these are true:

- Its timestamp is more than 24 hours old.
- It is older than the most recent relevant source/config change.
- It is not referenced by the current task handoff's `Progress Log`, `Artifacts`, `Study Notes`, or `Extra File Index`.
- It belongs to another task slug, `archive/`, or an unknown folder.

Use these rules:

- Recent and referenced by the active handoff: safe to inspect, but still summarize rather than paste.
- Old but referenced by the active handoff: report that it is old, verify against current files or rerun relevant checks before relying on it.
- Old and not referenced by the active handoff: treat as a possible orphan file from an unfinished or unarchived task. Do not trust it as current context. Report it and add it to `Extra File Index` if it affects the task.
- Any artifact under `archive/` or artifacts belonging to another slug: do not read by default unless the user asks or the active handoff explicitly points there.

If a timestamped file appears important but old, say so explicitly in the handoff update: `Potential stale/orphan artifact: <path> (<timestamp>). Not trusted until verified.`

When a process artifact or temporary helper must be created outside `HandoffDocs/artifacts/<task-slug>/`, immediately record it in the task handoff's `Extra File Index`. Include:

- Path
- Why it exists
- Whether to keep, mark as a move candidate into `HandoffDocs/artifacts/<task-slug>/`, mark as a delete candidate, or promote into the formal project tree
- Cleanup status

Examples of indexed extra files include temporary scripts in project root, one-off reports, scratch fixtures, copied datasets, generated screenshots, debug logs, and experimental config files. This index is mandatory whenever the task creates non-source files outside the controlled artifacts directory, except for expected artifacts owned by another workflow.

Also index suspicious old timestamped files that appear relevant but are not referenced by the active handoff. Mark them as `unknown`, `orphan?`, or `needs verification` until resolved.

At the end of a handoff, review `Extra File Index` before archiving. Before user confirmation, mark each file with a gentle candidate label such as `move-candidate`, `delete-candidate`, `orphan-candidate`, or `needs-user-confirmation`. After confirmed actions are completed, update labels to final states such as `kept`, `moved`, `deleted-confirmed`, `promoted`, `ignored-as-stale`, or `confirmed-orphan`. Do not archive a handoff while unknown extra files are still unclassified.

## Study Notes

Use `/study` to turn an actual task, knowledge point, personal reflection, or short summary into a personal learning note. These notes are for the learner, not for team-facing postmortems. Prefer reflective, practical writing over status reporting.

Study notes are personal learning material, not task authority. Do not load `HandoffDocs/study/` during normal task work. Read a study note only when the user asks for learning material, when running `/study`, or when the active handoff explicitly references a specific note as relevant context.

Do not force a rigid section template. Choose the shape that best fits the case and the learner's intent. The note may be a debugging case study, architecture reading guide, build-process reflection, proposal review, technology crash course, operational playbook, or "what I learned from this incident" essay.

Create study notes as timestamped HTML files:

```text
HandoffDocs/study/<study-scope>/YYYYMMDD-HHMMSS-short-title.html
```

Use the task slug as `<study-scope>` when the note is tied to a handoff task. Use a kebab-case topic slug such as `typescript-generics`, `code-review-habits`, or `internship-reflection` when it is a standalone knowledge point or personal reflection.

If project or user instructions define a personal notes root, standalone knowledge or reflection notes should use that root instead of `HandoffDocs/study/`. Keep task-linked notes in `HandoffDocs/study/<task-slug>/` when they are part of the handoff evidence trail.

A study note can be one of these modes:

- Task case: based on a concrete handoff task and its investigation.
- Knowledge point: explains a concept, API, architecture pattern, tool, or engineering practice.
- Personal reflection: captures personal understanding, confusion, growth, work habits, mentor feedback, or internship observations.
- Summary: consolidates several related learnings into a compact guide.

It should usually include some of these ingredients, but not necessarily in this order or with these exact headings:

- Real case: what happened in this task
- Solution path: how the issue was understood and solved
- Enterprise practice: what this reveals about mature engineering, architecture, quality, operations, collaboration, or review culture
- Design principle: the reusable idea behind the solution
- Personal takeaway: what the learner should remember next time
- Reuse checklist: when and how to apply the lesson again
- Questions to ask: mentor questions, docs to read, or deeper topics to study

Choose concrete headings that match the note, such as `Problem Context`, `Key Concept`, `Repository Structure`, `Debugging Trace`, `Decision Review`, `Future Debugging Method`, `Regression Checklist`, `Method Notes`, `What I Finally Understood`, `Open Questions`, or `Internship Takeaways`.

After creating a task-linked study note, add it to the task handoff's `Study Notes` table. For standalone knowledge or reflection notes, do not force a handoff link; keep the note under the relevant `study/<study-scope>/` folder. If the note references old artifacts, apply Timestamp Trust Rules and label stale or unverified material clearly inside the note.

## Coordinator Workflow

When starting a multi-agent effort:

1. Select or create `HandoffDocs/` unless the project explicitly uses another handoff root.
2. Create `handoff.md` if missing.
3. Split the work into independent task slugs.
4. Create one `handoffs/<task-slug>.md` per manual agent.
5. Put only the summary row in `handoff.md`.
6. Give each agent its own task handoff path and tell it to update that task handoff plus its own index row through the Index Update Protocol.

When resuming:

1. Read `handoff.md` first.
2. If the user names a slug or task, read that task handoff.
3. If the user does not identify a task and multiple active tasks exist, ask which task to resume or whether to create a new task.
4. Use the task handoff as the continuity context, especially `Mission`, `Progress Log`, and `Handoff Back`.
5. Do not read `archive/`, `study/`, or historical `artifacts/` during resume unless specifically directed by the active handoff or user.

When an agent returns:

1. Read its task handoff and returned summary.
2. Update the task status and `Handoff Back`.
3. Update the corresponding index row using the Index Update Protocol.
4. Move completed tasks to `Done` only after the work is genuinely integrated or intentionally closed.
5. Archive tasks with `/archivehandoff` or the Archive Workflow below when the task is closed, superseded, abandoned, stale, or a failed experiment.

## Archive Workflow

Archive to prevent old context from polluting active work.

1. Confirm the slug and archive reason: `done`, `superseded`, `abandoned`, `stale`, or `failed-experiment`.
2. Read `HandoffDocs/handoffs/<task-slug>.md`.
3. Run a pre-archive audit. Do not perform file moves or deletions during the audit:
   - Check `Extra File Index` and classify every extra file with a gentle label such as `keep`, `move-candidate`, `delete-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, or `needs-user-confirmation`.
   - Check `HandoffDocs/artifacts/<task-slug>/` and confirm artifacts are indexed or intentionally historical.
   - Check for scattered temporary files in the project root and likely scratch locations, excluding expected artifacts owned by other workflows.
   - Check for old timestamped files related to the slug that are not referenced by the active handoff.
   - If in a git repository, inspect changed and untracked files so temporary byproducts are not confused with deliverable source changes or expected external workflow artifacts.
   - Confirm no other active handoff depends on this task without a replacement link.
4. Add an `Archive Plan` near the top and ask the user to confirm before moving or deleting anything. The plan should present the default archive action as a full move, and ask the user to explicitly say if they want copy-only/no active-file removal instead.

```markdown
## Archive Plan
- Proposed At:
- Reason:
- Final Outcome:
- Proposed Archive Path:
- Index Change:
- File Move/Delete Actions Requiring Confirmation:
- Gentle Labels Applied:
- Still Needs User Confirmation:
```

5. If the user does not confirm, stop after updating the task handoff and optionally set the index row to `archive-candidate` or `needs-user-confirmation`.
6. After user confirmation for a full archive move, add or refresh an `Archive Summary` near the top. If the user confirms copy-only/no active-file removal, keep it as an archive candidate and add a brief copied-archive note instead of an `Archive Summary`.

```markdown
## Archive Summary
- Archived At:
- Reason:
- Final Outcome:
- Do Not Reuse:
- Useful If:
- Superseded By:
- Extra File Cleanup:
- Stale/Orphan Artifacts:
- Pre-Archive Audit:
```

7. Create `HandoffDocs/archive/YYYY-MM/` if missing.
8. Re-read `HandoffDocs/handoff.md` immediately before editing.
9. By default, perform a confirmed archive as a move: create `HandoffDocs/archive/YYYY-MM/<task-slug>.md`, update the index, then remove the active `HandoffDocs/handoffs/<task-slug>.md` only after the archived file and index update both succeed.
10. If the user explicitly confirms copy-only/no active-file removal, copy the task file to `HandoffDocs/archive/YYYY-MM/<task-slug>.md`, keep the active file indexed, and mark the active row as `archive-candidate` or `copied-to-archive` instead of treating the task as fully archived.
11. For a confirmed move, remove it from `Active` or `Blocked` in `handoff.md` using a local row edit.
12. For a confirmed move, add a short row to `Archived` in `handoff.md`.
13. Leave task artifacts in `HandoffDocs/artifacts/<task-slug>/` unless the user explicitly confirmed artifact cleanup. Mark them historical and do not read them by default.

When resuming work, do not read `archive/`, `study/`, or historical `artifacts/` unless the user names an archived slug, asks for learning or historical context, or the active handoff explicitly points to a specific file.

## Agent Prompt Contract

When manually launching an agent, `/handoffprompt` or the coordinator should produce a compact prompt packet like this:

```markdown
You are working on `<task-slug>`.

Read `HandoffDocs/handoffs/<task-slug>.md` before starting.
Keep your scope to the Mission section.
Append concise progress to Progress Log.
Update Handoff Back before returning.
Do not edit other task handoff files.
You may update only your own row in `HandoffDocs/handoff.md` through the Index Update Protocol.
Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or old artifacts unless this task handoff explicitly links to a specific file.

Return:
- What you changed or found
- Files touched
- Verification run
- Remaining blockers
```

## Update Rules

Update the task handoff before real work begins once the user's requirement is clear. This captures the mission before context drifts.

Update the task handoff after meaningful project edits, investigations, failed attempts, or blocker discoveries. Prefer short append-only entries over rewriting history.

Update the index when status, owner, scope, blocker, or next action changes. Avoid index churn for tiny progress updates.

## Collision Avoidance

Use one handoff file per task because parallel agents may otherwise overwrite each other's context. Individual agents own their task files and may update only their own index row. A coordinator, if present, handles task splitting, broad reconciliation, and conflict resolution.

If two agents need the same files or domain, either merge their task into one owner or make the dependency explicit in both task handoffs.

If multiple worktrees or branches are involved, record the branch or worktree in the task metadata and index row.

## Git and Privacy Policy

Follow the project's policy for whether handoffs are committed:

- Private/local handoffs: prefer adding `HandoffDocs/` or the configured handoff root to `.git/info/exclude` for local-only protection. Use `.gitignore` only when the team should share the ignore rule.
- Shared/team handoffs: keep them in a normal docs location and commit them like other project docs.

If policy is unclear, ask before modifying `.gitignore`, `.git/info/exclude`, staging, or committing handoff files.
