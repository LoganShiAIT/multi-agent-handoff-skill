# Handoff Formats

Use these templates when creating or repairing handoff files. Task-spec templates live in `references/task-specs.md`. Record eviction rules live in `references/artifact-lifecycle.md`.

## Reading Order

A handoff has three layers, in this order:

1. **Status block** — three lines a person reads in ten seconds.
2. **Contract** — `Scope` and `Context`. Stable; does not grow with progress.
3. **Records** — `Log`. Grows, and is evicted incrementally.

Machine fields live in frontmatter so the index can be generated from them instead of maintained by hand in two places.

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
        |-- history.md
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
- `artifacts/<execution-slug>/history.md` receives evicted log records.
- `archive/`, `study/`, and historical artifacts are not default operational context.
- Create a directory only when writing a file into it. Never pre-create empty artifact subdirectories.
- Never store a generated transfer prompt in a light or full handoff.

## Full Execution Handoff Template

Create one full handoff per execution slot:

```markdown
---
slug: <execution-slug>
status: planned | in-progress | blocked | done
owner: <agent or person>
updated: YYYY-MM-DD
branch: <branch or worktree>
task: <HandoffDocs/tasks/<task-slug>/task.md, or omit when unbound>
work_item: <work-item id, or omit when unbound>
---

# <Execution Title>

> **State** One sentence on where this slot actually is.
> **Next** One sentence on the next action.
> **Blocked** What is blocking, or `none`.

## Scope
- Goal:
- Out of scope:
- Done when:

## Context
- Must read:
- Optional:
- Do not read:

## Log
- YYYY-MM-DD One fact that changes what the next agent should do.
```

Nothing else belongs in a new handoff. Append a section from `Optional Sections` only when it has content.

### Status Block

The three status lines are the only part written for a human reader. Keep each to one sentence, and refresh them whenever the slot's real state changes. `Blocked` is never omitted; write `none` when nothing blocks.

### Scope

`Done when` is the acceptance boundary. When the slot is task-bound, point at the work item's acceptance reference instead of restating it.

### Context

This is the reading boundary that keeps the next agent out of unrelated context.

- `Must read` lists the few paths required to act, including the task record and required spec paths when bound.
- `Optional` names narrow expansion paths.
- `Do not read` excludes archive, study, unrelated handoffs, old artifacts, and broad source folders.

Do not record which files a previous agent read or which commands it ran. The next agent needs the reading boundary, not the previous agent's trail.

### Log

Record only facts that cannot be derived from code, specs, or git.

Write:

- An attempt that failed, and why it failed.
- An alternative that was rejected, and the reason.
- A blocker that is still open.
- A decision that later work must not silently reverse.

Do not write: commands executed, files inspected, files changed, or features implemented. All of those are recoverable from the repository, and restating them is how a handoff turns into a journal.

Use one line per record, dated to the day. On every write, evict records that have died — see `Record Lifecycle` in `references/artifact-lifecycle.md`.

## Optional Sections

Append any of these to a full handoff only when it has content. Never create one as an empty placeholder.

```markdown
## Task Binding
- Spec Owner: internal | external
- Workflow:
- Binding Status: current | blocked
```

Required spec paths belong in `Context` under `Must read`, not here. The task record and work item are already in frontmatter.

```markdown
## Artifacts
- <path>: <what it is>
```

```markdown
## Study Notes
| Path | Topic | Key Lesson | Created |
| --- | --- | --- | --- |
```

```markdown
## History
| Record | Covered | Created |
| --- | --- | --- |
```

`History` links to `artifacts/<execution-slug>/history.md` and to any compact-history reports.

```markdown
## Extra Files
| Path | Why It Exists | Decision Label | Cleanup Status |
| --- | --- | --- | --- |
```

`Extra Files` tracks non-source or temporary files created outside `artifacts/<execution-slug>/`.

## Light Handoff Template

Use a light handoff for one focused task that needs a small continuation note. It carries no task binding and no optional sections.

```markdown
---
slug: <task-slug>
status: in-progress | blocked | done
updated: YYYY-MM-DD
---

# <Task Title>

> **State** Where this actually is.
> **Next** The next action.
> **Blocked** What is blocking, or `none`.

## Context
- Must read:
- Do not read:

## Log
- YYYY-MM-DD One fact that changes what the next agent should do.
```

If a light handoff needs artifacts, bindings, or history, it has outgrown light and should become a full handoff.

## Full Index Template

Generate index rows from handoff frontmatter rather than maintaining status in two places.

```markdown
# Handoff Index

## Active
| Slug | Owner | Status | Next Action | Updated |
| --- | --- | --- | --- | --- |

## Blocked
| Slug | Owner | Blocker | Needed |
| --- | --- | --- | --- |

## Done
| Slug | Result | Follow-up |
| --- | --- | --- |

## Archived
| Slug | Archived At | Reason | Replacement |
| --- | --- | --- | --- |
```

## Maintenance Boundary

Update the active handoff concisely after meaningful implementation, investigation, failed attempts, validation, blockers, or changed next steps. Refresh the status block and frontmatter `updated` in the same edit. This routine maintenance is not a command invocation and must not produce command recommendations.

Treat any stored transfer-prompt field found in an older handoff as inert historical content. Do not refresh or use it during normal maintenance, and do not remove it during an unrelated update. `/compacthandoff` handles migrating legacy structure.
