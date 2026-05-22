$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$url64 = 'https://github.com/Wox-launcher/Wox/releases/download/v2.1.0/wox-windows-amd64.exe'
$fileFullPath = Join-Path $toolsDir 'wox.exe'

if ((Get-OSArchitectureWidth) -lt 64) {
  throw 'Wox 2.x only provides Windows amd64 builds.'
}

Get-ChocolateyWebFile `
  -PackageName $env:ChocolateyPackageName `
  -FileFullPath $fileFullPath `
  -Url64bit $url64 `
  -Checksum64 '0f6f3118a5be3827f19a823408c490048113b07bb1f9fd7451243b13b147954b' `
  -ChecksumType64 'sha256'

$programs = [Environment]::GetFolderPath('CommonPrograms')
if ([string]::IsNullOrWhiteSpace($programs)) {
  $programs = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'
}

Install-ChocolateyShortcut `
  -ShortcutFilePath (Join-Path $programs 'Wox.lnk') `
  -TargetPath $fileFullPath `
  -WorkingDirectory $toolsDir
