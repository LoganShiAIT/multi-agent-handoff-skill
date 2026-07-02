$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SkillDir = Join-Path $RepoRoot "multi-agent-handoff"
$SkillFile = Join-Path $SkillDir "SKILL.md"
$CommandsDir = Join-Path $SkillDir "commands"
$ReferencesDir = Join-Path $SkillDir "references"
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

Require-Path $SkillFile "SKILL.md"
Require-Path $CommandsDir "commands directory"
Require-Path $ReferencesDir "references directory"

if (Test-Path -LiteralPath $SkillFile) {
    $skillItem = Get-Item -LiteralPath $SkillFile
    $skillText = Get-Content -Raw -Encoding UTF8 $SkillFile

    Require-Contains $skillText '(?ms)^---\s*\r?\nname:\s*multi-agent-handoff\s*\r?\ndescription:\s*.+' "required SKILL.md frontmatter"
    Require-Contains $skillText '(?m)^## Lazy Command Routing$' "Lazy Command Routing"

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
        foreach ($commandFile in $commandFiles) {
            if ($declaredCommands -notcontains $commandFile.Name) {
                $Errors.Add("Command file is not routed from SKILL.md: $($commandFile.Name)")
            }
        }
    }
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
    "examples\explore-output.md",
    "examples\light-handoffprompt-output.md",
    "examples\compact-history\HandoffDocs\artifacts\api-auth-investigation\reports\20260702-101500-compact-history.md",
    "examples\handoffprompt-output.md"
)

foreach ($relativePath in $examplePaths) {
    Require-Path (Join-Path $RepoRoot $relativePath) "example $relativePath"
}

if ($Errors.Count -gt 0) {
    Write-Host "Skill validation failed:" -ForegroundColor Red
    foreach ($errorMessage in $Errors) {
        Write-Host " - $errorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Skill validation passed." -ForegroundColor Green
