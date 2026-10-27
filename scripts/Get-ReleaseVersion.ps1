param(
    [Parameter(Mandatory)][ValidateRange(1,21474836)][long]$RunNumber,
    [Parameter(Mandatory)][ValidateRange(1,99)][int]$RunAttempt,
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
# Numeric fourth component works with System.Version and grows on retries too.
$revision=$RunNumber*100+$RunAttempt
$version="$base.$revision"
if (-not [version]::TryParse($version,[ref]([version]$null))) { throw 'Generated version is invalid.' }
[pscustomobject]@{ Version=$version; Tag="v$version" }
