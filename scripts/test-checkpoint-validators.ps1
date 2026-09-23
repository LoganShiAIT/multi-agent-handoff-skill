param(
    [ValidateSet('Both', 'PowerShell', 'Bash')][string]$Validator = 'Both',
    [string]$Bash = 'bash'
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('handit-validators-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $scratch | Out-Null
foreach ($name in @('handit', 'examples', 'README.md')) {
    Copy-Item -LiteralPath (Join-Path $repo $name) -Destination $scratch -Recurse
}
$utf8 = [Text.UTF8Encoding]::new($false)
$cases = @(
    @{ Name = 'baseline'; Pass = $true },
    @{ Name = 'legacy advice allowed'; Pass = $true; Path = 'examples/legacy-next/input.md'; Add = "`n> **Next** Historical advice only.`n" },
    @{ Name = 'formal plan allowed'; Pass = $true; Path = 'examples/task-spec-internal/HandoffDocs/tasks/add-session-timeout/tasks.md'; Add = "`n## Next`n- Authorized formal work item.`n" },
    @{ Name = 'manual uncommitted sync allowed'; Pass = $true; Path = 'handit/commands/tracehandoff.md'; Add = "`nAn explicit save request may record uncommitted facts without a commit.`n" },
    @{ Name = 'full Next rejected'; Pass = $false; Path = 'handit/references/handoff-formats.md'; Old = '> **State** One sentence'; New = "> **Next** Invent work.`n> **State** One sentence" },
    @{ Name = 'light Next rejected'; Pass = $false; Path = 'handit/references/handoff-formats.md'; Old = '> **State** Where'; New = "> **Next** Invent work.`n> **State** Where" },
    @{ Name = 'index Next Action rejected'; Pass = $false; Path = 'handit/references/handoff-formats.md'; Old = '| Slug | Owner | Status | Updated |'; New = '| Slug | Owner | Status | Next Action | Updated |' },
    @{ Name = 'index Needed rejected'; Pass = $false; Path = 'examples/basic-handoff/HandoffDocs/handoff.md'; Add = "`n| Slug | Owner | Blocker | Needed |`n" },
    @{ Name = 'bound example Next rejected'; Pass = $false; Path = 'examples/task-spec-external/HandoffDocs/handoffs/add-profile-filters--w-01.md'; Add = "`n> **Next** Invent work.`n" },
    @{ Name = 'command return write rejected'; Pass = $false; Path = 'handit/commands/handoffprompt.md'; Add = "`nBefore returning, always update the handoff.`n" },
    @{ Name = 'full prompt return write rejected'; Pass = $false; Path = 'examples/handoffprompt-output.md'; Add = "`nBefore returning, always update the handoff.`n" },
    @{ Name = 'light prompt return write rejected'; Pass = $false; Path = 'examples/light-handoffprompt-output.md'; Add = "`nBefore returning, always update the handoff.`n" }
)
foreach ($case in $cases) {
    $original = $null
    try {
        if ($case.Path) {
            $target = Join-Path $scratch $case.Path
            $original = [IO.File]::ReadAllText($target)
            $changed = $original
            if ($case.ContainsKey('Old')) {
                if (-not $changed.Contains($case.Old)) { throw "Mutation target missing: $($case.Name)" }
                $changed = $changed.Replace($case.Old, $case.New)
            } else { $changed += $case.Add }
            [IO.File]::WriteAllText($target, $changed, $utf8)
        }
        foreach ($engine in @('PowerShell', 'Bash')) {
            if ($Validator -ne 'Both' -and $Validator -ne $engine) { continue }
            if ($engine -eq 'PowerShell') {
                $result = & (Join-Path $PSHOME 'pwsh') -NoProfile -File (Join-Path $PSScriptRoot 'validate-skill.ps1') -Root $scratch 2>&1
            } else {
                $result = & $Bash (Join-Path $PSScriptRoot 'validate-skill.sh').Replace('\', '/') $scratch.Replace('\', '/') 2>&1
            }
            $passed = $LASTEXITCODE -eq 0
            if ($passed -ne $case.Pass) { throw "$engine / $($case.Name): unexpected result`n$result" }
            if (-not $case.Pass -and ($result -join "`n") -notmatch 'Found forbidden') {
                throw "$engine / $($case.Name): failed for an unrelated reason`n$result"
            }
            Write-Output "PASS $engine / $($case.Name)"
        }
    } finally {
        if ($null -ne $original) { [IO.File]::WriteAllText($target, $original, $utf8) }
    }
}
Write-Output "Validated $($cases.Count) cases. Isolated fixture retained at $scratch"
