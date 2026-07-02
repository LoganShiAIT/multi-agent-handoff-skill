# Write Safety

Use these rules when a handoff command may create, edit, move, archive, delete, or classify files.

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

## Confirmation Gates

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

## Git And Privacy Policy

Never assume `HandoffDocs/` is private. Choose private/local or shared/team policy before changing ignore rules or committing handoff files.

- Private/local handoffs: prefer adding `HandoffDocs/` or the configured handoff root to `.git/info/exclude` for local-only protection.
- Shared/team handoffs: keep them in a normal docs location and commit them like other project docs.

If policy is unclear, ask before modifying `.gitignore`, `.git/info/exclude`, staging, committing, or pushing handoff files.

## Index Edit Protocol

For full handoffs, use `HandoffDocs/handoff.md` as a compact dashboard. Before editing it, re-read the file, change only the affected row or minimal section, preserve unrelated rows exactly, and merge locally if another agent changed the file.

Each agent owns its task handoff and may update only its own index row unless acting as a coordinator. If a safe merge is not obvious, update the task handoff with an index update request and ask the user or coordinator to reconcile.
