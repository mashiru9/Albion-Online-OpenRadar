[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent $PSScriptRoot
$results = [Collections.Generic.List[object]]::new()
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machinePath;$userPath"

function Invoke-TestStep {
    param([string] $Name, [string] $Command, [string[]] $Arguments)
    Write-Host ''
    Write-Host "=== $Name ==="
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $resolved = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $resolved) {
        $watch.Stop()
        $results.Add([pscustomobject]@{ Step = $Name; ExitCode = 127; Duration = $watch.Elapsed; Status = 'FAIL' })
        Write-Error "Command not found: $Command"
        return
    }
    & $resolved.Source @Arguments
    $code = $LASTEXITCODE
    $watch.Stop()
    $results.Add([pscustomobject]@{
        Step = $Name
        ExitCode = $code
        Duration = $watch.Elapsed
        Status = if ($code -eq 0) { 'PASS' } else { 'FAIL' }
    })
}

Push-Location $repoRoot
try {
    Invoke-TestStep 'go test ./...' 'go.exe' @('test', './...')
    Invoke-TestStep 'npm test' 'npm.cmd' @('test')
    Invoke-TestStep 'npm run typecheck' 'npm.cmd' @('run', 'typecheck')
    Invoke-TestStep 'npm run lint' 'npm.cmd' @('run', 'lint')
} finally {
    Pop-Location
}

Write-Host ''
Write-Host '=== Final summary ==='
$results | Format-Table -AutoSize
$failed = @($results | Where-Object { $_.ExitCode -ne 0 })
if ($failed.Count -gt 0) {
    Write-Error "$($failed.Count) test step(s) failed."
    exit 1
}
Write-Host 'All test steps passed.'
exit 0
