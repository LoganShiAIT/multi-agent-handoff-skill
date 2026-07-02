# Example Handoff Prompt Output

```markdown
You are working on `api-auth-investigation`.

First read `HandoffDocs/handoffs/api-auth-investigation.md`.

Mission:
- Identify why authenticated API calls return intermittent 401 responses in the sample service.
- Success means the next agent can reproduce the issue and continue from a focused test or patch.

Scope:
- Work only within the task boundaries in the handoff.
- Do not edit other handoff task files.
- You may update only your own task row in `HandoffDocs/handoff.md`; re-read the index immediately before editing, preserve unrelated rows, and make the smallest local edit.
- Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or old artifacts unless the handoff explicitly references a specific file.
- Treat old timestamped artifacts as potentially stale or orphaned. Report them and verify before relying on their contents.
- Do not move, delete, archive, or relocate files unless the user explicitly confirms that file operation.

Before returning:
- Append concise progress to `HandoffDocs/handoffs/api-auth-investigation.md`.
- Save generated reports, test scripts, test results, and temporary notes under timestamped paths in `HandoffDocs/artifacts/api-auth-investigation/`.
- Refresh the Handoff Back section with current state, next step, risks, and blockers.

Return:
- What you changed or found
- Files touched
- Verification run
- Remaining blockers
```
