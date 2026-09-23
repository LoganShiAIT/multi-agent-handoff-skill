# Example On-Demand Light Handoff Prompt Output

This text is emitted only after an explicit prompt-generation request and is not stored in the light handoff.

```markdown
You are working from light handoff `api-auth-investigation`.

First read `HandoffDocs/light/api-auth-investigation.md`.

Goal:
- Check why API auth sometimes returns 401 after token refresh.
- Keep the work scoped to API client retry behavior.

Scope:
- Use only the selected light handoff for authorized state writes.
- Do not create full handoff index, artifacts, archive, study notes, or cleanup records unless the user explicitly asks.
- If the work exceeds this light handoff's scope, report the blocker and return without silently expanding the file.

Maintenance: follow Handit `SKILL.md` Automatic Checkpoint Boundary. Only an observed successful substantive current-task commit with this selected handoff, or an explicit sync/save request, permits a state update. Skip failed commits, handoff-only commits, and duplicate `checkpoint_commit` SHA; an authorized substantive amend can checkpoint its new SHA. Record the full SHA only with a successful automatic write. Manual sync preserves it, and no-change sync writes nothing. Returning findings or blockers alone causes no maintenance reads or writes. Never create, request, stage, amend, or push commits for maintenance; no polling or external-commit backfill. Report write failure without advancing the marker or retrying.

Save only known facts in State/Blocked and non-derivable Log facts. No extra tests/investigation to enrich records, no mandatory commit journal, no next-step plans or copied legacy Next. Preserve user scope and formal task references.

Return:
- What you changed or found
- Files touched
- Verification run
- Remaining blockers
```
