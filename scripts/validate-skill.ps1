$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SkillDir = Join-Path $RepoRoot "multi-agent-handoff"
$SkillFile = Join-Path $SkillDir "SKILL.md"
$AgentFile = Join-Path $SkillDir "agents\openai.yaml"
$CommandsDir = Join-Path $SkillDir "commands"
$ReferencesDir = Join-Path $SkillDir "references"
$ReadmeFile = Join-Path $RepoRoot "README.md"
$Errors = New-Object System.Collections.Generic.List[string]

function Require-Path($Path, $Label) {
    if (!(Test-Path -LiteralPath $Path)) {
        $Errors.Add("Missing $Label`: $Path")
    }
}

function Require-Contains($Text, $Pattern, $Label) {
    if ($Text -notmatch $Pattern) {
        $Errors.Add("Missing $Label")
    }
}

function Require-NotContains($Text, $Pattern, $Label) {
    if ($Text -match $Pattern) {
        $Errors.Add("Found forbidden $Label")
    }
}

Require-Path $SkillFile "SKILL.md"
Require-Path $AgentFile "agents/openai.yaml"
Require-Path $CommandsDir "commands directory"
Require-Path $ReferencesDir "references directory"
Require-Path (Join-Path $CommandsDir "inittask.md") "inittask command"
Require-Path (Join-Path $CommandsDir "updatetask.md") "updatetask command"
Require-Path (Join-Path $ReferencesDir "task-specs.md") "task spec reference"

if (Test-Path -LiteralPath $SkillFile) {
    $skillItem = Get-Item -LiteralPath $SkillFile
    $skillText = Get-Content -Raw -Encoding UTF8 $SkillFile

    Require-Contains $skillText '(?ms)^---\s*\r?\nname:\s*multi-agent-handoff\s*\r?\ndescription:\s*.+' "required SKILL.md frontmatter"
    Require-Contains $skillText '(?m)^## Lazy Command Routing$' "Lazy Command Routing"
    Require-Contains $skillText 'routine minimal handoff maintenance separate from command routing' "routine maintenance boundary"
    Require-NotContains $skillText '(?i)After a handoff-related action.*suggest' "global post-command suggestion rule"

    if ($skillItem.Length -gt 8192) {
        $Errors.Add("SKILL.md is too large: $($skillItem.Length) bytes > 8192 bytes")
    }

    $declaredCommands = [regex]::Matches($skillText, 'Read `commands/([^`]+\.md)`') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique

    foreach ($command in $declaredCommands) {
        Require-Path (Join-Path $CommandsDir $command) "declared command $command"
    }

    if (Test-Path -LiteralPath $CommandsDir) {
        $commandFiles = Get-ChildItem -LiteralPath $CommandsDir -Filter "*.md" -File
        $transitionCommandPattern = 'explorehandoff|inittask|updatetask|inithandoff|tracehandoff|compacthandoff|handoffprompt|archivehandoff|study'
        foreach ($commandFile in $commandFiles) {
            if ($declaredCommands -notcontains $commandFile.Name) {
                $Errors.Add("Command file is not routed from SKILL.md: $($commandFile.Name)")
            }

            $commandText = Get-Content -Raw -Encoding UTF8 $commandFile.FullName
            if ($commandFile.Name -ne "handoffprompt.md") {
                Require-NotContains $commandText '(?i)(^|[^\p{L}\p{N}_])/handoffprompt([^\p{L}\p{N}_-]|$)' "$($commandFile.Name) handoffprompt reference"
            }
            if ($commandFile.Name -ne "explorehandoff.md") {
                Require-NotContains $commandText '(?i)(suggest|next-step hint|next useful command|natural-language alternative)' "$($commandFile.Name) optional command suggestion"
            }

            $sourceCommand = [System.IO.Path]::GetFileNameWithoutExtension($commandFile.Name)
            foreach ($transitionLine in $commandText -split "\r?\n") {
                if ($transitionLine -notmatch '(?i)(suggest|recommend|next[- ]?(step|command|action)|then\s+(run|use)|follow[- ]?up)') {
                    continue
                }
                if ($transitionLine -match '(?i)(do not|never)[^.]*(suggest|recommend)') {
                    continue
                }
                foreach ($targetMatch in [regex]::Matches($transitionLine, "/($transitionCommandPattern)")) {
                    $targetCommand = $targetMatch.Groups[1].Value
                    if ($sourceCommand -ne "explorehandoff" -or
                        ($targetCommand -ne "inittask" -and $targetCommand -ne "inithandoff")) {
                        $Errors.Add("Forbidden or cyclic command transition: $sourceCommand -> $targetCommand")
                    }
                }
            }
        }
    }
}

if (Test-Path -LiteralPath $ReadmeFile) {
    $readmeText = Get-Content -Raw -Encoding UTF8 $ReadmeFile
    Require-Contains $readmeText '/inittask' "README inittask command"
    Require-Contains $readmeText '/updatetask' "README updatetask command"
    Require-Contains $readmeText 'external-first|外部规范优先' "README external-first policy"
}

if (Test-Path -LiteralPath $AgentFile) {
    $agentText = Get-Content -Raw -Encoding UTF8 $AgentFile
    Require-NotContains $agentText '(?i)default_prompt:.*(next agent|next session|handoff prompt|transfer prompt)' "prompt-oriented default UI prompt"
}

if (Test-Path -LiteralPath $CommandsDir) {
    foreach ($commandFile in Get-ChildItem -LiteralPath $CommandsDir -Filter "*.md" -File) {
        $commandText = Get-Content -Raw -Encoding UTF8 $commandFile.FullName
        Require-Contains $commandText '(?m)^## Required References$' "$($commandFile.Name) Required References section"
    }
}

$textsToScan = @()
if (Test-Path -LiteralPath $SkillFile) {
    $textsToScan += Get-Content -Raw -Encoding UTF8 $SkillFile
}
if (Test-Path -LiteralPath $CommandsDir) {
    foreach ($commandFile in Get-ChildItem -LiteralPath $CommandsDir -Filter "*.md" -File) {
        $textsToScan += Get-Content -Raw -Encoding UTF8 $commandFile.FullName
    }
}

$declaredReferences = $textsToScan |
    ForEach-Object { [regex]::Matches($_, '`references/([^`]+\.md)`') } |
    ForEach-Object { $_ } |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

foreach ($reference in $declaredReferences) {
    Require-Path (Join-Path $ReferencesDir $reference) "declared reference $reference"
}

$examplePaths = @(
    "examples\basic-handoff\HandoffDocs\handoff.md",
    "examples\basic-handoff\HandoffDocs\handoffs\api-auth-investigation.md",
    "examples\light-handoff\HandoffDocs\light\api-auth-investigation.md",
    "examples\task-spec-internal\HandoffDocs\tasks\add-session-timeout\task.md",
    "examples\task-spec-internal\HandoffDocs\tasks\add-session-timeout\brief.md",
    "examples\task-spec-internal\HandoffDocs\tasks\add-session-timeout\spec.md",
    "examples\task-spec-internal\HandoffDocs\tasks\add-session-timeout\tasks.md",
    "examples\task-spec-external\HandoffDocs\handoff.md",
    "examples\task-spec-external\HandoffDocs\tasks\add-profile-filters\task.md",
    "examples\task-spec-external\HandoffDocs\handoffs\add-profile-filters--w-01.md",
    "examples\task-spec-external\openspec\changes\add-profile-filters\proposal.md",
    "examples\task-spec-external\openspec\changes\add-profile-filters\specs\profile\spec.md",
    "examples\task-spec-external\openspec\changes\add-profile-filters\tasks.md",
    "examples\explore-output.md",
    "examples\light-handoffprompt-output.md",
    "examples\compact-history\HandoffDocs\artifacts\api-auth-investigation\reports\20260702-101500-compact-history.md",
    "examples\handoffprompt-output.md"
)

foreach ($relativePath in $examplePaths) {
    Require-Path (Join-Path $RepoRoot $relativePath) "example $relativePath"
}

$handoffFormatsPath = Join-Path $ReferencesDir "handoff-formats.md"
if (Test-Path -LiteralPath $handoffFormatsPath) {
    $handoffFormatsText = Get-Content -Raw -Encoding UTF8 $handoffFormatsPath
    Require-NotContains $handoffFormatsText '(?im)^\s*-\s*(Handoff prompt|Prompt for the next agent):' "persistent prompt field in handoff formats"
    Require-Contains $handoffFormatsText '(?m)^## Task Binding$' "Task Binding template section"
}

$normalHandoffs = @(
    (Join-Path $RepoRoot "examples\basic-handoff\HandoffDocs\handoffs\api-auth-investigation.md"),
    (Join-Path $RepoRoot "examples\light-handoff\HandoffDocs\light\api-auth-investigation.md")
)
foreach ($normalHandoff in $normalHandoffs) {
    if (Test-Path -LiteralPath $normalHandoff) {
        $normalHandoffText = Get-Content -Raw -Encoding UTF8 $normalHandoff
        Require-NotContains $normalHandoffText '(?im)^\s*-\s*(Handoff prompt|Prompt for the next agent):' "persistent prompt field in $(Split-Path -Leaf $normalHandoff)"
    }
}

$exampleHandoffFiles = Get-ChildItem -Path (Join-Path $RepoRoot "examples") -Recurse -Filter "*.md" -File |
    Where-Object { $_.FullName -match '[\\/]HandoffDocs[\\/]' }
foreach ($exampleHandoffFile in $exampleHandoffFiles) {
    $exampleHandoffText = Get-Content -Raw -Encoding UTF8 $exampleHandoffFile.FullName
    Require-NotContains $exampleHandoffText '(?im)^\s*-\s*(Handoff prompt|Prompt for the next agent):' "persistent prompt field in HandoffDocs examples"
}

$handoffPromptPath = Join-Path $CommandsDir "handoffprompt.md"
if (Test-Path -LiteralPath $handoffPromptPath) {
    $handoffPromptText = Get-Content -Raw -Encoding UTF8 $handoffPromptPath
    Require-Contains $handoffPromptText '(?m)^## Manual Trigger Gate$' "handoffprompt manual trigger gate"
    Require-Contains $handoffPromptText 'Do not create, save, cache, maintain' "handoffprompt non-persistence rule"
    Require-Contains $handoffPromptText 'Do not copy proposal, spec, design, or work-item prose' "handoffprompt path-only task binding"
    Require-NotContains $handoffPromptText '(?i)(^|[^\p{L}\p{N}_])/tracehandoff([^\p{L}\p{N}_-]|$)' "handoffprompt to tracehandoff edge"
}

$traceHandoffPath = Join-Path $CommandsDir "tracehandoff.md"
if (Test-Path -LiteralPath $traceHandoffPath) {
    $traceHandoffText = Get-Content -Raw -Encoding UTF8 $traceHandoffPath
    Require-Contains $traceHandoffText '(?m)^## Explicit Sync Boundary$' "tracehandoff explicit sync boundary"
    Require-Contains $traceHandoffText 'Do not edit task specs, external spec artifacts, or task readiness' "tracehandoff task-spec isolation"
}

$initHandoffPath = Join-Path $CommandsDir "inithandoff.md"
if (Test-Path -LiteralPath $initHandoffPath) {
    $initHandoffText = Get-Content -Raw -Encoding UTF8 $initHandoffPath
    Require-Contains $initHandoffText '--from-task' "inithandoff task binding mode"
    Require-Contains $initHandoffText 'Require task status `ready` or `in-progress`' "inithandoff ready gate"
}

$compactHandoffPath = Join-Path $CommandsDir "compacthandoff.md"
if (Test-Path -LiteralPath $compactHandoffPath) {
    $compactHandoffText = Get-Content -Raw -Encoding UTF8 $compactHandoffPath
    Require-Contains $compactHandoffText 'Preserve complete .*`Task Binding`' "compaction Task Binding preservation"
}

$archiveHandoffPath = Join-Path $CommandsDir "archivehandoff.md"
if (Test-Path -LiteralPath $archiveHandoffPath) {
    $archiveHandoffText = Get-Content -Raw -Encoding UTF8 $archiveHandoffPath
    Require-Contains $archiveHandoffText 'Do not move the task directory' "archive task-spec independence"
}

$taskSpecsPath = Join-Path $ReferencesDir "task-specs.md"
if (Test-Path -LiteralPath $taskSpecsPath) {
    $taskSpecsText = Get-Content -Raw -Encoding UTF8 $taskSpecsPath
    Require-Contains $taskSpecsText '(?m)^## Source Selection$' "task spec source selection"
    Require-Contains $taskSpecsText '(?m)^## Task Record Template$' "task record template"
    Require-Contains $taskSpecsText 'draft\s*\|\s*ready\s*\|\s*in-progress\s*\|\s*blocked\s*\|\s*done' "task status lifecycle"
    Require-Contains $taskSpecsText 'explicit user confirmation' "explicit ready gate"
    Require-Contains $taskSpecsText 'If several external candidates are plausible, stop' "ambiguous external source stop rule"
    Require-Contains $taskSpecsText 'Allow task-bound execution only from `ready` or `in-progress`' "task-bound execution status gate"
}

$externalTaskDir = Join-Path $RepoRoot "examples\task-spec-external\HandoffDocs\tasks\add-profile-filters"
foreach ($forbiddenExternalCopy in @("brief.md", "spec.md", "design.md", "tasks.md")) {
    $forbiddenPath = Join-Path $externalTaskDir $forbiddenExternalCopy
    if (Test-Path -LiteralPath $forbiddenPath) {
        $Errors.Add("External task example duplicates spec content: $forbiddenPath")
    }
}

$externalHandoffPath = Join-Path $RepoRoot "examples\task-spec-external\HandoffDocs\handoffs\add-profile-filters--w-01.md"
if (Test-Path -LiteralPath $externalHandoffPath) {
    $externalHandoffText = Get-Content -Raw -Encoding UTF8 $externalHandoffPath
    Require-Contains $externalHandoffText '(?m)^## Task Binding$' "external example Task Binding"
}

$externalTaskRecordPath = Join-Path $externalTaskDir "task.md"
if (Test-Path -LiteralPath $externalTaskRecordPath) {
    $externalTaskRecordText = Get-Content -Raw -Encoding UTF8 $externalTaskRecordPath
    Require-Contains $externalTaskRecordText '(?m)^\s*-\s*Owner:\s*external\s*$' "external example owner"
}

if ($Errors.Count -gt 0) {
    Write-Host "Skill validation failed:" -ForegroundColor Red
    foreach ($errorMessage in $Errors) {
        Write-Host " - $errorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Skill validation passed." -ForegroundColor Green
