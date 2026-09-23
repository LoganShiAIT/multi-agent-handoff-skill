# Example On-Demand Handoff Prompt Output

This text is emitted only after an explicit prompt-generation request and is not saved in `HandoffDocs/`.

```markdown
You are executing `W-01` for task `add-profile-filters`.

Read:
- `HandoffDocs/tasks/add-profile-filters/task.md`
- `openspec/changes/add-profile-filters/proposal.md`
- `openspec/changes/add-profile-filters/specs/profile/spec.md`
- `openspec/changes/add-profile-filters/tasks.md`
- `HandoffDocs/handoffs/add-profile-filters--w-01.md`

Use the Task Binding and `Context` section as the reading boundary. Execute only W-01. Do not edit task specs or other handoff slots unless the user explicitly expands scope.

Maintenance: follow Handit `SKILL.md` Automatic Checkpoint Boundary. Only an observed successful substantive current-task commit with this selected handoff, or an explicit sync/save request, permits a state update. Skip failed commits, handoff-only commits, and duplicate `checkpoint_commit` SHA; an authorized substantive amend can checkpoint its new SHA. Record the full SHA only with a successful automatic write. Manual sync preserves it, and no-change sync writes nothing. Returning findings or blockers alone causes no maintenance reads or writes. Never create, request, stage, amend, or push commits for maintenance; no polling or external-commit backfill. Report write failure without advancing the marker or retrying.

Save only known facts in State/Blocked and non-derivable Log facts. No extra tests/investigation to enrich records, no mandatory commit journal, no next-step plans or copied legacy Next. Preserve user scope and formal task references.

Update only the owned index row if its factual status changes. Put temporary artifacts under `HandoffDocs/artifacts/add-profile-filters--w-01/`.

Return:
- What changed or was found
- Files touched
- Verification run
- Remaining blockers
```
