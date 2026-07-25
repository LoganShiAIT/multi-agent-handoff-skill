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

Use the Task Binding and Context Panel as the reading boundary. Execute only W-01. Do not edit task specs or other handoff slots unless the user explicitly expands scope.

Before returning:
- Update `HandoffDocs/handoffs/add-profile-filters--w-01.md` with progress, verification, blockers, and next step.
- Update only its owned row in `HandoffDocs/handoff.md` when operational status changed.
- Put temporary execution artifacts under `HandoffDocs/artifacts/add-profile-filters--w-01/`.

Return:
- What changed or was found
- Files touched
- Verification run
- Remaining blockers
```
