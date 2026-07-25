# Handoff Formats

Use these templates when creating or repairing handoff files. Task-spec templates live in `references/task-specs.md`.

## Directory Pattern

```text
HandoffDocs/
|-- tasks/
|   `-- <task-slug>/
|       `-- task.md
|-- light/
|   `-- <task-slug>.md
|-- handoff.md
|-- handoffs/
|   `-- <execution-slug>.md
|-- archive/
|   `-- YYYY-MM/
|       `-- <execution-slug>.md
|-- study/
|   `-- <study-scope>/
|       `-- YYYYMMDD-HHMMSS-short-title.html
`-- artifacts/
    `-- <execution-slug>/
        |-- reports/
        |-- test-scripts/
        |-- test-results/
        `-- misc/
```

Rules:

- `tasks/<task-slug>/` holds orchestration state or an external-spec binding.
- `light/<task-slug>.md` is an independent continuation note without task binding.
- `handoff.md` is the full execution index only.
- `handoffs/<execution-slug>.md` holds active or resumable execution context.
- `artifacts/<execution-slug>/` holds handoff-owned process byproducts.
- `archive/`, `study/`, and historical artifacts are not default operational context.
- Never store a generated transfer prompt in a light or full handoff.

## Light Handoff Template

```markdown
# <Task Title>

## Intent
- User request:
- Goal:
- Scope:

## Current Understanding
- Key facts:
- Files inspected:
- Commands run:

## Progress
-

## Next
- Recommended next step:
- Verification:
- Risks / blockers:
```

## Full Index Template

```markdown
# Handoff Index

## Active
| Slug | Owner | Status | Scope | Next Action | Updated |
| --- | --- | --- | --- | --- | --- |

## Blocked
| Slug | Owner | Blocker | Needed |
| --- | --- | --- | --- |

## Done
| Slug | Result | Follow-up |
| --- | --- | --- |

## Archived
| Slug | Archived At | Reason | Replacement |
| --- | --- | --- | --- |

## Compacted History
| Record | Covered Range | Summary | Created |
| --- | --- | --- | --- |
```

## Full Execution Handoff Template

Create one full handoff per execution slot:

```markdown
# <Execution Title>

## Metadata
- Slug:
- Owner / Agent:
- Status: planned | in-progress | blocked | done | archived
- Created:
- Last Updated:
- Branch / Worktree:
- Related Files:

## Mission
- Goal:
- Out of Scope:
- Success Criteria:

## Task Binding
- Task Record:
- Work Item:
- Spec Owner: internal | external
- Workflow:
- Required Context:
- Binding Status: current | blocked

## Context Panel
- Slot discusses:
- Required files to read:
- Optional files to read only if needed:
- Do not read by default:

## Context Packet
- User request:
- Relevant project facts:
- Commands already run:
- Files already inspected:

## Progress Log
-

## Findings and Decisions
-

## Artifacts
- Reports:
- Test scripts:
- Test results:
- Other byproducts:

## Study Notes
| Path | Topic | Key Lesson | Created |
| --- | --- | --- | --- |

## Compacted History
| Record | Covered Range | Summary | Created |
| --- | --- | --- | --- |

## Extra File Index
| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |

## Handoff Back
- Current state:
- Next recommended step:
- Risks / blockers:
```

For a task-bound handoff, complete `Task Binding` from `task.md` and the selected work item. For an unbound legacy or directly initialized full handoff, omit the section instead of inventing a task record.

Keep `Context Panel` short:

- `Slot discusses` states the owned execution topic.
- `Required files to read` includes the task record and required spec paths when bound.
- `Optional files to read only if needed` names narrow expansion paths.
- `Do not read by default` excludes archive, study, unrelated handoffs, old artifacts, and broad source folders.

## Maintenance Boundary

Update the active handoff concisely after meaningful implementation, investigation, failed attempts, validation, blockers, or changed next steps. This routine maintenance is not a command invocation and must not produce command recommendations.

Treat legacy `Handoff prompt` or `Prompt for the next agent` fields as inert historical content:

- Do not refresh or use them during normal maintenance.
- Do not remove them during unrelated updates.
- During explicit compaction, preserve their old contents only in the compact-history report and omit them from active context.
