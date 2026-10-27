param([ValidateSet('Release','Debug')][string]$Configuration='Release', [string]$MSBuildPath='')
$ErrorActionPreference='Stop'
if (-not $MSBuildPath) {
    $command=Get-Command MSBuild.exe -ErrorAction SilentlyContinue
    if ($command) { $MSBuildPath=$command.Source }
    elseif (Test-Path -LiteralPath 'C:\VSTool\VSBuildTools2026\MSBuild\Current\Bin\MSBuild.exe') {
        $MSBuildPath='C:\VSTool\VSBuildTools2026\MSBuild\Current\Bin\MSBuild.exe'
    } else { throw 'Install the Visual Studio C++ tools and Windows SDK, or pass -MSBuildPath.' }
}
& $MSBuildPath (Join-Path $PSScriptRoot 'DisplayCD.sln') /m "/p:Configuration=$Configuration" /p:Platform=x64 /nologo /v:minimal
if ($LASTEXITCODE -ne 0) { throw "DisplayCD build failed ($LASTEXITCODE)." }
