# Artifact Lifecycle

Use these rules for full handoffs that create, reference, compact, archive, or clean up process artifacts.

## Artifacts And Trust

Put temporary or process artifacts under `HandoffDocs/artifacts/<execution-slug>/` with local timestamps like `YYYYMMDD-HHMMSS`. Keep handoff entries to conclusions plus artifact paths; do not paste long logs, generated reports, or raw test output into active handoffs.

Do not put deliverable source code, permanent tests, formal specs, migration files, official docs, or intentionally committed scripts under `HandoffDocs/artifacts/`. Those belong in the normal project tree or the owning workflow's directory.

Track every non-source or temporary file created outside `HandoffDocs/artifacts/<execution-slug>/` in `Extra Files`, unless it is an expected artifact owned by another workflow. Include path, why it exists, candidate decision label, and cleanup status.

Treat old timestamped artifacts as potentially stale until verified against active handoff context, current source/config, or fresh checks. Treat artifacts as stale candidates when they are older than 24 hours, older than relevant source/config changes, unreferenced by the active handoff, under another slug, under `archive/`, or in an unknown folder. Report stale or orphan candidates instead of trusting them silently.

Respect task-spec and external workflow ownership. Do not move, archive, or classify expected outputs from other skills, frameworks, spec systems, docs workflows, test frameworks, or project-defined output directories as scattered handoff artifacts.

```text
Planned intent: external or internal task spec
Implemented behavior: current source code and configuration
Execution progress: active execution handoff
Historical evidence: referenced active artifacts, then archive/study/history
```

Do not collapse these fact types into one precedence rule. If planned intent and implemented behavior differ, record the gap in the execution handoff instead of treating either as stale.

## Artifact Paths

Use these paths for generated debugging or acceptance artifacts:

- Reports: `HandoffDocs/artifacts/<execution-slug>/reports/YYYYMMDD-HHMMSS-short-title.md`
- Test scripts: `HandoffDocs/artifacts/<execution-slug>/test-scripts/YYYYMMDD-HHMMSS-short-title.<ext>`
- Test results: `HandoffDocs/artifacts/<execution-slug>/test-results/YYYYMMDD-HHMMSS-short-title.<ext>`
- Other temporary outputs: `HandoffDocs/artifacts/<execution-slug>/misc/YYYYMMDD-HHMMSS-short-title.<ext>`

If a temporary document, script, test output, report, screenshot, fixture, dump, or scratch config was created outside `HandoffDocs/artifacts/<execution-slug>/`, add it to the execution handoff's `Extra Files`:

```markdown
| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |
```

Create each subdirectory only when writing a file into it. Never pre-create the full artifact tree; empty directories are the same defect as an empty section, and they make a slot look like it produced evidence it never produced.

Prefer creating handoff-owned process artifacts directly under `HandoffDocs/artifacts/<execution-slug>/`. If a file already exists elsewhere, mark it as `move-candidate` before user confirmation. If a file should become part of the real project or belongs to another workflow's declared layout, mark it as `promote-candidate`, `keep`, or `external-owned` and explain why. Do not move, delete, or relocate files without explicit user confirmation.

## Record Lifecycle

A log record earns space in active context only while it still changes what the next agent will do. Evict it once it is dead.

A record dies when it is superseded, landed, or resolved:

- **Superseded** — a later record replaces its conclusion.
- **Landed** — the decision now exists in code, configuration, or a spec, so it is derivable from the repository.
- **Resolved** — the blocker is cleared or the open question is answered.

`Landed` is the common case. A decision that ships stops earning a slot, because the repository now carries it. The practical consequence is that successful work expires on its own, while failure does not.

Never evict failed attempts, rejected alternatives, or unresolved blockers. None of those leave a trace in the repository, so the handoff is the only place they can survive.

These are state tests, not importance judgements. Ask whether a record is still true and still load-bearing, not whether it seems significant.

### When To Evict

Evict incrementally, on every write to `Log`. After appending a record, check whether the new record supersedes, lands, or resolves anything already present, and evict what it killed.

Do not wait for a size threshold. A threshold means every session between thresholds loads dead context.

### Where Evicted Records Go

Append them to `HandoffDocs/artifacts/<execution-slug>/history.md`, oldest first, each with its eviction date and cause. Add or update one `History` row in the active handoff linking to that file.

Move, never delete. Eviction removes a record from default context; it does not destroy it. Creating and appending to `history.md` requires no user confirmation. Deleting it does.

### Scope Alarm

If a slot still holds more than 10 live records after eviction, do not compact them. Report that the slot's scope is probably too large and that splitting it is the fix.

A high count of genuinely live records is a scoping problem, not a length problem. Compacting real decisions to satisfy a budget destroys the only copy.

## Context Length Policy

Incremental eviction is the primary length control. `/compacthandoff` is the fallback for handoffs that eviction did not keep small enough, or that still use an older structure.

Light handoffs should stay short. If one is too long, report that it is outside compaction scope and stop without turning compaction into another command flow.

Target budgets:

- `HandoffDocs/handoff.md`: 120 lines.
- `HandoffDocs/handoffs/<execution-slug>.md`: 120 lines.
- Active index `Done` and `Archived`: keep at most the most recent 20 rows each.
- Active handoff `History`: keep at most the most recent 10 rows.

Never remove unresolved blockers, risks, user-confirmation items, cleanup candidates, artifact paths, or `Extra Files` rows during compaction. Do not read unrelated `archive/`, `study/`, or historical artifacts unless the active handoff or index links to a specific compact history report needed for the compaction.

## Archive Constraints

Full archive audit may inspect, classify, and propose actions, but must not silently move, copy, delete, or relocate files.

Before a confirmed archive, check whether another active handoff or task record references the execution slug. If yes, add a replacement or dependency note before archiving.

The default confirmed archive operation is a full move from `HandoffDocs/handoffs/` to `HandoffDocs/archive/YYYY-MM/`. If the user confirms copy-only/no active-file removal, keep it as an archive candidate and add a copied-archive note instead of treating it as fully archived.

Leave `HandoffDocs/artifacts/<execution-slug>/` in place unless the user explicitly confirmed artifact cleanup. Mark artifacts historical and not default operational context.

Archive execution handoffs independently from task specs. Never move a task directory with an execution archive. After a confirmed move, a coordinator may update only the task record's execution-binding path/status.
