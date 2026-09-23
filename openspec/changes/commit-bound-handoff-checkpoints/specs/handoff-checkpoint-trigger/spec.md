## ADDED Requirements

### Requirement: Automatic checkpoints follow observed task commits

Handit SHALL automatically update an existing, unambiguously selected task handoff only after the current agent observes an actual successful commit containing a substantive change for that task. It MUST NOT create or discover additional handoffs merely because a commit occurred. A successful authorized amend SHALL be treated as a commit with its resulting SHA.

#### Scenario: Successful task commit with an active handoff
- **WHEN** the current task has a selected handoff and its commit succeeds with a new SHA and substantive task changes
- **THEN** Handit performs one logical checkpoint update for that handoff and records the resulting commit SHA
- **AND** a full index is edited only when the selected row's factual status changed

#### Scenario: Commit fails or is cancelled
- **WHEN** a commit fails validation, is cancelled, or is only proposed
- **THEN** Handit performs no automatic checkpoint read or write

#### Scenario: No selected handoff
- **WHEN** a task commit succeeds but no handoff is selected or its identity is ambiguous
- **THEN** Handit skips automatic maintenance without creating state or searching unrelated handoffs

### Requirement: Execution events do not trigger maintenance

Handit MUST NOT automatically inspect, refresh, append to, classify, or compact handoff state in response to implementation progress, investigation, failed attempts, verification, blockers, changed plans, elapsed time, token usage, or ending a response. Initial context recovery and ordinary task work SHALL remain distinct from maintenance.

#### Scenario: Multiple execution steps without a commit
- **WHEN** an agent edits code, investigates a failure, retries, and runs tests without a successful task commit or explicit sync request
- **THEN** automatic handoff-maintenance reads and writes remain zero across those steps
- **AND** the agent does not schedule intermediate record-importance or eviction reviews

#### Scenario: Pause without a save request
- **WHEN** the user says to pause or the agent reports a blocker without explicitly requesting or being asked to save handoff state
- **THEN** that event alone does not trigger automatic handoff maintenance

### Requirement: Explicit handoff actions remain available

Handit SHALL accept `/tracehandoff` and explicit natural-language requests to synchronize or save handoff state without requiring a commit. It SHALL retain writes authorized by explicit initialization, compaction, archive, and study commands without treating command completion as another checkpoint trigger. A sync with no new facts or requested corrections MUST NOT rewrite timestamps solely to show activity.

#### Scenario: Explicit sync of uncommitted work
- **WHEN** the user explicitly requests saving known progress that has not been committed
- **THEN** Handit updates only the requested handoff with the known facts and their uncommitted or unverified status
- **AND** it neither creates a commit nor represents those facts as covered by a commit

#### Scenario: Repeated sync without changes
- **WHEN** the user requests sync and the selected record already contains all requested facts without needed correction
- **THEN** Handit reports no update is needed and leaves the files unchanged

### Requirement: Checkpoint writes are idempotent and cannot create a commit loop

Handit SHALL store the last successful automatic checkpoint SHA in optional `checkpoint_commit` frontmatter. Reobserving that SHA MUST NOT cause another automatic write. Commits containing only handoff-maintenance changes MUST NOT trigger checkpoints. Handit MUST NOT create, request, split, stage, amend, or push commits for the purpose of checkpoint maintenance.

#### Scenario: Duplicate observation of the same commit
- **WHEN** the observed SHA matches the selected handoff's `checkpoint_commit`
- **THEN** Handit performs no repeated write or timestamp refresh

#### Scenario: Handoff-only maintenance commit
- **WHEN** a commit changes only handoff state, index, or handoff-maintenance artifacts
- **THEN** Handit does not generate another automatic checkpoint or additional commit

#### Scenario: Mixed commit or amended substantive change
- **WHEN** a new successful commit or authorized amend includes substantive current-task deliverables as well as handoff files
- **THEN** Handit can checkpoint the resulting SHA once
- **AND** the checkpoint write does not cause a follow-up commit or amend

### Requirement: Maintenance has a bounded evidence scope

An automatic checkpoint SHALL use known conversation facts and the selected handoff, with a minimal selected-row index edit if necessary. It MAY read only the observed commit's SHA and changed paths when needed to establish eligibility. It MUST NOT inspect complete diffs to reconstruct a journal, scan historical artifacts, re-run validation, or investigate the project solely to enrich or evict handoff records. Unknown facts MUST remain explicitly unverified.

#### Scenario: Verification result is unknown at commit time
- **WHEN** the task commit succeeds but no live verification result is known
- **THEN** the checkpoint records the known verification boundary if relevant
- **AND** it does not run tests or inspect extra evidence solely to complete the handoff

#### Scenario: No additional log fact exists
- **WHEN** a qualifying commit has no new non-derivable fact beyond its checkpoint association
- **THEN** Handit does not invent a Log entry or repeat the commit's implementation details

### Requirement: Prompt generation does not bypass the trigger policy

Generated transfer prompts and command/reference templates MUST apply the same checkpoint policy to receiving agents. They MUST NOT require unconditional maintenance before returning, after every meaningful action, or after reporting a blocker. `/handoffprompt` SHALL remain read-only with respect to handoff state.

#### Scenario: Receiver returns without committing
- **WHEN** an agent follows a generated transfer prompt and returns findings without a successful task commit or explicit sync request
- **THEN** the prompt does not require any handoff write

### Requirement: Checkpoint observation has explicit operational limits

Handit MUST NOT install hooks, run background watchers, poll Git, or backfill external-session commits automatically. A failed handoff write SHALL be reported as a failed checkpoint without undoing the successful commit, falsely advancing `checkpoint_commit`, or entering an automatic retry loop. Manual sync SHALL preserve the last automatic checkpoint association rather than inventing one.

#### Scenario: Another session commits
- **WHEN** a commit is discovered through history or was made outside the current execution context
- **THEN** Handit does not automatically replay maintenance for it
- **AND** the user can explicitly request synchronization if needed

#### Scenario: Post-commit write fails
- **WHEN** the task commit succeeds but saving the handoff fails
- **THEN** the agent reports the two outcomes separately and leaves the Git commit intact
- **AND** it does not claim the checkpoint succeeded or loop on retries
