---
description: Audit and archive a handoff task to prevent stale context pollution
argument-hint: "<task-slug> [reason]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

Audit the task and workspace, then prepare an archive plan for one task handoff. This command is for tasks that are done, superseded, abandoned, stale, or failed experiments. It must not move, copy, delete, or relocate files until the user explicitly confirms those actions.

Workflow:

1. Read `HandoffDocs/handoff.md`.
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
6. Ask the user to confirm before performing any archive file operation. If confirmation is not available, stop after updating the task handoff and optionally update this task's index row to `archive-candidate` or `needs-user-confirmation`.
7. After confirmation, add or refresh an `Archive Summary` near the top:
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
10. Move or copy the task file to `HandoffDocs/archive/YYYY-MM/<task-slug>.md` exactly as confirmed.
11. Remove the task from Active or Blocked in `HandoffDocs/handoff.md` using a local row edit, preserving unrelated rows.
12. Add a one-line row to Archived with slug, archive date, reason, and replacement if any.
13. Delete the active `HandoffDocs/handoffs/<task-slug>.md` only if the user explicitly confirmed deletion and the archived copy plus index update both succeeded.
14. Leave `HandoffDocs/artifacts/<task-slug>/` in place unless the user explicitly confirmed artifact cleanup. Mark artifacts historical and not default operational context.

Never treat `delete-candidate` as permission to delete. Never delete archived task handoffs, active task handoffs, artifacts, or scattered workspace files unless the user explicitly confirms that deletion.

End with one next-step hint. Suggest `/study <topic>` if there is a personal learning to preserve, or natural language such as "make a study note from this task".
