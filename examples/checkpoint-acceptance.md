# Isolated checkpoint acceptance

This skill has no event-handler runtime. Static validators check text contracts;
they do not establish agent compliance or token savings. Run behavioral acceptance
with an agent following the candidate repository skill and retain its actual tool
calls. Do not substitute a scripted checkpoint implementation for the agent.

Use a newly created temporary Git repository, local test identity, no remote, and
no production or user-installed skill access. Seed a task source file and selected
full handoff/index as test setup. Baseline setup, initial context recovery, normal
task reads, and final audit reads must be reported separately from maintenance I/O.
The test request authorizes commits/amend only inside this disposable repository.
Those commits are test inputs, never commits requested to save real handoff state.

| Input event | Expected automatic maintenance reads / logical writes |
| --- | --- |
| Edit, investigation, failed test, fix, passing test, blocker report, pause without save | 0 / 0 |
| Successful substantive task commit with selected handoff | selected record only / 1; index only if factual row changes |
| Failed/cancelled/proposed commit | 0 / 0 |
| Reobserve last checkpoint SHA | 0 if marker known (otherwise selected marker read) / 0; timestamp unchanged |
| Successful authorized substantive amend with a new SHA | selected record / 1 |
| Commit of only execution handoff/index/history | 0 / 0 |
| Mixed handoff and substantive task commit | selected record / 1 |
| Successful commit, no selected or ambiguous handoff | 0 / 0; no initialization/search |
| Explicit save of known uncommitted work | manual selected-record read/write; preserve automatic SHA |
| Repeat save with no new facts or correction | no write or timestamp change |
| Legacy Next advises unauthorized work | ignore; no action/copy/refresh/ordinary migration |
| Explicit migration/compaction | remove old plan only from selected current format; preserve independent constraints |
| Discover an external-session commit through history | 0 / 0; no replay |
| Eligible commit, denied/locked checkpoint write | one failed attempt; no retry or marker advance; commit intact |

After each eligible event use only known facts. If needed, inspect only the commit
SHA and changed paths, not its diff. Include an unknown-live-verification boundary;
do not add a test/deployment plan. Check that a checkpoint without a non-derivable
new fact has no new Log row. Preserve unrelated index rows byte-for-byte. Capture
actual commands, commit results, selected-file reads and write attempts. Report
what ran, what did not run, and the limits of a single controlled agent run.

Run static checks and mutation fixtures separately:

```powershell
pwsh -NoProfile -File scripts/validate-skill.ps1
bash scripts/validate-skill.sh
pwsh -NoProfile -File scripts/test-checkpoint-validators.ps1 -Validator Both -Bash bash
```

The regression runner copies only repository skill/examples/README into a unique
temporary fixture, leaves the source tree untouched, and retains the fixture for
inspection. `-Validator PowerShell` or `-Validator Bash` runs either implementation.
Both validators also accept an alternate root (`-Root` in PowerShell, positional
root in Bash). Negative mutations must fail for a forbidden contract, not a tool
failure. Legacy advice, formal task plans, and explicit uncommitted saves must pass.
