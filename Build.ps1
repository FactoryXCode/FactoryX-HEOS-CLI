[CmdletBinding()]
param(
    [string]$DelphiRoot,
    [ValidateSet('Win32', 'Win64')]
    [string[]]$Platform = @('Win32', 'Win64'),
    [switch]$RunTests
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = $PSScriptRoot

if (-not $DelphiRoot) {
    if ($env:BDS -and (Test-Path -LiteralPath (Join-Path $env:BDS 'bin\dcc32.exe'))) {
        $DelphiRoot = $env:BDS
    }
    else {
        foreach ($registryPath in @('HKCU:\Software\Embarcadero\BDS\15.0',
                                     'HKLM:\Software\WOW6432Node\Embarcadero\BDS\15.0')) {
            $installation = Get-ItemProperty -LiteralPath $registryPath -ErrorAction SilentlyContinue
            if ($installation -and $installation.RootDir) {
                $DelphiRoot = $installation.RootDir
                break
            }
        }
    }
    if (-not $DelphiRoot) {
        $DelphiRoot = Join-Path ${env:ProgramFiles(x86)} 'Embarcadero\Studio\15.0'
    }
}

foreach ($target in $Platform) {
    $compilerName = if ($target -eq 'Win32') { 'dcc32.exe' } else { 'dcc64.exe' }
    $compiler = Join-Path $DelphiRoot ('bin\' + $compilerName)
    $libraryPath = Join-Path $DelphiRoot ('lib\' + $target.ToLowerInvariant() + '\release')
    if (-not (Test-Path -LiteralPath $compiler) -or -not (Test-Path -LiteralPath $libraryPath)) {
        throw "Delphi compiler or libraries missing for $target. Supply -DelphiRoot."
    }

    $outputPath = Join-Path $repositoryRoot ('Build\' + $target)
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    $sourcePath = Join-Path $repositoryRoot 'Source'

    foreach ($project in @('Examples\HeosCliDemo.dpr', 'Tests\HeosApiTests.dpr')) {
        $projectPath = Join-Path $repositoryRoot $project
        Write-Host "Building $project ($target)"
        Push-Location (Split-Path -Parent $projectPath)
        try {
            & $compiler -B -Q '-NSSystem;Winapi' "-U$sourcePath;$libraryPath" "-N0$outputPath" "-E$outputPath" (Split-Path -Leaf $projectPath)
            if ($LASTEXITCODE -ne 0) {
                throw "Compilation failed for $project ($target)."
            }
        }
        finally {
            Pop-Location
        }
    }

    if ($RunTests) {
        Write-Host "Running HEOS simulator tests ($target)"
        & (Join-Path $outputPath 'HeosApiTests.exe')
        if ($LASTEXITCODE -ne 0) {
            throw "HEOS simulator tests failed ($target)."
        }
    }
}