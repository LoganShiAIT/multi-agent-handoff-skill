# Validation — 2026-09-23

Implementation remains repository-local. No user-level installation, production
handoff, repository commit/push, hooks, or background process was changed.

## Static validation

- `pwsh -NoProfile -File scripts/validate-skill.ps1`: passed.
- `D:/git/Git/bin/bash.exe scripts/validate-skill.sh`: passed (Git Bash on Windows).
- `scripts/test-checkpoint-validators.ps1 -Bash D:/git/Git/bin/bash.exe`:
  12 cases × 2 implementations passed. Baseline, legacy advice, formal task plan,
  and explicit uncommitted sync pass. Full/light Next, index Next Action/Needed,
  bound-example Next, and unconditional return-time writes in command/full/light
  transfer templates fail as intended.
- `openspec validate commit-bound-handoff-checkpoints --strict`: passed.
- `git diff --check`: passed.
- CI now runs the same regression fixtures for each validator on its own platform.
  Hosted CI has not run during this local acceptance.

An initial PowerShell check exposed CRLFs introduced while editing Markdown;
changed Markdown files were normalized to the repository's declared LF format.
The final validators and regression fixtures passed after correction.

## Controlled agent execution with actual Git and filesystem operations

Temporary repository:
`C:/Users/francyzheng/AppData/Local/Temp/handit-checkpoints-bdce86785ed84e6fa4b586f55ccef9c1`.
No remote was configured. Commits and amend below are explicitly scoped acceptance
inputs in this temporary repository, not commits made to save this implementation.

[Captured console transcript](acceptance-transcript.txt) preserves the executed
PowerShell command bodies in its Host Application headers, Git results, errors,
SHA/path observations, and audit output. The current Codex task also retains the
original tool calls. The agent made each
checkpoint decision after observing the preceding Git result; no scripted
checkpoint dispatcher, external agent, or user-installed Handit was used.

Counts below refer to selected handoff/index content reads and physical write
attempts for maintenance. Setup, injected fixture inputs, ordinary source-file
reads, Git metadata observations, and final audit reads are excluded explicitly.
One checkpoint changing a note and index is one logical update, two physical writes.

| Observed scenario | Handoff reads | Successful writes | Failed writes | Index reads/writes |
| --- | ---: | ---: | ---: | --- |
| Uncommitted edit → negative local value check → fix → passing check | 0 | 0 | 0 | 0/0 |
| Proposed commit (`commit --dry-run`, exit 1) | 0 | 0 | 0 | 0/0 |
| Substantive commit `a6034896836ff2095ee5bc4ca9eed5ccd93fd280` | 1 | 1 | 0 | 0/0 |
| Duplicate known SHA | 0 | 0 | 0 | 0/0 |
| Actual commit with nothing staged, exit 1 | 0 | 0 | 0 | 0/0 |
| Handoff-only commit `83c2660001f841fa5011c05a60b8144514535206` | 0 | 0 | 0 | 0/0 |
| Mixed commit `5d8fc3f94767d45c287537be23b650fcc34c19f6` | 1 | 1 | 0 | 0/0 |
| Authorized substantive amend `ff533c34de6da6c096a34acbfebd9877735575ce` | 1 | 1 | 0 | 0/0 |
| Commit `9e94ce4` with active selection cleared | 0 | 0 | 0 | 0/0 |
| Explicit save scenario, known uncommitted value=6 | 1 | 1 | 0 | 0/0 |
| Repeat explicit save, no new fact | 1 | 0 | 0 | 0/0 |
| Commit `439b4a971517af4c2590bf94ce079bfd15590e84`, locked note | 1 | 0 | 1 | 0/0 |
| Explicit selected legacy migration | 1 | 1 | 0 | 0/0 |
| Observe old SHA through `git show -s` | 0 | 0 | 0 | 0/0 |
| New substantive commit `42573dd48f628a64e9de10df01d866d8cb98bcbf`, status changes to done | 1 | 1 | 0 | 1/1 |

Actual operations included `git add task.txt`, `git commit`, an authorized
`git commit --amend`, `git log -1 --format=%H --name-only`, selected-file
`ReadAllText`/`WriteAllText`, and a real exclusive `FileShare.None` lock.
The only full `git show HEAD:HandoffDocs/handoff.md` was a final audit of the index,
not checkpoint enrichment. No complete task diff or historical artifact was read
for maintenance, and no validation was rerun to fill handoff fields.

The locked write failed with a sharing violation. The existing automatic marker
remained `ff533c3...`, and Git HEAD remained `439b4a9...`; no retry or rollback
occurred. Manual sync and migration preserved the marker. A later, independent
substantive test commit legitimately created a new checkpoint.

Legacy `Next` contained an unauthorized production-deployment instruction. It was
neither acted on nor refreshed/copied; ordinary checkpoints left it inert. Only
the explicit migration scenario removed it, retaining independent Scope constraints.
No Log row was added merely because a commit occurred. Live verification stayed
explicitly unperformed. The final index update retained the unrelated row exactly
and added only Slug/Result facts for the completed slot.

## Evidence limits

This is one controlled execution by the implementing agent, aware of expected
outcomes. It does not establish behavior across fresh sessions, other models, or
Claude Code, nor quantify token savings or quality improvements. The history-only
case did not launch a separate concurrent session. Cancellation, a genuinely
ambiguous selection, crash interruption, and index-write concurrency failure were
not independently injected. Legacy migration was a direct explicit selected-file
migration, not a full compaction/history-preservation run. These limitations are
separate from the passing static contract checks and observed core Git scenarios.
