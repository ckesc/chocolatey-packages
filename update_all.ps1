#Requires -Version 5.1
# Run the wox AU updater from the repo root.
# Examples:
#   ./update_all.ps1
#   $Env:au_Push = 'true'; $Env:api_key = '<choco-api-key>'; ./update_all.ps1

param(
  [switch] $Push,
  [switch] $Force
)

$ErrorActionPreference = 'Stop'

if ($Push) {
  $Env:au_Push = 'true'
}

if (-not (Get-Module -ListAvailable -Name Chocolatey-AU)) {
  throw 'Chocolatey-AU module not found. Install with: Install-Module Chocolatey-AU -Scope CurrentUser'
}

Import-Module Chocolatey-AU

if ($Force) {
  $global:au_Force = $true
}

# Chocolatey-AU requires <name>/<name>.nuspec. This repo keeps sources in wox/src/
# (for the existing bat helpers), so run AU through a temporary junction named wox.
$packageSource = Join-Path $PSScriptRoot 'wox\src'
$nuspec = Join-Path $packageSource 'wox.nuspec'
if (-not (Test-Path -LiteralPath $nuspec)) {
  throw "Expected package nuspec at $nuspec"
}

$auWork = Join-Path ([System.IO.Path]::GetTempPath()) 'ckesc-au-wox'
$auPackageDir = Join-Path $auWork 'wox'
if (Test-Path -LiteralPath $auWork) {
  Remove-Item -LiteralPath $auWork -Recurse -Force
}
New-Item -ItemType Directory -Path $auWork | Out-Null
New-Item -ItemType Junction -Path $auPackageDir -Target $packageSource | Out-Null

Push-Location $auPackageDir
try {
  & (Join-Path $auPackageDir 'update.ps1')
}
finally {
  Pop-Location
  # Remove the junction without deleting the real package files.
  cmd.exe /c "rmdir `"$auPackageDir`""
  Remove-Item -LiteralPath $auWork -Recurse -Force -ErrorAction SilentlyContinue
}
