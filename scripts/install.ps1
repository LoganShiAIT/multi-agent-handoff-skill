param(
    [string]$CodexSkillsDir = $(if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME "skills" } else { Join-Path $HOME ".codex\skills" }),
    [string]$ClaudeCommandsDir = "",
    [ValidateSet("copy", "link")]
    [string]$Mode = "copy",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SkillSource = Join-Path $RepoRoot "multi-agent-handoff"
$CommandSource = Join-Path $SkillSource "commands"
$SkillTarget = Join-Path $CodexSkillsDir "multi-agent-handoff"

function Say($Message) {
    Write-Host "[multi-agent-handoff] $Message"
}

function Ensure-Dir($Path) {
    if ($DryRun) {
        Say "would create directory: $Path"
        return
    }
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Install-Path($Source, $Target, [bool]$Directory) {
    Ensure-Dir (Split-Path -Parent $Target)

    if ($DryRun) {
        Say "would install $Source -> $Target ($Mode)"
        return
    }

    if (Test-Path -LiteralPath $Target) {
        Remove-Item -LiteralPath $Target -Recurse -Force
    }

    if ($Mode -eq "link") {
        $itemType = if ($Directory) { "Junction" } else { "SymbolicLink" }
        New-Item -ItemType $itemType -Path $Target -Target $Source | Out-Null
    } elseif ($Directory) {
        Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force
    } else {
        Copy-Item -LiteralPath $Source -Destination $Target -Force
    }
}

if (!(Test-Path -LiteralPath $SkillSource)) {
    throw "Skill source not found: $SkillSource"
}

Install-Path $SkillSource $SkillTarget $true
if ($DryRun) {
    Say "would finish skill install to $SkillTarget"
} else {
    Say "installed skill to $SkillTarget"
}

if ($ClaudeCommandsDir) {
    Ensure-Dir $ClaudeCommandsDir
    Get-ChildItem -LiteralPath $CommandSource -Filter "*.md" | ForEach-Object {
        $target = Join-Path $ClaudeCommandsDir $_.Name
        Install-Path $_.FullName $target $false
    }
    if ($DryRun) {
        Say "would finish Claude command sync to $ClaudeCommandsDir"
    } else {
        Say "synced Claude commands to $ClaudeCommandsDir"
    }
} else {
    Say "skipped Claude command sync; pass -ClaudeCommandsDir .claude\commands to enable it"
}
