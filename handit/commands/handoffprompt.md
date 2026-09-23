---
description: Generate an explicit, on-demand transfer prompt without saving it
argument-hint: "[--light | --full] <handoff-slug>"
allowed-tools: Read, Glob, Grep
---

Use the `handit` skill.

## Required References

None by default. Read `references/task-specs.md` only when the selected full handoff contains a Task Binding.

## Manual Trigger Gate

Run this command only when the user explicitly invokes `/handoffprompt` or clearly asks to generate, prepare, or package a prompt for another agent/session.

Do not run it because the user merely mentions another agent, future work, a later session, resumability, or a handoff. Do not create, save, cache, maintain, or proactively recommend generated prompt text.

Workflow:

1. Resolve mode and handoff slug. If ambiguous, ask which existing handoff to package.
2. Read only the selected light handoff, or the full index and selected full execution handoff.
3. For a task-bound full handoff:
   - Read its task record.
   - Verify the bound work item and required context paths.
   - Emit references to the task record, exact spec files, work item, and execution handoff.
   - Do not copy proposal, spec, design, or work-item prose into the prompt.
4. For an unbound legacy or direct handoff:
   - Include a compact mission and scope summary from the current handoff.
5. Require the receiving agent to follow the same commit/explicit-sync boundary below. Reference only the user-authorized mission or formal bound work item. Ignore legacy Next/equivalent advice; never copy it into the prompt or infer extra work.
6. Include scope boundaries, artifact placement, verification expectations, and return format.
7. Emit the prompt in the response only. Do not write a file or modify handoff state.

Task-bound template:

```markdown
You are executing `<work-item>` for task `<task-slug>`.

Read:
- `<task-record>`
- `<required-spec-paths>`
- `<execution-handoff>`

Use the Task Binding and `Context` section as the reading boundary. Execute only the bound work item. Do not edit task specs or other handoff slots unless the user explicitly expands scope.

Maintenance: follow Handit `SKILL.md` Automatic Checkpoint Boundary. Only an observed successful substantive current-task commit with this selected handoff, or an explicit sync/save request, permits a state update. Skip failed commits, handoff-only commits, and duplicate `checkpoint_commit` SHA; an authorized substantive amend can checkpoint its new SHA. Record the full SHA only with a successful automatic write. Manual sync preserves it, and no-change sync writes nothing. Returning findings or blockers alone causes no maintenance reads or writes. Never create, request, stage, amend, or push commits for maintenance; no polling or external-commit backfill. Report write failure without advancing the marker or retrying.

Save only known facts in State/Blocked and non-derivable Log facts. No extra tests/investigation to enrich records, no mandatory commit journal, no next-step plans or copied legacy Next. Preserve user scope and formal task references.
Update only the owned index row when its factual status changes. Put temporary execution artifacts under the bound artifact directory.

Return:
- What changed or was found
- Files touched
- Verification run
- Remaining blockers
```

Unbound template:

```markdown
You are working on `<handoff-slug>`.

Read `<handoff-path>` and follow its `Scope` and `Context` sections.

Scope:
- <compact current scope>

Maintenance: follow Handit `SKILL.md` Automatic Checkpoint Boundary. Only an observed successful substantive current-task commit with this selected handoff, or an explicit sync/save request, permits a state update. Skip failed commits, handoff-only commits, and duplicate `checkpoint_commit` SHA; an authorized substantive amend can checkpoint its new SHA. Record the full SHA only with a successful automatic write. Manual sync preserves it, and no-change sync writes nothing. Returning findings or blockers alone causes no maintenance reads or writes. Never create, request, stage, amend, or push commits for maintenance; no polling or external-commit backfill. Report write failure without advancing the marker or retrying.

Save only known facts in State/Blocked and non-derivable Log facts. No extra tests/investigation to enrich records, no mandatory commit journal, no next-step plans or copied legacy Next. Preserve user scope and formal task references.

Return:
- What changed or was found
- Files touched
- Verification run
- Remaining blockers
```

End after emitting the requested prompt.
