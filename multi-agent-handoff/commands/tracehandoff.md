---
description: Explicitly synchronize requested progress into an existing handoff
argument-hint: "[--light | --full] [handoff-slug or update notes]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

Use the `multi-agent-handoff` skill.

## Required References

Read `references/write-safety.md` before updating any handoff.

For full handoffs, read `references/artifact-lifecycle.md` before recording artifacts, cleanup labels, or index changes. Read `references/task-specs.md` only when the selected handoff has a Task Binding.

## Explicit Sync Boundary

Run this workflow only when the user explicitly invokes `/tracehandoff` or clearly asks to synchronize, backfill, or record progress in an existing handoff.

Routine minimal maintenance after substantive work is not this command. Do not announce or recommend this command during routine maintenance.

Workflow:

1. Resolve the handoff and mode from explicit arguments, current context, and existing files. If ambiguous, ask which handoff to update.
2. Read the selected light file, or read the full index followed by the selected full execution handoff.
3. Append only requested facts:
   - What changed or was learned
   - Files touched or inspected
   - Verification run or skipped
   - Current blockers
   - Next recommended step
4. For light, update only `Progress` and `Next`.
5. For full:
   - Record handoff-owned artifacts under the execution slug.
   - Refresh Context Panel only when the execution reading boundary changed.
   - Preserve Task Binding and verify its paths if the update depends on them.
   - Do not edit task specs, external spec artifacts, or task readiness.
   - If execution reveals a spec change, record that need as a finding or blocker.
   - Update the owned index row only when operational status changed.
6. Treat legacy stored prompt fields as inert: do not read, refresh, copy, or delete them.
7. Do not rewrite the whole handoff unless malformed.

Report the synchronized facts, files updated, verification, and blockers. End after reporting.
