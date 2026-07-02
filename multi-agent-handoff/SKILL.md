---
name: multi-agent-handoff
description: Use for project-local handoff coordination across manual Claude Code, Codex, or agent sessions: initialize, update, compact, prompt, study, or archive task handoff context.
---

# Multi-Agent Handoff

## Purpose

Use one compact index plus one focused task handoff per agent-level task. The index shows active, blocked, done, and archived work. Each task handoff owns the context, progress, artifacts, and next prompt for one resumable thread of work.

Default to `HandoffDocs/` as the project-local handoff root unless project or user instructions name a different root. Keep handoff files factual, incremental, and short enough for another agent to resume without replaying the whole conversation.

## Activation Boundary

Do not create or update handoff files for every conversation. Create or select a handoff only for concrete project work that benefits from continuity: code changes, investigation, debugging, validation, multi-agent delegation, artifact generation, or work likely to continue across sessions.

Do not initialize handoff context for casual chat, one-off Q&A, pure concept explanation, early brainstorming before a task is chosen, or reading-only discussion that will not create decisions, files, progress, or follow-up work. If a conversation becomes actionable, ask whether to create or attach a handoff topic.

## Directory Pattern

Use this default structure:

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

Rules:

- `handoff.md` is the coordination index only. Keep each row to one line of operational signal.
- `handoffs/<task-slug>.md` holds active or resumable task context. Use kebab-case slugs.
- `artifacts/<task-slug>/` holds process byproducts such as reports, scratch validation scripts, test outputs, debug dumps, and screenshots.
- `archive/`, `study/`, and historical artifacts are not default operational context. Do not read them during normal startup or continuation unless the user asks, the active handoff links to a specific file, or a command requires it.
- Never assume `HandoffDocs/` is private. Choose private/local or shared/team policy before changing ignore rules or committing handoff files.

## Command Routing

Slash commands are workflow gates. Natural-language requests such as "update the handoff" or "make a prompt for the next agent" should follow the matching command workflow.

When using one of these actions, read the matching command file before acting; the command file is the detailed workflow authority:

- `/inithandoff`: initialize or select the project handoff topic. Read `commands/inithandoff.md`.
- `/tracehandoff`: update the current handoff with progress, blockers, validation, or next steps. Read `commands/tracehandoff.md`.
- `/compacthandoff`: create a historical report, then compact oversized active handoff context without closing the task. Read `commands/compacthandoff.md`.
- `/handoffprompt`: generate a prompt packet for another manually launched agent or fresh session. Read `commands/handoffprompt.md`.
- `/archivehandoff`: audit and archive a closed, superseded, abandoned, stale, or failed-experiment task. Read `commands/archivehandoff.md`.
- `/study`: create a personal HTML learning note from a task, knowledge point, reflection, or summary. Read `commands/study.md`.

After a handoff-related action, suggest only the single next useful command plus a natural-language alternative, for example: `Next: /tracehandoff after the next code change, or just tell me "update the handoff".`

## Index And Task Ownership

Use `HandoffDocs/handoff.md` as a compact dashboard:

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

## Task Handoff Shape

Create one task handoff per manually launched agent-level task. Include these sections unless a command says otherwise:

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

Update the task handoff before real work begins once the requirement is clear. Update it again after meaningful edits, investigation, failed attempts, validation, returned agent summaries, blockers, or changed next steps. Prefer short append-only entries over rewriting history.

## Artifacts And Trust

Put temporary or process artifacts under `HandoffDocs/artifacts/<task-slug>/` with local timestamps like `YYYYMMDD-HHMMSS`. Keep handoff entries to conclusions plus artifact paths; do not paste long logs, generated reports, or raw test output into active handoffs.

Do not put deliverable source code, permanent tests, formal specs, migration files, official docs, or intentionally committed scripts under `HandoffDocs/artifacts/`. Those belong in the normal project tree or the owning workflow's directory.

Track every non-source or temporary file created outside `HandoffDocs/artifacts/<task-slug>/` in `Extra File Index`, unless it is an expected artifact owned by another workflow. Include path, why it exists, candidate decision label, and cleanup status.

Treat old timestamped artifacts as potentially stale until verified against active handoff context, current source/config, or fresh checks. Treat artifacts as stale candidates when they are older than 24 hours, older than relevant source/config changes, unreferenced by the active handoff, under another slug, under `archive/`, or in an unknown folder. Report stale or orphan candidates instead of trusting them silently.

Respect external workflow ownership. Do not move, archive, or classify expected outputs from other skills, frameworks, spec systems, docs workflows, test frameworks, or project-defined output directories as scattered handoff artifacts. If sources disagree, use this priority:

```text
External workflow formal artifacts > current source code/config > active task handoff > active artifacts explicitly referenced by handoff > archive/study/historical artifacts
```

## Context Length Policy

Use `/compacthandoff` when active context is still useful but too long. Compaction creates a historical report first, then rewrites the active handoff or index into shorter current context with links back to the report. It is not archival.

Target budgets:

- `HandoffDocs/handoff.md`: 120 lines.
- `HandoffDocs/handoffs/<task-slug>.md`: 260 lines.
- Active index `Done` and `Archived`: keep at most the most recent 20 rows each.
- Active index `Compacted History`: keep at most the most recent 10 rows.

Never remove unresolved blockers, risks, user-confirmation items, cleanup candidates, artifact paths, or `Extra File Index` rows during compaction. Do not read unrelated `archive/`, `study/`, or historical artifacts unless the active handoff or index links to a specific compact history report needed for the compaction.

## Global Safety Rules

Archive audit may inspect, classify, and propose actions, but must not silently move, copy, delete, or relocate files.

Without explicit user confirmation, agents may create or update handoff documents, create expected handoff directories, create compact-history report artifacts, read/list/classify candidate files, update the index through the local edit protocol, and add archive proposals, cleanup plans, or gentle labels to a task handoff.

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

When starting multi-agent work, select or create the handoff root, create the index if missing, split work into independent task slugs, create one task handoff per manual agent, put only summary rows in the index, and tell each agent to update its own task handoff plus its own index row.

When resuming, read `handoff.md` first. If the user names a slug or task, read that task handoff. If multiple active tasks exist and the user does not identify one, ask which task to resume or whether to create a new task. Do not read `archive/`, `study/`, or historical artifacts unless the user or active handoff points there.

When an agent returns, read its task handoff and summary, update task status and `Handoff Back`, update the corresponding index row, and move work to `Done` only when it is genuinely integrated or intentionally closed.

## Git And Privacy Policy

Follow the project's policy for whether handoffs are committed:

- Private/local handoffs: prefer adding `HandoffDocs/` or the configured handoff root to `.git/info/exclude` for local-only protection.
- Shared/team handoffs: keep them in a normal docs location and commit them like other project docs.

If policy is unclear, ask before modifying `.gitignore`, `.git/info/exclude`, staging, committing, or pushing handoff files.
