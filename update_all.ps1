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

Push-Location (Join-Path $PSScriptRoot 'wox\src')
try {
  & (Join-Path (Get-Location) 'update.ps1')
}
finally {
  Pop-Location
}
