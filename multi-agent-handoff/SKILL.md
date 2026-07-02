---
name: multi-agent-handoff
description: Use for explore-first project handoff coordination across manual Claude Code, Codex, or agent sessions: read-only handoff exploration, light or full handoff initialization, progress updates, transfer prompts, compaction, study notes, and archival.
---

# Multi-Agent Handoff

## Purpose

Start by exploring whether work deserves durable handoff tracking. Use light handoffs for single-task resumability and full handoffs for project-level coordination. Full handoffs use one compact index plus one focused task handoff per agent-level task. The index shows active, blocked, done, and archived work. Each full task handoff owns the context, progress, artifacts, and next prompt for one resumable thread of work.

Default to `HandoffDocs/` as the project-local handoff root unless project or user instructions name a different root. Keep handoff files factual, incremental, and short enough for another agent to resume without replaying the whole conversation.

## Activation Boundary

Do not create or update handoff files for every conversation. Use `/explorehandoff` first when the task shape is unclear. Create or select a handoff only for concrete project work that benefits from continuity: code changes, investigation, debugging, validation, multi-agent delegation, artifact generation, or work likely to continue across sessions.

Do not initialize handoff context for casual chat, one-off Q&A, pure concept explanation, early brainstorming before a task is chosen, or reading-only discussion that will not create decisions, files, progress, or follow-up work. If exploration finds no durable thread, recommend no handoff. If work becomes actionable, recommend light or full and ask before creating full.

## Explore-First Policy

Default to light exploration, not light writing. During exploration, inspect only the files and commands needed to understand the task, then report:

- What was checked.
- What was learned.
- Likely task shape.
- Handoff recommendation: `none`, `light`, or `full`.
- Next action.

Do not create `HandoffDocs/`, write handoff files, modify git metadata, or modify project files during `/explorehandoff`. Keep exploration focused on whether the work deserves no handoff, a light handoff, or a full handoff.

## Directory Pattern

Use this default structure. Light handoffs may use only `HandoffDocs/light/`; full handoffs use the complete structure:

```text
HandoffDocs/
|-- light/
|   |-- <task-slug>.md
|   `-- ...
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

Rules:

- `light/<task-slug>.md` is a single-task continuation note. It does not require an index, artifacts, archive, study notes, compaction, or stale-artifact scanning.
- `handoff.md` is the coordination index only. Keep each row to one line of operational signal.
- `handoffs/<task-slug>.md` holds full active or resumable task context. Use kebab-case slugs.
- `artifacts/<task-slug>/` holds full handoff process byproducts such as reports, scratch validation scripts, test outputs, debug dumps, and screenshots.
- `archive/`, `study/`, and historical artifacts are not default operational context. Do not read them during normal startup or continuation unless the user asks, the active handoff links to a specific file, or a command requires it.
- Never assume `HandoffDocs/` is private. Choose private/local or shared/team policy before changing ignore rules or committing handoff files.

## Light Vs Full Handoff

Use a light handoff when work needs a small project-local continuation note but not project-level coordination. A light handoff is one file at `HandoffDocs/light/<task-slug>.md` with:

```markdown
# <Task Title>

## Intent
- User request:
- Goal:
- Scope:

## Current Understanding
- Key facts:
- Files inspected:
- Commands run:

## Progress
-

## Next
- Recommended next step:
- Verification:
- Handoff prompt:
```

Use a full handoff when work needs multiple agents, cross-session project state, artifacts, blocked/done/archive status, stale artifact trust rules, compaction, study notes, or cleanup tracking.

Ask before creating a full handoff unless the user explicitly requested full project handoff management. Do not create a separate temp tier by default. If the user explicitly asks to save scattered exploration without project tracking, provide a one-off exported summary outside the project index.

## Command Routing

Slash commands are workflow gates. Natural-language requests such as "update the handoff" or "make a prompt for the next agent" should follow the matching command workflow.

When using one of these actions, read the matching command file before acting; the command file is the detailed workflow authority:

- `/explorehandoff`: inspect the project and recommend no handoff, light handoff, or full handoff without writing files. Read `commands/explorehandoff.md`.
- `/inithandoff`: create or select a light or full project handoff after exploration. Read `commands/inithandoff.md`.
- `/tracehandoff`: update the current handoff with progress, blockers, validation, or next steps. Read `commands/tracehandoff.md`.
- `/compacthandoff`: create a historical report, then compact oversized active handoff context without closing the task. Read `commands/compacthandoff.md`.
- `/handoffprompt`: generate a prompt packet for another manually launched agent or fresh session. Read `commands/handoffprompt.md`.
- `/archivehandoff`: audit and archive a closed, superseded, abandoned, stale, or failed-experiment task. Read `commands/archivehandoff.md`.
- `/study`: create a personal HTML learning note from a task, knowledge point, reflection, or summary. Read `commands/study.md`.

After a handoff-related action, suggest only the single next useful command plus a natural-language alternative, for example: `Next: /tracehandoff after the next code change, or just tell me "update the handoff".`

## Index And Task Ownership

For full handoffs, use `HandoffDocs/handoff.md` as a compact dashboard:

```markdown
# Handoff Index

## Active
| Slug | Owner | Status | Scope | Next Action | Updated |
| --- | --- | --- | --- | --- | --- |

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

Before editing the index, re-read `HandoffDocs/handoff.md`, change only the affected row or minimal section, preserve unrelated rows exactly, and merge locally if another agent changed the file. If a safe merge is not obvious, update the task handoff with an index update request and ask the user or coordinator to reconcile.

Each agent owns its task handoff and may update only its own index row unless acting as a coordinator. If two agents need the same files or domain, merge the task under one owner or make the dependency explicit in both task handoffs.

Record branch or worktree in the task handoff and index row when multiple branches or worktrees are involved.

## Full Task Handoff Shape

Create one full task handoff per manually launched agent-level task. Include these sections unless a command says otherwise:

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
| Path | Topic | Key Lesson | Created |
| --- | --- | --- | --- |

## Compacted History
| Record | Covered Range | Summary | Created |
| --- | --- | --- | --- |

## Extra File Index
| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |

## Handoff Back
- Current state:
- Next recommended step:
- Risks / blockers:
- Prompt for the next agent:
```

Update the full task handoff before real work begins once the requirement is clear. Update it again after meaningful edits, investigation, failed attempts, validation, returned agent summaries, blockers, or changed next steps. Prefer short append-only entries over rewriting history.

## Artifacts And Trust

These rules apply to full handoffs. Put temporary or process artifacts under `HandoffDocs/artifacts/<task-slug>/` with local timestamps like `YYYYMMDD-HHMMSS`. Keep handoff entries to conclusions plus artifact paths; do not paste long logs, generated reports, or raw test output into active handoffs.

Do not put deliverable source code, permanent tests, formal specs, migration files, official docs, or intentionally committed scripts under `HandoffDocs/artifacts/`. Those belong in the normal project tree or the owning workflow's directory.

Track every non-source or temporary file created outside `HandoffDocs/artifacts/<task-slug>/` in `Extra File Index`, unless it is an expected artifact owned by another workflow. Include path, why it exists, candidate decision label, and cleanup status.

Treat old timestamped artifacts as potentially stale until verified against active handoff context, current source/config, or fresh checks. Treat artifacts as stale candidates when they are older than 24 hours, older than relevant source/config changes, unreferenced by the active handoff, under another slug, under `archive/`, or in an unknown folder. Report stale or orphan candidates instead of trusting them silently.

Respect external workflow ownership. Do not move, archive, or classify expected outputs from other skills, frameworks, spec systems, docs workflows, test frameworks, or project-defined output directories as scattered handoff artifacts. If sources disagree, use this priority:

```text
External workflow formal artifacts > current source code/config > active task handoff > active artifacts explicitly referenced by handoff > archive/study/historical artifacts
```

## Context Length Policy

Use `/compacthandoff` when full active context is still useful but too long. Compaction creates a historical report first, then rewrites the active full handoff or index into shorter current context with links back to the report. It is not archival. Light handoffs should stay short; if they become too long, recommend full handoff creation instead of compacting.

Target budgets:

- `HandoffDocs/handoff.md`: 120 lines.
- `HandoffDocs/handoffs/<task-slug>.md`: 260 lines.
- Active index `Done` and `Archived`: keep at most the most recent 20 rows each.
- Active index `Compacted History`: keep at most the most recent 10 rows.

Never remove unresolved blockers, risks, user-confirmation items, cleanup candidates, artifact paths, or `Extra File Index` rows during compaction. Do not read unrelated `archive/`, `study/`, or historical artifacts unless the active handoff or index links to a specific compact history report needed for the compaction.

## Filesystem Operations Checklist

Before creating or updating handoff files, identify the handoff root, task slug, target file, and whether the action writes an index, task handoff, artifact, archive candidate, or study note.

For every file operation:

- Create only expected handoff directories: the root, `light/`, `handoffs/`, `artifacts/<task-slug>/`, artifact category folders, `archive/YYYY-MM/`, or `study/<scope>/`.
- Write new task handoffs and reports to the final intended path only after the parent directory exists.
- Before editing `HandoffDocs/handoff.md`, re-read it, update only the relevant row or compact section, and preserve unrelated rows exactly.
- Before rewriting an active handoff during compaction, create the compact-history report first. If report creation fails, stop and leave the active handoff unchanged.
- Put process artifacts under timestamped paths in `HandoffDocs/artifacts/<task-slug>/`; if temporary files must exist elsewhere, record them in `Extra File Index`.
- Treat archive, cleanup, move, delete, relocate, git ignore, stage, commit, and push actions as confirmation-gated. Propose them with gentle labels before acting.
- Do not delete or move files outside `HandoffDocs/artifacts/<task-slug>/` without explicit user confirmation, even if they look temporary.
- If a local merge, overwrite, archive, or cleanup is not obviously safe, stop after recording the issue in the task handoff and ask the user or coordinator to reconcile.

## Global Safety Rules

Full archive audit may inspect, classify, and propose actions, but must not silently move, copy, delete, or relocate files.

Without explicit user confirmation, agents may create or update light or full handoff documents, create expected handoff directories, create compact-history report artifacts for full handoffs, read/list/classify candidate files, update the full index through the local edit protocol, and add archive proposals, cleanup plans, or gentle labels to a full task handoff.

Require explicit user confirmation before:

- Moving or copying a task handoff into `archive/`.
- Deleting an active task handoff after archiving.
- Moving, deleting, relocating, or cleaning artifacts.
- Deleting or moving any file outside `HandoffDocs/artifacts/<task-slug>/`.
- Modifying `.gitignore`, `.git/info/exclude`, staging files, committing files, or pushing changes.

Use gentle labels before confirmation: `keep`, `move-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, `delete-candidate`, `archive-candidate`, `needs-user-confirmation`.

Use final labels only after the confirmed action is complete: `kept`, `moved`, `promoted`, `external-owned`, `ignored-as-stale`, `confirmed-orphan`, `deleted-confirmed`, `archived-confirmed`.

Never treat `delete-candidate` as permission to delete.

## Coordinator Workflow

When starting full multi-agent work, select or create the handoff root, create the index if missing, split work into independent task slugs, create one full task handoff per manual agent, put only summary rows in the index, and tell each agent to update its own task handoff plus its own index row.

When resuming full work, read `handoff.md` first. If the user names a light slug, read `HandoffDocs/light/<task-slug>.md` instead. If the user names a full slug or task, read that full task handoff. If multiple active tasks exist and the user does not identify one, ask which task to resume or whether to create a new task. Do not read `archive/`, `study/`, or historical artifacts unless the user or active handoff points there.

When an agent returns from full work, read its task handoff and summary, update task status and `Handoff Back`, update the corresponding index row, and move work to `Done` only when it is genuinely integrated or intentionally closed. For light work, update only the light file's `Progress` and `Next` sections.

## Git And Privacy Policy

Follow the project's policy for whether handoffs are committed:

- Private/local handoffs: prefer adding `HandoffDocs/` or the configured handoff root to `.git/info/exclude` for local-only protection.
- Shared/team handoffs: keep them in a normal docs location and commit them like other project docs.

If policy is unclear, ask before modifying `.gitignore`, `.git/info/exclude`, staging, committing, or pushing handoff files.
