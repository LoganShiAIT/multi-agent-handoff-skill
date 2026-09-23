---
description: Explicitly synchronize requested progress into an existing handoff
argument-hint: "[--light | --full] [handoff-slug or update notes]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `handit` skill.

## Required References

Read `references/write-safety.md` before updating any handoff.

Read `references/artifact-lifecycle.md` before appending to `Log`; it defines `Record Lifecycle`, which governs what may be written and what must be evicted. Read `references/task-specs.md` only when the selected handoff has a Task Binding.

## Explicit Sync Boundary

Run this workflow only when the user explicitly invokes `/tracehandoff` or clearly asks to synchronize, backfill, or record progress in an existing handoff.

Automatic maintenance is limited to the observed successful substantive task commit policy in `SKILL.md`. This explicit command may save uncommitted facts; preserve `checkpoint_commit` unchanged (or absent). No new facts or requested correction means no write, including no timestamp refresh. Do not announce or recommend this command during automatic maintenance. Neither path generates plans, recovery routes, or a journal row per commit; use known facts without extra investigation or validation for recordkeeping.

Workflow:

1. Resolve the handoff and mode from explicit arguments, current context, and existing files. If ambiguous, ask which handoff to update.
2. Read the selected light file, or read the full index followed by the selected full execution handoff.
3. Append to `Log` only requested facts that cannot be derived from code, specs, or git, writing each as `- [<kind>] YYYY-MM-DD <fact>`:
   - `decision` — what was decided, and what that decision rules out
   - `failed` — what was attempted and failed, with the reason
   - `rejected` — which alternative was rejected, with the reason
   - `blocker` — which blockers are still open
   Do not append commands executed, files inspected, or work that already landed in the repository. Those are recoverable without the handoff.
4. Using only known evidence during this authorized write, evict under `Record Lifecycle`: after appending, remove records the new ones superseded, landed, or resolved, and, for full handoffs only, append them to `HandoffDocs/artifacts/<execution-slug>/history.md` with their eviction date and cause. Decide from the kind, not the prose: only `decision` records can land, only `blocker` records can resolve, and `failed` or `rejected` records have no death cause. Never evict failed attempts, rejected alternatives, or unresolved blockers.
5. If more than 10 live records remain after eviction, do not compact them. Report that the slot's scope is probably too large.
6. Only when facts or a requested correction require a write, refresh factual `State`, `Blocked`, and frontmatter `updated` in the same edit. Never add next-action fields or rename old plans into facts.
7. For light, update only factual status, `updated`, and `Log`; do not create full history/artifact infrastructure. Retain records if eviction would require expanding beyond light mode, and report that boundary.
8. For full:
   - Record handoff-owned artifacts under the execution slug.
   - Refresh `Context` only when the execution reading boundary changed.
   - Preserve Task Binding and verify its paths if the update depends on them.
   - Do not edit task specs, external spec artifacts, or task readiness.
   - If execution reveals a spec change, record that need as a `Log` record or blocker.
   - Update the owned index row only when operational status changed.
   - Add an optional section only when it now has content.
9. Treat legacy Next/equivalent fields and stored prompts as inert: do not act on, refresh, copy, or rename them. This sync does not migrate them. Only explicit format migration/compaction removes old planning fields; preserve independently authorized constraints.
10. Do not rewrite the whole handoff unless malformed.

Report the synchronized facts, files updated, verification, and blockers. End after reporting.
