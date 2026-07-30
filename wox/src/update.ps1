#Requires -Version 5.1
# Chocolatey-AU updater for the wox package.
# Upstream: https://github.com/Wox-launcher/Wox/releases
# Skips prereleases (GitHub /releases/latest already returns the latest stable).

Import-Module Chocolatey-AU

$releasesRepo = 'Wox-launcher/Wox'
$windowsAsset = 'wox-windows-amd64.exe'
$packageSourceUrl = 'https://github.com/ckesc/chocolatey-packages'

function global:au_SearchReplace {
  @{
    '.\tools\chocolateyInstall.ps1' = @{
      "(?i)(^\s*`$url64\s*=\s*)('.*')"   = "`$1'$($Latest.URL64)'"
      "(?i)(-\s*Checksum64\s+)('.*')"    = "`$1'$($Latest.Checksum64)'"
    }
    '.\legal\VERIFICATION.txt' = @{
      '(?i)(Package Version:\s*).*' = "`${1}$($Latest.Version)"
      '(?i)https://github\.com/Wox-launcher/Wox/releases/download/v[\w\.-]+/wox-windows-amd64\.exe' = "$($Latest.URL64)"
      '(?im)(Checksum:\s*\r?\n)[a-fA-F0-9]{64}' = "`${1}$($Latest.Checksum64)"
      '(?i)(asset metadata for Wox )v[\w\.-]+' = "`${1}$($Latest.Tag)"
      '(?i)https://github\.com/Wox-launcher/Wox/releases/tag/v[\w\.-]+' = "$($Latest.ReleaseUrl)"
    }
    '.\legal\LICENSE.txt' = @{
      '(?i)(https://raw\.githubusercontent\.com/Wox-launcher/Wox/)v[\w\.-]+(/LICENSE)' = "`${1}$($Latest.Tag)`$2"
    }
    '.\wox.nuspec' = @{
      '(?i)(<version>).*?(</version>)' = "`${1}$($Latest.Version)`$2"
      '(?i)(<licenseUrl>).*?(</licenseUrl>)' = "`${1}https://raw.githubusercontent.com/Wox-launcher/Wox/$($Latest.Tag)/LICENSE`$2"
      '(?i)(<iconUrl>).*?(</iconUrl>)' = "`${1}https://raw.githubusercontent.com/Wox-launcher/Wox/$($Latest.Tag)/assets/app.png`$2"
      '(?i)(<packageSourceUrl>).*?(</packageSourceUrl>)' = "`${1}$packageSourceUrl`$2"
    }
  }
}

# releaseNotes is handled here instead of via au_SearchReplace because
# Chocolatey-AU applies those patterns per-line (Get-Content without -Raw),
# which can't match/replace a <releaseNotes> value that spans multiple lines
# (e.g. the hand-written multi-paragraph notes from a manual version bump).
function global:au_AfterUpdate($Package) {
  $xml = New-Object xml
  $xml.PSBase.PreserveWhitespace = $true
  $xml.Load($Package.NuspecPath)
  $xml.package.metadata.releaseNotes = $Latest.ReleaseNotes
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Package.NuspecPath, $xml.InnerXml, $utf8NoBom)
}

function global:au_BeforeUpdate {
  if ([string]::IsNullOrWhiteSpace($Latest.Checksum64)) {
    Write-Host 'GitHub asset digest missing; downloading to compute sha256...'
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64 -Algorithm sha256
  }
  $Latest.ChecksumType64 = 'sha256'
}

function global:au_GetLatest {
  $headers = @{
    'User-Agent' = 'ckesc-chocolatey-packages-au'
    'Accept'     = 'application/vnd.github+json'
  }
  if ($env:GITHUB_TOKEN) {
    $headers['Authorization'] = "Bearer $($env:GITHUB_TOKEN)"
  }

  $release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$releasesRepo/releases/latest" `
    -Headers $headers

  if ($release.prerelease) {
    throw "refusing to package prerelease $($release.tag_name)"
  }

  $asset = @($release.assets) | Where-Object { $_.name -eq $windowsAsset } | Select-Object -First 1
  if (-not $asset) {
    throw "release $($release.tag_name) has no asset named $windowsAsset"
  }

  $tag = $release.tag_name
  $version = $tag.TrimStart('v')
  if ($version -match '-') {
    throw "refusing to package non-stable version $version"
  }

  $checksum = $null
  if ($asset.digest -match '^sha256:([a-fA-F0-9]{64})$') {
    $checksum = $Matches[1].ToLowerInvariant()
  }

  @{
    Version        = $version
    Tag            = $tag
    URL64          = $asset.browser_download_url
    Checksum64     = $checksum
    ChecksumType64 = 'sha256'
    ReleaseUrl     = $release.html_url
    ReleaseNotes   = "Updated to Wox $version. See $($release.html_url)"
  }
}

update -ChecksumFor none
