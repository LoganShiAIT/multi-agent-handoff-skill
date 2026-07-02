# Artifact Lifecycle

Use these rules for full handoffs that create, reference, compact, archive, or clean up process artifacts.

## Artifacts And Trust

Put temporary or process artifacts under `HandoffDocs/artifacts/<task-slug>/` with local timestamps like `YYYYMMDD-HHMMSS`. Keep handoff entries to conclusions plus artifact paths; do not paste long logs, generated reports, or raw test output into active handoffs.

Do not put deliverable source code, permanent tests, formal specs, migration files, official docs, or intentionally committed scripts under `HandoffDocs/artifacts/`. Those belong in the normal project tree or the owning workflow's directory.

Track every non-source or temporary file created outside `HandoffDocs/artifacts/<task-slug>/` in `Extra File Index`, unless it is an expected artifact owned by another workflow. Include path, why it exists, candidate decision label, and cleanup status.

Treat old timestamped artifacts as potentially stale until verified against active handoff context, current source/config, or fresh checks. Treat artifacts as stale candidates when they are older than 24 hours, older than relevant source/config changes, unreferenced by the active handoff, under another slug, under `archive/`, or in an unknown folder. Report stale or orphan candidates instead of trusting them silently.

Respect external workflow ownership. Do not move, archive, or classify expected outputs from other skills, frameworks, spec systems, docs workflows, test frameworks, or project-defined output directories as scattered handoff artifacts. If sources disagree, use this priority:

```text
External workflow formal artifacts > current source code/config > active task handoff > active artifacts explicitly referenced by handoff > archive/study/historical artifacts
```

## Artifact Paths

Use these paths for generated debugging or acceptance artifacts:

- Reports: `HandoffDocs/artifacts/<task-slug>/reports/YYYYMMDD-HHMMSS-short-title.md`
- Test scripts: `HandoffDocs/artifacts/<task-slug>/test-scripts/YYYYMMDD-HHMMSS-short-title.<ext>`
- Test results: `HandoffDocs/artifacts/<task-slug>/test-results/YYYYMMDD-HHMMSS-short-title.<ext>`
- Other temporary outputs: `HandoffDocs/artifacts/<task-slug>/misc/YYYYMMDD-HHMMSS-short-title.<ext>`

If a temporary document, script, test output, report, screenshot, fixture, dump, or scratch config was created outside `HandoffDocs/artifacts/<task-slug>/`, add it to the task handoff's `Extra File Index`:

```markdown
| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |
```

Prefer creating handoff-owned process artifacts directly under `HandoffDocs/artifacts/<task-slug>/`. If a file already exists elsewhere, mark it as `move-candidate` before user confirmation. If a file should become part of the real project or belongs to another workflow's declared layout, mark it as `promote-candidate`, `keep`, or `external-owned` and explain why. Do not move, delete, or relocate files without explicit user confirmation.

## Context Length Policy

Use `/compacthandoff` when full active context is still useful but too long. Compaction creates a historical report first, then rewrites the active full handoff or index into shorter current context with links back to the report. It is not archival.

Light handoffs should stay short. If they become too long, recommend full handoff creation instead of compacting.

Target budgets:

- `HandoffDocs/handoff.md`: 120 lines.
- `HandoffDocs/handoffs/<task-slug>.md`: 260 lines.
- Active index `Done` and `Archived`: keep at most the most recent 20 rows each.
- Active index `Compacted History`: keep at most the most recent 10 rows.

Never remove unresolved blockers, risks, user-confirmation items, cleanup candidates, artifact paths, or `Extra File Index` rows during compaction. Do not read unrelated `archive/`, `study/`, or historical artifacts unless the active handoff or index links to a specific compact history report needed for the compaction.

## Archive Constraints

Full archive audit may inspect, classify, and propose actions, but must not silently move, copy, delete, or relocate files.

Before a confirmed archive, check whether another active handoff references the slug. If yes, add a replacement or dependency note before archiving.

The default confirmed archive operation is a full move from `HandoffDocs/handoffs/` to `HandoffDocs/archive/YYYY-MM/`. If the user confirms copy-only/no active-file removal, keep it as an archive candidate and add a copied-archive note instead of treating it as fully archived.

Leave `HandoffDocs/artifacts/<task-slug>/` in place unless the user explicitly confirmed artifact cleanup. Mark artifacts historical and not default operational context.
