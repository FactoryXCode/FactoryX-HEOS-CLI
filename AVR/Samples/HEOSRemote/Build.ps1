[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MfPackRoot,
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',
    [string]$HeosCliRoot = 'D:\GitHub\FactoryX-HEOS-CLI',
    [string]$DelphiRoot = ${env:BDS}
)
$ErrorActionPreference = 'Stop'
if (-not $DelphiRoot) {
    $DelphiRoot = Join-Path ${env:ProgramFiles(x86)} 'Embarcadero\Studio\15.0'
}
$compiler = Join-Path $DelphiRoot ('bin\' + $(if ($Platform -eq 'Win32') { 'dcc32.exe' } else { 'dcc64.exe' }))
$sourcePath = Join-Path $MfPackRoot 'src'
if (-not (Test-Path -LiteralPath $sourcePath)) { throw 'MfPackRoot must point to the MfPack root containing src.' }
if (-not (Test-Path -LiteralPath $compiler)) { throw 'Delphi compiler not found; supply -DelphiRoot.' }
$repositoryRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$outputPath = Join-Path $repositoryRoot ('Build\' + $Platform + '\HEOSRemote')
$dcuPath = Join-Path $outputPath 'DCU'
New-Item -ItemType Directory -Path $dcuPath -Force | Out-Null
$libraryPath = Join-Path $DelphiRoot ('lib\' + $Platform.ToLowerInvariant() + '\release')
$controlsPath = Join-Path $PSScriptRoot 'Controls'
$apiPath = Join-Path $HeosCliRoot 'Source'
$avrPath = Join-Path $HeosCliRoot 'AVR\Source'
if (-not (Test-Path -LiteralPath (Join-Path $apiPath 'Heos.Cli.pas'))) { throw 'HeosCliRoot must point to the HEOS API repository containing Source.' }
Push-Location $PSScriptRoot
try {
    & $compiler -B -Q '-NSSystem;Winapi;Vcl;Data;Xml;System.Win;Data.Win;Xml.Win' "-U$controlsPath;$apiPath;$avrPath;$sourcePath;$libraryPath" "-N0$dcuPath" "-E$outputPath" HEOSRemote.dpr
    if ($LASTEXITCODE -ne 0) { throw 'HEOS Remote build failed.' }
}
finally { Pop-Location }