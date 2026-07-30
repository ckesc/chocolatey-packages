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

# Chocolatey-AU requires <name>/<name>.nuspec, and derives <name> from the leaf
# name of the current directory (Split-Path -Leaf $pwd) internally. This repo
# keeps sources in wox/src/ (for the existing bat helpers), so AU can't run
# there directly.
#
# We used to bridge this with a directory junction named wox pointing at
# wox/src, but that's unreliable under pwsh: after Push-Location into the
# junction, $pwd can resolve to the junction's *target* path, so the leaf name
# AU sees is "src" instead of "wox", and it fails with "No nuspec file found
# in the package directory". Instead, copy the sources into a real directory
# named wox and copy the AU-edited metadata files back afterwards.
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
Copy-Item -LiteralPath $packageSource -Destination $auPackageDir -Recurse

Push-Location $auPackageDir
try {
  & (Join-Path $auPackageDir 'update.ps1')

  # Sync back exactly the files au_SearchReplace edits (same set the workflow
  # stages for commit).
  $filesToSync = @(
    'wox.nuspec'
    'tools\chocolateyInstall.ps1'
    'legal\VERIFICATION.txt'
    'legal\LICENSE.txt'
  )
  foreach ($relativePath in $filesToSync) {
    Copy-Item -LiteralPath (Join-Path $auPackageDir $relativePath) -Destination (Join-Path $packageSource $relativePath) -Force
  }
}
finally {
  Pop-Location
  Remove-Item -LiteralPath $auWork -Recurse -Force -ErrorAction SilentlyContinue
}
