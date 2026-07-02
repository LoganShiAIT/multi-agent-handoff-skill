# Handoff Formats

Use these templates when creating or repairing handoff files.

## Directory Pattern

Light handoffs may use only `HandoffDocs/light/`. Full handoffs use the complete structure:

```text
HandoffDocs/
|-- light/
|   |-- <task-slug>.md
|   `-- ...
|-- handoff.md
|-- handoffs/
|   |-- <task-slug>.md
|   `-- ...
|-- archive/
|   `-- YYYY-MM/
|       `-- <task-slug>.md
|-- study/
|   `-- <study-scope>/
|       `-- YYYYMMDD-HHMMSS-short-title.html
`-- artifacts/
    `-- <task-slug>/
        |-- reports/
        |-- test-scripts/
        |-- test-results/
        `-- misc/
```

Rules:

- `light/<task-slug>.md` is a single-task continuation note. It does not require an index, artifacts, archive, study notes, compaction, or stale-artifact scanning.
- `handoff.md` is the full coordination index only. Keep each row to one line of operational signal.
- `handoffs/<task-slug>.md` holds full active or resumable task context. Use kebab-case slugs.
- `artifacts/<task-slug>/` holds full handoff process byproducts.
- `archive/`, `study/`, and historical artifacts are not default operational context. Do not read them during normal startup or continuation unless the user asks, the active handoff links to a specific file, or a command requires it.

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
- Handoff prompt:
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
```

## Full Task Handoff Template

Create one full task handoff per manually launched agent-level task. Include these sections unless a command says otherwise:

```markdown
# <Task Title>

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
- Prompt for the next agent:
```

Update the full task handoff before real work begins once the requirement is clear. Update it again after meaningful edits, investigation, failed attempts, validation, returned agent summaries, blockers, or changed next steps. Prefer short append-only entries over rewriting history.
