$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SkillDir = Join-Path $RepoRoot "multi-agent-handoff"
$SkillFile = Join-Path $SkillDir "SKILL.md"
$CommandsDir = Join-Path $SkillDir "commands"
$ExamplesDir = Join-Path $RepoRoot "examples"
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

if (Test-Path -LiteralPath $SkillFile) {
    $skillText = Get-Content -Raw -Encoding UTF8 $SkillFile
    Require-Contains $skillText '(?ms)^---\s*\r?\nname:\s*multi-agent-handoff\s*\r?\ndescription:\s*.+' "required SKILL.md frontmatter"
    Require-Contains $skillText '(?m)^## Explore-First Policy$' "Explore-First Policy"
    Require-Contains $skillText '(?m)^## Light Vs Full Handoff$' "Light Vs Full Handoff"
    Require-Contains $skillText '(?m)^## Filesystem Operations Checklist$' "Filesystem Operations Checklist"

    $declared = [regex]::Matches($skillText, 'Read `commands/([^`]+\.md)`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    foreach ($command in $declared) {
        Require-Path (Join-Path $CommandsDir $command) "declared command $command"
    }
}

$initCommand = Join-Path $CommandsDir "inithandoff.md"
Require-Path $initCommand "inithandoff command"
if (Test-Path -LiteralPath $initCommand) {
    $initText = Get-Content -Raw -Encoding UTF8 $initCommand
    Require-Contains $initText "Filesystem Operations Checklist" "inithandoff checklist reference"
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
