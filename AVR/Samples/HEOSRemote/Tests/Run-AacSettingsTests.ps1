[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$MfPackRoot,
    [string]$HeosCliRoot = '',
    [string]$AvrSourcePath = '',
    [string]$DelphiRoot = 'C:\Program Files (x86)\Embarcadero\Studio\15.0',
    [string]$OutputRoot = ''
)
$ErrorActionPreference = 'Stop'
$sampleRoot = Split-Path -Parent $PSScriptRoot
if (-not $HeosCliRoot) { $HeosCliRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $sampleRoot)) }
if (-not $AvrSourcePath) { $AvrSourcePath = Join-Path $HeosCliRoot 'AVR\Source' }
if (-not $OutputRoot) { $OutputRoot = Join-Path $HeosCliRoot 'Build\AacSettingsTests' }
if (-not (Test-Path -LiteralPath (Join-Path $AvrSourcePath 'Avr.Capabilities.pas'))) {
    throw 'Avr.Capabilities.pas is required; supply -AvrSourcePath with its source directory.'
}
$fixtureRoot = Join-Path $OutputRoot 'Fixture'
New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
# Match the radio regression harness: expose private state in a fixture only.
$formText = [IO.File]::ReadAllText((Join-Path $sampleRoot 'MainForm.pas')).Replace('  private', '  public')
[IO.File]::WriteAllText((Join-Path $fixtureRoot 'MainForm.pas'), $formText)
Copy-Item -LiteralPath (Join-Path $sampleRoot 'MainForm.dfm') -Destination $fixtureRoot
$originalLocalAppData = $env:LOCALAPPDATA
$originalAppData = $env:APPDATA
Push-Location $fixtureRoot
try {
    foreach ($platform in @('win32', 'win64')) {
        $output = Join-Path $OutputRoot $platform
        New-Item -ItemType Directory -Path (Join-Path $output 'dcu'),(Join-Path $output 'AppData') -Force | Out-Null
        $env:LOCALAPPDATA = Join-Path $output 'AppData'
        $env:APPDATA = $env:LOCALAPPDATA
        $paths = @($fixtureRoot, $sampleRoot, (Join-Path $sampleRoot 'Controls'),
            (Join-Path $HeosCliRoot 'Source'), $AvrSourcePath,
            (Join-Path $MfPackRoot 'src'), (Join-Path $DelphiRoot ('lib\' + $platform + '\release')))
        $compiler = Join-Path $DelphiRoot ('bin\dcc' + $(if ($platform -eq 'win32') { '32' } else { '64' }) + '.exe')
        $compilerArgs = @('-B', '-Q', '-NSSystem;Winapi;Vcl;Data;Xml;System.Win;Data.Win;Xml.Win',
            ('-U' + ($paths -join ';')), ('-N0' + (Join-Path $output 'dcu')), ('-E' + $output),
            (Join-Path $PSScriptRoot 'HeosAacSettingsTests.dpr'))
        & $compiler @compilerArgs
        if ($LASTEXITCODE -ne 0) { throw "$platform test compilation failed." }
        & (Join-Path $output 'HeosAacSettingsTests.exe')
        if ($LASTEXITCODE -ne 0) { throw "$platform AAC settings tests failed." }
    }
}
finally {
    Pop-Location
    $env:LOCALAPPDATA = $originalLocalAppData
    $env:APPDATA = $originalAppData
}