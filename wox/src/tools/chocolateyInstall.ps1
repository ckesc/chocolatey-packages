$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$url64 = 'https://github.com/Wox-launcher/Wox/releases/download/v2.3.0/wox-windows-amd64.exe'
$fileFullPath = Join-Path $toolsDir 'wox.exe'

if ((Get-OSArchitectureWidth) -lt 64) {
  throw 'Wox 2.x only provides Windows amd64 builds.'
}

Get-ChocolateyWebFile `
  -PackageName $env:ChocolateyPackageName `
  -FileFullPath $fileFullPath `
  -Url64bit $url64 `
  -Checksum64 'bd4c0d29b6b81b58dddf36d4770088459c06d1270d1ce150bba0598464f87446' `
  -ChecksumType64 'sha256'

$programs = [Environment]::GetFolderPath('CommonPrograms')
if ([string]::IsNullOrWhiteSpace($programs)) {
  $programs = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'
}

Install-ChocolateyShortcut `
  -ShortcutFilePath (Join-Path $programs 'Wox.lnk') `
  -TargetPath $fileFullPath `
  -WorkingDirectory $toolsDir
