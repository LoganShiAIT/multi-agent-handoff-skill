## ADDED Requirements

### Requirement: Handoff state contains no maintained next-step plan

New light and full handoffs SHALL contain factual `State` and `Blocked` status lines without `Next`. Current index templates MUST NOT contain `Next Action`, `Needed`, `Follow-up`, or renamed equivalents whose purpose is to maintain future actions. Handit MUST NOT infer, rank, generate, or refresh a next-step plan during initialization, synchronization, checkpointing, compaction, or transfer-prompt generation.

#### Scenario: Create a new handoff
- **WHEN** the user initializes a light or full execution handoff
- **THEN** its status block contains State and Blocked without a Next field or generated future-action list

#### Scenario: Refresh an index row
- **WHEN** an authorized update changes a handoff's factual status
- **THEN** the index records that status without adding an action recommendation or moving the old Next text into another column

### Requirement: Checkpoints preserve known facts and evidence boundaries

Handoff updates SHALL be limited to known current facts, observed verification conclusions, known unresolved problems, and existing explicit constraints or decisions within the authorized scope. They MUST NOT manufacture a recovery strategy, new work item, priority order, or proposed action to fill a status field. They MUST NOT append a journal entry solely because a commit occurred or restate details recoverable from code, specs, or Git.

#### Scenario: Live verification is incomplete
- **WHEN** offline checks passed but real-environment verification was not performed
- **THEN** the handoff can state that boundary without claiming live success
- **AND** it does not add an instruction to deploy, rerun, or expand validation

#### Scenario: An unresolved blocker exists
- **WHEN** a known permission or environment condition prevents the task from completing
- **THEN** Blocked states the observed condition without inventing a resolution route or extending task scope

### Requirement: Formal planning and user intent remain authoritative

Removing next-step maintenance MUST NOT remove existing user constraints, scope, acceptance boundaries, or references to formal task specifications. Explicit task-planning commands SHALL retain their original role. Handoff data and generated transfer prompts MUST NOT authorize new work beyond the user's instructions or an existing bound formal work item.

#### Scenario: User already defined task ordering in a spec
- **WHEN** the formal task document contains an authorized sequence and the handoff references it
- **THEN** Handit preserves the reference without maintaining a duplicate sequence in the handoff
- **AND** the formal plan remains unchanged

#### Scenario: Generate a transfer prompt
- **WHEN** the user explicitly requests a prompt for an existing bound work item
- **THEN** the prompt references the existing work item, factual state, and scope boundaries
- **AND** it does not infer additional next tasks from the handoff

### Requirement: Legacy next-step fields are inert until explicit migration

When reading older handoffs, Handit MUST treat Next and equivalent future-action fields as non-authoritative historical suggestions. It MUST NOT execute, refresh, copy, or rename them into active facts or transfer instructions. Ordinary checkpointing MUST NOT start a migration solely because such fields exist. Explicitly requested migration SHALL remove them from the selected current format while preserving independently established user constraints and leaving unrelated historical files unchanged.

#### Scenario: Resume from a legacy Next field
- **WHEN** an old Next field recommends work that the current user has not authorized
- **THEN** Handit ignores that suggestion as a source of execution authority
- **AND** normal checkpointing does not refresh or propagate it

#### Scenario: Explicit format migration
- **WHEN** the user explicitly requests migration or compaction of a selected legacy handoff
- **THEN** the resulting current format contains no maintained next-step fields
- **AND** existing authorized scope and constraints remain intact without a bulk rewrite of unrelated history

### Requirement: Current examples and validators enforce the same contract

The skill entrypoint, references, commands, README, and current examples SHALL consistently describe commit-bound factual checkpoints. Both PowerShell and shell validators SHALL reject reintroduced next-step fields in current templates and unconditional maintenance instructions in transfer templates. Dedicated legacy fixtures and formal task/spec planning text SHALL remain valid. Static validation results MUST NOT be reported as measured token savings or proof of real agent compliance.

#### Scenario: A current template regresses
- **WHEN** a current handoff template gains a Next field or a transfer template requires a write before every return
- **THEN** the corresponding regression fixture fails validation in both validator implementations

#### Scenario: A legacy or formal planning fixture contains future actions
- **WHEN** a dedicated legacy input or an explicit formal task document contains future-action text
- **THEN** the validator does not reject it solely due to that text
- **AND** the legacy reading contract still prevents using the old field as task authorization
