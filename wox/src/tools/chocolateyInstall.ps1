$packageName = 'Wox' # arbitrary name for the package, used in messages
$url = 'https://github.com/qianlifeng/Wox/releases/download/v1.1.1/Wox-1.1.1.zip' # download url

Install-ChocolateyZipPackage "$packageName" "$url" "$(Split-Path -parent $MyInvocation.MyCommand.Definition)" -checksum "FF7001713F2DC7FBA88235F948CF85BD"