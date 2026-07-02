---
description: Create or select a light or full project handoff after exploration
argument-hint: "[--light | --full] [task/topic description]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

## Required References

Read these before creating or selecting a handoff:

- `references/write-safety.md`
- `references/handoff-formats.md`

Initialize or select a handoff context after the work is understood. Prefer `/explorehandoff` first when task shape is unclear.

Modes:

- `--light`: Create or select a single-file continuation note under `HandoffDocs/light/`.
- `--full`: Create or select full project coordination using index, full task handoff, and optional artifacts.
- No explicit mode: default to `--light` unless the user explicitly asks for full coordination.

Light structure:

```text
HandoffDocs/
└── light/
    └── <task-slug>.md
```

Full structure:

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
2. Resolve mode from `$ARGUMENTS` and user intent. If full is not explicit, use light. If the task is clearly full-weight but the user did not request full, ask before creating full.
3. Inspect the project briefly: README, package manifests, config files, and major source directories. Avoid broad historical handoff reads.
4. For light:
   - Follow `references/write-safety.md`.
   - Create `HandoffDocs/light/` if missing.
   - Create or select `HandoffDocs/light/<task-slug>.md`.
   - Use the light template from `references/handoff-formats.md`. Include user request, goal, scope, key facts, inspected files, commands run, current progress, recommended next step, verification, and handoff prompt.
   - Do not create or update `HandoffDocs/handoff.md`, `handoffs/`, `artifacts/`, `archive/`, or `study/`.
5. For full:
   - Follow `references/write-safety.md` and `references/handoff-formats.md`.
   - If `HandoffDocs/handoff.md` does not exist, create the full index and full task handoff from the user's request or `$ARGUMENTS`.
   - If `HandoffDocs/handoff.md` exists, read it first. If the user or `$ARGUMENTS` names a task, read that full task handoff. If multiple active tasks exist and no task is clear, list them and ask which to continue or whether to create a new one.
   - Determine whether handoffs are private/local or shared/team.
   - For private/local handoffs in a git repository, ask for and receive explicit user confirmation before changing git metadata; after confirmation, prefer adding `HandoffDocs/` to `.git/info/exclude`.
   - Do not modify `.gitignore` unless the user confirms the ignore rule should be shared by the repo.
   - Do not read `HandoffDocs/archive/`, `HandoffDocs/study/`, or historical artifacts unless the user or selected active handoff explicitly points to a specific file.
6. Before starting implementation work, update the chosen light or full handoff with the current mission, status, and next step.

End by reporting the selected mode, slug, path, and immediate focus. Suggest `/tracehandoff <slug>` after changes or `/handoffprompt <slug>` before launching another agent, plus a natural-language alternative.
