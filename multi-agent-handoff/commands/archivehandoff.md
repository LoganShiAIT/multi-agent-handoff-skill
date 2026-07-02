---
description: Audit and archive a handoff task to prevent stale context pollution
argument-hint: "<task-slug> [reason]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

## Required References

Read these before auditing or archiving:

- `references/write-safety.md`
- `references/artifact-lifecycle.md`

Audit the task and workspace, then prepare an archive plan for one full task handoff. This command is for full handoff tasks that are done, superseded, abandoned, stale, or failed experiments. It must not move, copy, delete, or relocate files until the user explicitly confirms those actions.

This command applies only to full handoffs under `HandoffDocs/handoffs/`. If `$ARGUMENTS` names a light handoff under `HandoffDocs/light/`, stop and suggest either leaving the light note as-is, deleting it only with explicit user confirmation, or creating a full handoff first if archival governance is needed.

Workflow:

1. Read `HandoffDocs/handoff.md`. If it does not exist and only light handoffs exist, stop; there is no full index to archive from.
2. Resolve `$ARGUMENTS` to a task slug and archive reason. If missing or ambiguous, ask before moving anything.
3. Read `HandoffDocs/handoffs/<task-slug>.md`.
4. Run a pre-archive audit. Do not move, copy, delete, or relocate files during the audit:
   - Review `Extra File Index`.
   - Check `HandoffDocs/artifacts/<task-slug>/` for unindexed reports, scripts, results, dumps, screenshots, and misc files.
   - Check likely scattered locations such as project root, `tmp/`, `temp/`, `debug/`, `reports/`, `screenshots/`, and recently modified files with timestamped names.
   - Exclude expected artifacts owned by other skills, spec systems, docs workflows, test frameworks, or project-defined output directories.
   - If in a git repository, inspect changed and untracked files so temporary byproducts are not mistaken for deliverable source changes or external workflow artifacts.
   - Check whether another active handoff references this slug; if yes, add a replacement or dependency note before archiving.
   - Classify every suspicious file with gentle labels such as `keep`, `move-candidate`, `delete-candidate`, `promote-candidate`, `external-owned`, `ignore-as-stale-candidate`, `orphan-candidate`, or `needs-user-confirmation`.
5. Add or refresh an `Archive Plan` near the top:
   - Proposed At
   - Reason: done | superseded | abandoned | stale | failed-experiment
   - Final Outcome
   - Proposed Archive Path
   - Index Change
   - File Move/Delete Actions Requiring Confirmation
   - Gentle Labels Applied
   - Still Needs User Confirmation
6. Ask the user to confirm before performing any archive file operation. State that the default confirmed archive operation is a full move from `HandoffDocs/handoffs/` to `HandoffDocs/archive/YYYY-MM/`, and ask the user to explicitly say if they want copy-only/no active-file removal instead. If confirmation is not available, stop after updating the task handoff and optionally update this task's index row to `archive-candidate` or `needs-user-confirmation`.
7. After confirmation for a full archive move, add or refresh an `Archive Summary` near the top. If the user confirms copy-only/no active-file removal, keep it as an archive candidate and add a brief copied-archive note instead of an `Archive Summary`.
   - Archived At
   - Reason: done | superseded | abandoned | stale | failed-experiment
   - Final Outcome
   - Do Not Reuse
   - Useful If
   - Superseded By
   - Extra File Cleanup
   - Stale/Orphan Artifacts
   - Pre-Archive Audit
8. Create `HandoffDocs/archive/YYYY-MM/` if missing.
9. Re-read `HandoffDocs/handoff.md` immediately before editing.
10. By default, perform the confirmed archive as a move: create `HandoffDocs/archive/YYYY-MM/<task-slug>.md`, update the index, then remove the active `HandoffDocs/handoffs/<task-slug>.md` only after the archived file and index update both succeed.
11. If the user explicitly confirms copy-only/no active-file removal, copy the task file to the archive path, keep the active file indexed, and mark its active row as `archive-candidate` or `copied-to-archive` instead of adding a final Archived row.
12. For a confirmed move, remove the task from Active or Blocked in `HandoffDocs/handoff.md` using a local row edit, preserving unrelated rows.
13. For a confirmed move, add a one-line row to Archived with slug, archive date, reason, and replacement if any.
14. Leave `HandoffDocs/artifacts/<task-slug>/` in place unless the user explicitly confirmed artifact cleanup. Mark artifacts historical and not default operational context.

Never treat `delete-candidate` as permission to delete. Never delete archived task handoffs, active task handoffs, artifacts, or scattered workspace files unless the user explicitly confirms that deletion.

End with one next-step hint. Suggest `/study <topic>` if there is a personal learning to preserve, or natural language such as "make a study note from this task".
