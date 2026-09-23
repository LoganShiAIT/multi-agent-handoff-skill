# Handoff Formats

Use these templates when creating or repairing handoff files. Task-spec templates live in `references/task-specs.md`. Record eviction rules live in `references/artifact-lifecycle.md`.

## Reading Order

A handoff has three layers, in this order:

1. **Status block** — two lines a person reads in ten seconds.
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
- [decision] YYYY-MM-DD One fact that changes what the next agent should do.
```

Nothing else belongs in a new handoff. Append a section from `Optional Sections` only when it has content.

### Status Block

The two status lines contain known facts only. Keep each to one sentence and refresh only at an eligible checkpoint or explicit authorized action. `Blocked` describes an observed obstacle, never a recovery strategy. `Blocked` is never omitted; write `none` when nothing blocks.

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

Every record opens with its kind:

```text
- [rejected] 2026-08-03 Count-based auto-compaction was rejected because count conflates volume with staleness.
```

The four kinds are the only things worth a slot:

- `failed` — an attempt that failed, and why it failed.
- `rejected` — an alternative that was rejected, and the reason.
- `blocker` — a blocker that is still open.
- `decision` — a decision that later work must not silently reverse.

Assign the kind when writing the record. It states what the record is, not how important it is, and it does not change afterwards. `Record Lifecycle` in `references/artifact-lifecycle.md` decides eviction from the kind alone, so an unlabelled record forces every later agent to re-derive the kind by interpreting the prose.

Do not write: commands executed, files inspected, files changed, or features implemented. All of those are recoverable from the repository, and restating them is how a handoff turns into a journal.

Use one line per record, dated to the day. During an authorized Log write, use known facts to evict records that have died — see `Record Lifecycle` in `references/artifact-lifecycle.md`.

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
> **Blocked** What is blocking, or `none`.

## Context
- Must read:
- Do not read:

## Log
- [decision] YYYY-MM-DD One fact that changes what the next agent should do.
```

If a light handoff needs artifacts, bindings, or history, it has outgrown light and should become a full handoff.

## Full Index Template

Generate index rows from handoff frontmatter rather than maintaining status in two places.

```markdown
# Handoff Index

## Active
| Slug | Owner | Status | Updated |
| --- | --- | --- | --- |

## Blocked
| Slug | Owner | Blocker |
| --- | --- | --- |

## Done
| Slug | Result |
| --- | --- |

## Archived
| Slug | Archived At | Reason | Replacement |
| --- | --- | --- | --- |
```

## Maintenance Boundary

Follow `SKILL.md` Automatic Checkpoint Boundary: only an observed successful substantive current-task commit with an already selected handoff triggers automatic maintenance. Failed commits and handoff-only commits do not. No selected handoff means no initialization or search. Execution progress and returning a response do not trigger reads or writes.

Optional frontmatter `checkpoint_commit` is the full SHA of the last successful automatic checkpoint. Omit it at initialization. Write it with the successful handoff update; never advance it on failure. Skip duplicate SHA without timestamp changes. An authorized substantive amend can checkpoint its new SHA once. Manual sync preserves the marker, including its absence; it does not claim uncommitted facts are committed. Do not force a Log row per commit.

Use only known facts and the selected record; commit metadata reads are limited to SHA and paths when eligibility is unknown. Update the full index only if the owned row's factual status changed. No extra investigation, tests, or historical scans for maintenance. Do not create, request, stage, amend, or push commits to save handoff changes.

Explicit sync may save uncommitted facts. No new facts or requested correction means no write, including no timestamp refresh. Preserve Scope, acceptance boundaries, and formal task references; never generate a plan, priority list, recovery route, or renamed next-action field.

Old `Next`, `Next Action`, `Needed`, `Follow-up`, and equivalents are non-authoritative historical advice. Do not act on, refresh, copy, or rename them. Ordinary checkpoints leave those fields inert without initiating migration. Explicit migration or compaction removes them from the selected current record/index while preserving independently established user constraints; unrelated history stays unchanged.

Treat stored transfer-prompt fields as inert historical content too. Do not refresh or use them in normal maintenance or remove them during an unrelated update. Explicit compaction handles legacy structure.
