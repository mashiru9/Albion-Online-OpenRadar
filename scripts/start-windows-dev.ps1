[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = 'D:\Projects\Albion-Online-OpenRadar'
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$env:Path = "$machinePath;$userPath"

foreach ($command in @('node.exe', 'npm.cmd', 'go.exe')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is missing from PATH: $command"
    }
}
foreach ($file in @('package.json', 'package-lock.json', 'go.mod', 'cmd\radar\main.go')) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $file) -PathType Leaf)) {
        throw "Required project file is missing: $file"
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'node_modules') -PathType Container)) {
    throw 'node_modules is missing. Run npm ci from the project root first.'
}
$listener = Get-NetTCPConnection -LocalPort 5001 -State Listen -ErrorAction SilentlyContinue
if ($listener) {
    throw 'TCP port 5001 is already occupied. This script will not stop the existing process.'
}

Push-Location $repoRoot
try {
    & npm.cmd run css
    if ($LASTEXITCODE -ne 0) { throw "npm run css failed with exit code $LASTEXITCODE" }
    & npm.cmd run vendors
    if ($LASTEXITCODE -ne 0) { throw "npm run vendors failed with exit code $LASTEXITCODE" }
    Write-Host 'Starting OpenRadar at http://localhost:5001'
    Write-Host 'Press Ctrl+C once to stop the service safely.'
    & go.exe run ./cmd/radar -dev
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
