$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$url64 = 'https://github.com/Wox-launcher/Wox/releases/download/v2.4.3/wox-windows-amd64.exe'
$fileFullPath = Join-Path $toolsDir 'wox.exe'

if ((Get-OSArchitectureWidth) -lt 64) {
  throw 'Wox 2.x only provides Windows amd64 builds.'
}

Get-ChocolateyWebFile `
  -PackageName $env:ChocolateyPackageName `
  -FileFullPath $fileFullPath `
  -Url64bit $url64 `
  -Checksum64 '21048354e87a12cffe9b70c3c75ae1766ad91842cfaca1d2dced526e4784f7b5' `
  -ChecksumType64 'sha256'

$programs = [Environment]::GetFolderPath('CommonPrograms')
if ([string]::IsNullOrWhiteSpace($programs)) {
  $programs = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'
}

Install-ChocolateyShortcut `
  -ShortcutFilePath (Join-Path $programs 'Wox.lnk') `
  -TargetPath $fileFullPath `
  -WorkingDirectory $toolsDir
