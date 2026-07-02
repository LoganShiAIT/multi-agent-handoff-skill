---
description: Compact oversized active handoff context into historical report artifacts
argument-hint: "[task-slug | --index | --all]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

Compact oversized active full handoff context without closing the task. This command creates a historical report artifact first, then rewrites the active full handoff or index into a shorter current-context form with links back to the report.

This command applies only to full handoffs. Light handoffs are intentionally too small for compaction; if a light handoff is too long, recommend creating a full handoff after user confirmation. This is not an archive command. Do not move, delete, archive, relocate, stage, commit, push, or modify git metadata.

Modes:

- `<task-slug>`: Compact one active task handoff.
- `--index`: Compact `HandoffDocs/handoff.md`.
- `--all`: Compact the index if it is over budget, then compact each active task handoff that is over budget.

Workflow:

1. Read `HandoffDocs/handoff.md`. If it does not exist and only light handoffs exist, stop and recommend full handoff creation instead of compacting.
2. Resolve `$ARGUMENTS`:
   - If `$ARGUMENTS` is `--index`, operate only on the index.
   - If `$ARGUMENTS` is `--all`, inspect the index and active task handoffs for length budgets.
   - If `$ARGUMENTS` names a light slug under `HandoffDocs/light/`, stop and recommend full handoff creation.
   - If `$ARGUMENTS` names a full slug, read `HandoffDocs/handoffs/<task-slug>.md`.
   - If the slug is missing or ambiguous, list active tasks and ask which one to compact.
3. Use these target budgets:
   - `HandoffDocs/handoff.md`: 120 lines.
   - `HandoffDocs/handoffs/<task-slug>.md`: 260 lines.
   - Index `Compacted History`: keep at most 10 rows.
   - Index `Done` and `Archived`: keep at most the most recent 20 rows in active context.
4. For a task handoff compaction:
   - Create `HandoffDocs/artifacts/<task-slug>/reports/YYYYMMDD-HHMMSS-compact-history.md` before editing the active handoff.
   - The report must preserve the key historical details being removed or condensed: old `Progress Log`, old `Context Packet`, completed decisions, commands already run, relevant artifact paths, stale context notes, and the previous `Handoff Back`.
   - Stop if the report cannot be created. Do not rewrite the active handoff.
   - Preserve complete `Metadata`, `Mission`, `Artifacts`, `Study Notes`, `Extra File Index`, and current `Handoff Back`.
   - Replace old or repetitive progress with a short `Compacted Summary` that keeps only facts still needed for current continuation.
   - Add or update `Compacted History` with one row linking to the report.
   - Never remove unresolved blockers, risks, user-confirmation items, cleanup candidates, or `Extra File Index` rows.
5. For index compaction:
   - Create `HandoffDocs/artifacts/handoff-index/reports/YYYYMMDD-HHMMSS-compact-history.md` before editing `HandoffDocs/handoff.md`.
   - The report must preserve any older `Done`, `Archived`, or `Compacted History` rows removed from the active index, plus a short explanation of what was compacted.
   - Stop if the report cannot be created. Do not rewrite the index.
   - Re-read `HandoffDocs/handoff.md` immediately before editing.
   - Preserve all `Active` and `Blocked` rows. Shorten long `Scope`, `Next Action`, `Blocker`, or `Needed` text into one-line operational signal.
   - Keep only the most recent 20 rows in `Done` and `Archived`; move older rows into the report. If dates do not make recency clear, preserve existing order and treat lower rows as newer.
   - Keep a short `Compacted History` section at the bottom of the index with at most 10 rows linking to index compact history reports.
6. Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or historical artifacts unless the active handoff or index explicitly links to a specific compact history report that is needed for the compaction.
7. End with the compacted target, report path, remaining line count if checked, and one next-step hint. Suggest `/tracehandoff <task-slug>` for continuing active work, `/handoffprompt <task-slug>` if another agent should continue, or `/archivehandoff <task-slug>` if the task is actually ready to close.
