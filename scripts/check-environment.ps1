[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [Collections.Generic.List[string]]::new()
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machinePath;$userPath"

function Test-Tool {
    param([string] $Name, [string] $Command, [string[]] $Arguments, [bool] $Critical = $true)
    $resolved = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $resolved) {
        if ($Critical) { $failures.Add("Missing command: $Name") }
        return [pscustomobject]@{ Component = $Name; Status = if ($Critical) { 'FAIL' } else { 'WARN' }; Details = 'Not found in PATH' }
    }
    $output = (& $resolved.Source @Arguments 2>&1 | Out-String).Trim()
    $code = $LASTEXITCODE
    if ($code -ne 0 -and $Critical) { $failures.Add("$Name exited with code $code") }
    [pscustomobject]@{ Component = $Name; Status = if ($code -eq 0) { 'PASS' } else { 'FAIL' }; Details = "$output [$($resolved.Source)]" }
}

function Test-Condition {
    param([string] $Name, [bool] $Passed, [string] $Details, [bool] $Critical = $true)
    if (-not $Passed -and $Critical) { $failures.Add("$($Name): $Details") }
    [pscustomobject]@{ Component = $Name; Status = if ($Passed) { 'PASS' } elseif ($Critical) { 'FAIL' } else { 'WARN' }; Details = $Details }
}

$results = [Collections.Generic.List[object]]::new()
$isWindowsHost = $env:OS -eq 'Windows_NT'
$results.Add((Test-Condition 'Windows' $isWindowsHost ([Environment]::OSVersion.VersionString)))
$results.Add((Test-Condition 'PowerShell' $true $PSVersionTable.PSVersion.ToString()))
$results.Add((Test-Tool 'Git' 'git.exe' @('--version')))
$results.Add((Test-Tool 'Node.js' 'node.exe' @('--version')))
$results.Add((Test-Tool 'npm' 'npm.cmd' @('--version')))
$results.Add((Test-Tool 'Go' 'go.exe' @('version')))
$results.Add((Test-Tool 'Bash' 'bash.exe' @('--version') $false))
$results.Add((Test-Tool 'GNU Make' 'make.exe' @('--version') $false))
$results.Add((Test-Tool 'Docker' 'docker.exe' @('--version') $false))

$required = @('AGENTS.md', 'README.md', 'Makefile', 'package.json', 'package-lock.json', 'go.mod', 'go.sum')
$missing = @($required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $repoRoot $_) -PathType Leaf) })
$results.Add((Test-Condition 'Required project files' ($missing.Count -eq 0) $(if ($missing) { $missing -join ', ' } else { 'All present' })))
$results.Add((Test-Condition 'D-drive project path' ($repoRoot -like 'D:\*') $repoRoot))
$results.Add((Test-Condition 'node_modules' (Test-Path -LiteralPath (Join-Path $repoRoot 'node_modules') -PathType Container) 'Project dependencies installed'))

$probe = Join-Path $repoRoot ('.write-probe-' + [guid]::NewGuid().ToString('N') + '.tmp')
$writable = $false
try { [IO.File]::WriteAllText($probe, 'probe'); $writable = $true }
finally { if (Test-Path -LiteralPath $probe) { Remove-Item -LiteralPath $probe -Force } }
$results.Add((Test-Condition 'D-drive writability' $writable $repoRoot))

$service = Get-Service npcap -ErrorAction SilentlyContinue
$packet = 'C:\Windows\System32\Npcap\Packet.dll'
$wpcap = 'C:\Windows\System32\Npcap\wpcap.dll'
$results.Add((Test-Condition 'Npcap service' ($service -and $service.Status -eq 'Running') $(if ($service) { $service.Status } else { 'Not installed' })))
$results.Add((Test-Condition 'Packet.dll' (Test-Path $packet) $(if (Test-Path $packet) { (Get-Item $packet).VersionInfo.FileVersion } else { 'Missing' })))
$results.Add((Test-Condition 'wpcap.dll' (Test-Path $wpcap) $(if (Test-Path $wpcap) { (Get-Item $wpcap).VersionInfo.FileVersion } else { 'Missing' })))

$listener = Get-NetTCPConnection -LocalPort 5001 -State Listen -ErrorAction SilentlyContinue
$results.Add((Test-Condition 'TCP port 5001' (-not $listener) $(if ($listener) { 'Occupied; stop the known service before startup' } else { 'Available' }) $false))
Write-Host "Repository: $repoRoot"
$results | Format-Table -AutoSize -Wrap
Write-Host ''
Write-Host 'Relevant adapters (no MAC/IP output):'
Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue |
    Where-Object { ($_.Name + ' ' + $_.InterfaceDescription) -match 'Wi-?Fi|WLAN|Ethernet|VPN|ExitLag|VMware|Virtual|TAP|Radmin' } |
    Select-Object Name, InterfaceDescription, Status, ifIndex |
    Sort-Object ifIndex |
    Format-Table -AutoSize -Wrap
if ($failures.Count -gt 0) { Write-Error ('Critical checks failed: ' + ($failures -join '; ')); exit 1 }
Write-Host 'Environment check passed.'
exit 0
