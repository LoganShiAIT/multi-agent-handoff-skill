# Write Safety

Use these rules when a handoff command may create, edit, move, archive, delete, or classify files.

## Filesystem Operations Checklist

Before creating or updating files, identify the handoff root, task slug or execution slug, target file, and whether the action writes a task record, execution handoff, index, artifact, archive candidate, or study note.

For every file operation:

- Create only expected directories: the root, `tasks/<task-slug>/`, `light/`, `handoffs/`, `artifacts/<execution-slug>/`, artifact category folders, `archive/YYYY-MM/`, or `study/<scope>/`.
- Create or update task-spec files only through an explicit task initialization/update action. Never write through a binding into an external spec workflow unless the user explicitly invokes that owning workflow.
- Write new execution handoffs and reports to the final intended path only after the parent directory exists.
- Before editing `HandoffDocs/handoff.md`, re-read it, update only the relevant row or compact section, and preserve unrelated rows exactly.
- Before rewriting an active handoff during compaction, create the compact-history report first. If report creation fails, stop and leave the active handoff unchanged.
- Put process artifacts under timestamped paths in `HandoffDocs/artifacts/<execution-slug>/`; if temporary files must exist elsewhere, record them in `Extra Files`.
- Treat archive, cleanup, move, delete, relocate, git ignore, stage, commit, and push actions as confirmation-gated. Propose them with gentle labels before acting.
- Do not delete or move files outside `HandoffDocs/artifacts/<execution-slug>/` without explicit user confirmation, even if they look temporary.
- If a local merge, overwrite, archive, or cleanup is not obviously safe, stop after recording the issue in the execution handoff and ask the user or coordinator to reconcile.

## Timestamp Discipline

Never write a timestamp from memory. Take artifact-name timestamps from the system clock with `date +%Y%m%d-%H%M%S`, and handoff date fields from `date '+%Y-%m-%d %H:%M:%S %Z'`. When judging whether an existing file is old or stale, compare filesystem modification times (`ls -lt`, `stat`) against the system clock instead of trusting the name alone.

## Confirmation Gates

Full archive audit may inspect, classify, and propose actions, but must not silently move, copy, delete, or relocate files.

Without explicit user confirmation, agents may create or update expected task records/internal task docs, light or full handoff documents, expected directories, compact-history report artifacts, candidate classifications, owned index rows, and archive proposals. Task readiness still requires explicit user confirmation.

Require explicit user confirmation before:

- Moving or copying an execution handoff into `archive/`.
- Deleting an active execution handoff after archiving.
- Moving, deleting, relocating, or cleaning artifacts.
- Deleting or moving any file outside `HandoffDocs/artifacts/<execution-slug>/`.
- Modifying `.gitignore`, `.git/info/exclude`, staging files, committing files, or pushing changes.

Use gentle labels before confirmation: `keep`, `move-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, `delete-candidate`, `archive-candidate`, `needs-user-confirmation`.

Use final labels only after the confirmed action is complete: `kept`, `moved`, `promoted`, `external-owned`, `ignored-as-stale`, `confirmed-orphan`, `deleted-confirmed`, `archived-confirmed`.

Never treat `delete-candidate` as permission to delete.

## Git And Privacy Policy

Never assume `HandoffDocs/` is private. Choose private/local or shared/team policy before changing ignore rules or committing handoff files.

- Private/local handoffs: prefer adding `HandoffDocs/` or the configured handoff root to `.git/info/exclude` for local-only protection.
- Shared/team handoffs: keep them in a normal docs location and commit them like other project docs.

If policy is unclear, ask before modifying `.gitignore`, `.git/info/exclude`, staging, committing, or pushing handoff files.

## Index Edit Protocol

For full handoffs, use `HandoffDocs/handoff.md` as a compact dashboard. Before editing it, re-read the file, change only the affected row or minimal section, preserve unrelated rows exactly, and merge locally if another agent changed the file.

Each agent owns its execution handoff and may update only its own index row unless acting as a coordinator. If a safe merge is not obvious, update the execution handoff with an index update request and ask the user or coordinator to reconcile.
