---
description: Initialize or select the project handoff topic
argument-hint: "[task/topic description]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

Initialize or select the handoff context for this project using the default structure:

```text
HandoffDocs/
├── handoff.md
├── handoffs/
│   └── <task-slug>.md
├── archive/
├── study/
└── artifacts/
```

Workflow:

1. Confirm this is a concrete project task that needs continuity. Do not create handoff for casual chat, one-off Q&A, pure explanation, or early brainstorming without an actionable task.
2. Inspect the project briefly: README, package manifests, config files, and major source directories.
3. If `HandoffDocs/handoff.md` does not exist:
   - Follow the skill's Filesystem Operations Checklist.
   - Create `handoff.md` as the index.
   - Create the first task handoff from the user's request or `$ARGUMENTS`.
   - Initialize the task handoff with an `OpenSpec Workflow State` section. Use `Spec Root: openspec/` by default, set `Status: not-needed` when the task clearly does not require OpenSpec, and set `Status: initialized` when the task may need a future OpenSpec change/spec.
   - Determine whether handoffs are private/local or shared/team.
   - For private/local handoffs in a git repository, ask for and receive explicit user confirmation before changing git metadata; after confirmation, prefer adding `HandoffDocs/` to `.git/info/exclude`.
   - Do not modify `.gitignore` unless the user confirms the ignore rule should be shared by the repo.
4. If `HandoffDocs/handoff.md` exists:
   - Read it first.
   - If the user or `$ARGUMENTS` names a task, read that task handoff.
   - If multiple active tasks exist and no task is clear, list them and ask which to continue or whether to create a new one.
   - Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or historical artifacts unless the user or selected active handoff explicitly points to a specific file.
5. Before starting implementation work, update the chosen task handoff with the current mission, status, and next step.
6. Keep OpenSpec-owned files in `openspec/`. Reference selected OpenSpec changes/specs from the task handoff, but do not move those artifacts into `HandoffDocs/`.

End by reporting the selected slug and the immediate focus. Include one next-step hint, such as `/tracehandoff` after changes or `/handoffprompt <slug>` before launching another agent, plus a natural-language alternative.
