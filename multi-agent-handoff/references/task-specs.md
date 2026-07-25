# Task Specs

Use these rules to separate task orchestration from execution handoff state.

## Contents

- Source Selection
- Directory Pattern
- Task Lifecycle
- Task Record Template
- Internal Task Files
- Execution Binding
- Ownership And Update Rules

## Source Selection

Choose exactly one specification owner:

1. Follow an explicit user choice or project instruction.
2. Otherwise inspect project-defined formal spec locations and conventions.
3. Otherwise detect known roots such as `openspec/` or `opsx/`.
4. If exactly one relevant external change or spec is identifiable, bind it.
5. If several external candidates are plausible, stop and ask which one owns the task.
6. If no external owner exists, use the internal task-spec structure.

Never copy external proposal, spec, design, or task content into `HandoffDocs/`. Store paths and identifiers only. Do not silently switch an external task to internal ownership when a bound path is missing; mark the binding blocked and ask for correction.

## Directory Pattern

Use one task directory for both internal and external sources:

```text
HandoffDocs/tasks/<task-slug>/
|-- task.md
|-- brief.md     # internal only
|-- spec.md      # internal only
|-- design.md    # internal only and only when needed
`-- tasks.md     # internal only
```

For an external source, create only `task.md`. Keep external formal artifacts in their owning workflow root.

Task specs belong to full coordination. Do not attach them to light handoffs.

## Task Lifecycle

Use only:

```text
draft | ready | in-progress | blocked | done
```

- `draft`: discussion, requirements, design, or work breakdown is incomplete.
- `ready`: the user has explicitly approved execution.
- `in-progress`: at least one execution handoff has started.
- `blocked`: orchestration cannot proceed without a decision or dependency.
- `done`: the user or coordinator has confirmed the task outcome is complete.

Require explicit user confirmation before changing `draft` to `ready`. Never infer approval from complete-looking documents.

Allow task-bound execution only from `ready` or `in-progress`. Do not create an execution handoff from `draft` or `blocked`.

## Task Record Template

Create `HandoffDocs/tasks/<task-slug>/task.md`:

```markdown
# <Task Title>

## Metadata
- Slug:
- Status: draft | ready | in-progress | blocked | done
- Created:
- Last Updated:

## Spec Source
- Owner: internal | external
- Workflow: internal | openspec | opsx | project-defined
- Root:
- Change / Spec ID:
- Required Files:
- Work Item Source:

## Execution Bindings
| Work Item | Handoff | Owner | Status |
| --- | --- | --- | --- |

## Coordination State
- Current focus:
- Open decisions:
- Blockers:
```

For internal ownership:

- Set `Root` to `HandoffDocs/tasks/<task-slug>/`.
- Set `Required Files` to `brief.md`, `spec.md`, and `tasks.md`, plus `design.md` only when it exists.
- Set `Work Item Source` to `HandoffDocs/tasks/<task-slug>/tasks.md`.

For external ownership:

- Record the external root and stable change/spec identifier.
- List only the files required to understand and execute the task.
- Point `Work Item Source` to the owning workflow's task artifact.
- Keep `Coordination State` operational; do not summarize or mirror external requirements.

## Internal Task Files

Create `brief.md`:

```markdown
# <Task Title> Brief

## Problem
-

## Goal
-

## Out Of Scope
-

## Context
-

## Open Questions
-
```

Create `spec.md`:

```markdown
# <Task Title> Specification

## Requirements
-

## Constraints
-

## Acceptance Criteria
-
```

Create `design.md` only when technical decisions need durable review:

```markdown
# <Task Title> Design

## Approach
-

## Key Decisions
-

## Risks
-

## Verification Strategy
-
```

Create `tasks.md`:

```markdown
# <Task Title> Work Items

## Work Items
| ID | Description | Depends On | Status | Acceptance Reference |
| --- | --- | --- | --- | --- |
| W-01 |  | none | pending |  |

## Execution Notes
-
```

Use work-item status `pending | in-progress | blocked | done`.

## Execution Binding

When creating a full handoff from a task, add:

```markdown
## Task Binding
- Task Record:
- Work Item:
- Spec Owner: internal | external
- Workflow:
- Required Context:
- Binding Status: current | blocked
```

Use `<task-slug>--<normalized-work-item-id>` as the execution handoff slug. Normalize the work-item ID to lowercase kebab-case, preserving its meaning.

Before creating the execution handoff:

- Read the task record.
- Require task status `ready` or `in-progress`.
- Require the work-item ID to exist in the work-item source.
- Verify every required context path exists.
- Stop on ambiguous or missing bindings.

After creation:

- Change task status from `ready` to `in-progress`.
- Add or update one `Execution Bindings` row.
- Keep task requirements, design, and work breakdown owned by the task-spec workflow.

## Ownership And Update Rules

- Let the coordinator or an explicit task-update action edit task records and internal task docs.
- Let execution agents edit only their own handoff and owned index row.
- Do not let routine handoff maintenance edit task specs.
- If execution discovers a spec change, record the need in the handoff and let the owning workflow apply it.
- Treat planned intent, current implementation, and execution state as different facts:
  - Formal task specs define intended behavior.
  - Current source and configuration define implemented behavior.
  - Active handoffs define execution progress.
- Do not move or archive task specs with execution-handoff archival.
- Mark task completion through an explicit task update. Leave task directories in place in this version.
