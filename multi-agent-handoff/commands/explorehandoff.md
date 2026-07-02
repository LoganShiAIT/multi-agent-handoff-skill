---
description: Explore whether work needs no handoff, a light handoff, or a full handoff
argument-hint: "[task/topic/question]"
allowed-tools: Read, Glob, Grep, LS, Bash
---

Use the `multi-agent-handoff` skill.

Explore the project and task shape before creating any handoff. This command is read-only for handoff state: do not create, edit, move, delete, archive, stage, commit, push, or modify `HandoffDocs/`, git metadata, or project files.

Workflow:

1. Clarify the user's request or `$ARGUMENTS` into a short task/topic.
2. Inspect only the files needed to understand the task: README, package manifests, relevant config, obvious entry points, existing `HandoffDocs/handoff.md` or `HandoffDocs/light/` listings if present, and targeted source files.
3. Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, historical artifacts, or compact-history reports unless the user explicitly asks or a currently active handoff links to a specific file needed for understanding.
4. Do not create or modify handoff files. If the user asks to save exploration results, explain that `/inithandoff --light` creates a project-local light note and `/inithandoff --full` creates full coordination.
5. Classify task shape:
   - `none`: casual Q&A, pure explanation, reading-only discovery, or a task unlikely to need continuity.
   - `light`: one focused task or small investigation that may benefit from a single continuation note.
   - `full`: multi-agent work, cross-session project state, artifacts, blockers, archive needs, multiple task slugs, or stale-context risk.

Output exactly these sections:

```markdown
## Exploration Result
- Topic:
- Checked:
- Key findings:
- Task shape:
- Handoff recommendation: none | light | full
- Suggested next action:
```

If recommending `light`, include a suggested kebab-case slug and say `/inithandoff --light <slug>` can create the note. If recommending `full`, say full should be created only after user confirmation with `/inithandoff --full <slug>`.
