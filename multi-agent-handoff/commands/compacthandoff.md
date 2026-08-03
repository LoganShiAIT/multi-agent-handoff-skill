---
description: Compact oversized active handoff context into historical report artifacts
argument-hint: "[execution-slug | --index | --all]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read these before compacting:

- `references/write-safety.md`
- `references/artifact-lifecycle.md`
- `references/handoff-formats.md` when migrating a legacy handoff to the current structure

This command is the fallback, not the primary length control. `Record Lifecycle` in `references/artifact-lifecycle.md` evicts dead records incrementally on every write, and a handoff maintained that way should not need compaction. Reach for this command in two cases only:

- A handoff grew past budget despite incremental eviction.
- A handoff still uses the legacy structure and needs migrating.

If a handoff is over budget only because it holds many genuinely live records, do not compact it. Report that the slot's scope is too large and stop.

Compact oversized active full handoff context without closing the task. This command creates a historical report artifact first, then rewrites the active full handoff or index into a shorter current-context form with links back to the report.

This command applies only to full handoffs. Light handoffs are intentionally too small for compaction; report that the selected light handoff is unsupported and stop. This is not an archive command. Do not move, delete, archive, relocate, stage, commit, push, or modify git metadata.

Modes:

- `<execution-slug>`: Compact one active execution handoff.
- `--index`: Compact `HandoffDocs/handoff.md`.
- `--all`: Compact the index if it is over budget, then compact each active execution handoff that is over budget.

Workflow:

1. Read `HandoffDocs/handoff.md`. If it does not exist and only light handoffs exist, report that compaction requires an existing full handoff and stop.
2. Resolve `$ARGUMENTS`:
   - If `$ARGUMENTS` is `--index`, operate only on the index.
   - If `$ARGUMENTS` is `--all`, inspect the index and active execution handoffs for length budgets.
   - If `$ARGUMENTS` names a light slug under `HandoffDocs/light/`, report that light handoffs are outside this command's scope and stop.
   - If `$ARGUMENTS` names a full slug, read `HandoffDocs/handoffs/<execution-slug>.md`.
   - If the slug is missing or ambiguous, list active tasks and ask which one to compact.
3. Use these target budgets:
   - `HandoffDocs/handoff.md`: 120 lines.
   - `HandoffDocs/handoffs/<execution-slug>.md`: 120 lines.
   - Active handoff `History`: keep at most 10 rows.
   - Index `Done` and `Archived`: keep at most the most recent 20 rows in active context.
4. For an execution handoff compaction:
   - Create `HandoffDocs/artifacts/<execution-slug>/reports/YYYYMMDD-HHMMSS-compact-history.md` before editing the active handoff.
   - The report must preserve the key historical details being removed or condensed: every dropped record, relevant artifact paths, stale context notes, the previous status, and any legacy stored transfer-prompt field. When migrating a legacy handoff, this includes its `Progress Log`, `Findings and Decisions`, `Context Packet`, and `Handoff Back` contents.
   - Stop if the report cannot be created. Do not rewrite the active handoff.
   - Preserve complete frontmatter, the status block, `Scope`, `Context`, `Task Binding` when present, `Artifacts`, `Study Notes`, and `Extra Files`.
   - Preserve every live record. Drop only records already dead under `Record Lifecycle`, and prefer appending those to `history.md` over writing a report.
   - Omit legacy stored transfer-prompt fields from active context after their contents are preserved in the report.
   - Add or update `History` with one row linking to the report.
   - Never remove unresolved blockers, risks, user-confirmation items, cleanup candidates, or `Extra Files` rows.
5. For a legacy-structure migration:
   - Move machine fields from `Metadata` into frontmatter.
   - Rewrite `Handoff Back` as the status block at the top.
   - Merge `Mission` into `Scope`, and `Context Panel` plus `Context Packet` into `Context`, dropping which files a previous agent read and which commands it ran.
   - Merge `Progress Log` and `Findings and Decisions` into `Log`, keeping only records still live under `Record Lifecycle`.
   - Drop every empty section rather than carrying it forward.
6. For index compaction:
   - Create `HandoffDocs/artifacts/handoff-index/reports/YYYYMMDD-HHMMSS-compact-history.md` before editing `HandoffDocs/handoff.md`.
   - The report must preserve any older `Done` or `Archived` rows removed from the active index, plus a short explanation of what was compacted.
   - Stop if the report cannot be created. Do not rewrite the index.
   - Re-read `HandoffDocs/handoff.md` immediately before editing.
   - Preserve all `Active` and `Blocked` rows. Shorten long `Next Action`, `Blocker`, or `Needed` text into one-line operational signal.
   - Keep only the most recent 20 rows in `Done` and `Archived`; move older rows into the report. If dates do not make recency clear, preserve existing order and treat lower rows as newer.
7. Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or historical artifacts unless the active handoff or index explicitly links to a specific compact history report that is needed for the compaction.
8. Report the compacted target, report path, remaining line count if checked, preserved Task Binding, and unresolved blockers. End after reporting.
