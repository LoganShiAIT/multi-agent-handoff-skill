---
description: Explore whether work needs no state, task planning, or a light/full handoff
argument-hint: "[task/topic/question]"
allowed-tools: Read, Glob, Grep, Bash(git status:*), Bash(git log:*), Bash(ls:*)
---

Use the `multi-agent-handoff` skill.

## Required References

None. Keep exploration read-only and do not load `references/`.

Inspect the project and classify the requested work without creating or editing `HandoffDocs/`, project files, or git metadata.

Workflow:

1. Clarify the task/topic from the user request or `$ARGUMENTS`.
2. Inspect only README, manifests, project instructions, likely spec roots, relevant entry points, and active handoff/task listings needed to understand task shape.
3. Do not read archive, study, or historical artifacts unless explicitly required.
4. Classify:
   - `none`: one-off answer or reading-only discovery.
   - `task`: requirements discussion, spec binding, design decisions, multiple work items, or orchestration should precede execution.
   - `light`: one focused continuation note without formal orchestration.
   - `full`: direct execution needs index, artifacts, blockers, archive, or multi-agent ownership but no separate task spec is needed.
5. Check whether OpenSpec, OPSX, or a project-defined formal spec appears to own the task. Report candidates without selecting among ambiguous changes.

Output exactly:

```markdown
## Exploration Result
- Topic:
- Checked:
- Key findings:
- Task shape:
- Coordination recommendation: none | task | light | full
- Spec source candidates:
- Suggested next action:
```

If recommending task planning, give a kebab-case slug and say `/inittask <slug>` can initialize or bind it. If recommending a handoff, give the matching `/inithandoff --light|--full <slug>` action. These are the only routine command transitions this skill may proactively recommend.
