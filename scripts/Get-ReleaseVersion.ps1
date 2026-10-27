param(
    [string]$Version='',
    [string]$ProjectRoot=(Split-Path -Parent $PSScriptRoot)
)
$ErrorActionPreference='Stop'
$metadata=Get-Content -LiteralPath (Join-Path $ProjectRoot 'store/metadata.json') -Raw | ConvertFrom-Json
$base=[string]$metadata.version
if ($base -notmatch '^\d+\.\d+\.\d+$') { throw 'Keep the source version in major.minor.patch format.' }
$config=[IO.File]::ReadAllText((Join-Path $ProjectRoot 'config.ini'))
$general=[regex]::Match($config,'(?ms)^\[General\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
$configured=[regex]::Match($general.Groups['body'].Value,'(?m)^Version\s*=\s*(\S+)\s*$').Groups[1].Value
if ($configured -ne $base) { throw 'config.ini and store/metadata.json base versions must agree.' }
if (-not $Version) { $Version=$base }
if ($Version -notmatch '^\d+\.\d+\.\d+$' -or -not [version]::TryParse($Version,[ref]([version]$null))) {
    throw 'Release version must contain exactly three numeric components, for example 1.1.0.'
}
[pscustomobject]@{ Version=$Version; Tag="v$Version" }
