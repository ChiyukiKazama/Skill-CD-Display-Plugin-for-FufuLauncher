param([ValidateSet('Release','Debug')][string]$Configuration='Release', [string]$MSBuildPath='', [string]$Version='')
$ErrorActionPreference='Stop'
if (-not $Version) { $Version=(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'store/metadata.json') -Raw | ConvertFrom-Json).version }
if ($Version -notmatch '^\d+\.\d+\.\d+(\.\d+)?$') { throw 'Build version must have three or four numeric components.' }
if (-not $MSBuildPath) {
    $command=Get-Command MSBuild.exe -ErrorAction SilentlyContinue
    if ($command) { $MSBuildPath=$command.Source }
    elseif (Test-Path -LiteralPath 'C:\VSTool\VSBuildTools2026\MSBuild\Current\Bin\MSBuild.exe') {
        $MSBuildPath='C:\VSTool\VSBuildTools2026\MSBuild\Current\Bin\MSBuild.exe'
    } else { throw 'Install the Visual Studio C++ tools and Windows SDK, or pass -MSBuildPath.' }
}
& $MSBuildPath (Join-Path $PSScriptRoot 'DisplayCD.sln') /m "/p:Configuration=$Configuration" /p:Platform=x64 "/p:DisplayCDVersion=$Version" /nologo /v:minimal
if ($LASTEXITCODE -ne 0) { throw "DisplayCD build failed ($LASTEXITCODE)." }
