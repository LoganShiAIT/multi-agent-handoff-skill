---
description: Explicitly synchronize requested progress into an existing handoff
argument-hint: "[--light | --full] [handoff-slug or update notes]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read `references/write-safety.md` before updating any handoff.

Read `references/artifact-lifecycle.md` before appending to `Log`; it defines `Record Lifecycle`, which governs what may be written and what must be evicted. Read `references/task-specs.md` only when the selected handoff has a Task Binding.

## Explicit Sync Boundary

Run this workflow only when the user explicitly invokes `/tracehandoff` or clearly asks to synchronize, backfill, or record progress in an existing handoff.

Routine minimal maintenance after substantive work is not this command. Do not announce or recommend this command during routine maintenance.

Workflow:

1. Resolve the handoff and mode from explicit arguments, current context, and existing files. If ambiguous, ask which handoff to update.
2. Read the selected light file, or read the full index followed by the selected full execution handoff.
3. Append to `Log` only requested facts that cannot be derived from code, specs, or git:
   - What was decided, and what that decision rules out
   - What was attempted and failed, with the reason
   - Which alternative was rejected, with the reason
   - Which blockers are still open
   Do not append commands executed, files inspected, or work that already landed in the repository. Those are recoverable without the handoff.
4. Evict under `Record Lifecycle`: after appending, remove records the new ones superseded, landed, or resolved, and append them to `HandoffDocs/artifacts/<execution-slug>/history.md` with their eviction date and cause. Never evict failed attempts, rejected alternatives, or unresolved blockers.
5. If more than 10 live records remain after eviction, do not compact them. Report that the slot's scope is probably too large.
6. Refresh the status block and frontmatter `updated` in the same edit.
7. For light, update only the status block and `Log`.
8. For full:
   - Record handoff-owned artifacts under the execution slug.
   - Refresh `Context` only when the execution reading boundary changed.
   - Preserve Task Binding and verify its paths if the update depends on them.
   - Do not edit task specs, external spec artifacts, or task readiness.
   - If execution reveals a spec change, record that need as a `Log` record or blocker.
   - Update the owned index row only when operational status changed.
   - Add an optional section only when it now has content.
9. Treat legacy stored prompt fields as inert: do not read, refresh, copy, or delete them.
10. Do not rewrite the whole handoff unless malformed.

Report the synchronized facts, files updated, verification, and blockers. End after reporting.
