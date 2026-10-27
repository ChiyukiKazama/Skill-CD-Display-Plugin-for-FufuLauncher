param(
    [string]$OutputDirectory=(Join-Path $PSScriptRoot 'dist'),
    [string]$Version='',
    [string]$DllPath=(Join-Path $PSScriptRoot 'bin/x64/Release/DisplayCD.dll')
)
$ErrorActionPreference='Stop'
$metadataPath=Join-Path $PSScriptRoot 'store\metadata.json'
$metadata=Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
$dll=[IO.Path]::GetFullPath($DllPath)
if (-not (Test-Path -LiteralPath $dll)) { throw 'Build Release x64 before packaging.' }
if (-not $Version) { $Version=[string]$metadata.version }
if ($Version -notmatch '^\d+\.\d+\.\d+(\.\d+)?$') { throw 'Package version must have three or four numeric components.' }
$config=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'config.ini'))
$general=[regex]::Match($config,'(?ms)^\[General\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
$versionLine=[regex]::Match($general.Value,'(?m)^Version\s*=\s*(\S+)\s*$')
if (-not $versionLine.Success -or $versionLine.Groups[1].Value -ne $metadata.version) { throw 'Source configuration and metadata versions differ.' }
$value=$versionLine.Groups[1]
$offset=$general.Index+$value.Index
$config=$config.Remove($offset,$value.Length).Insert($offset,$Version)
$metadata.version=$Version
$metadata.archive_file_name="DisplayCD-$Version.zip"
$output=[IO.Path]::GetFullPath($OutputDirectory)
[IO.Directory]::CreateDirectory($output) | Out-Null
$archive=Join-Path $output $metadata.archive_file_name
# Refuse silent replacement of an existing release artifact.
if (Test-Path -LiteralPath $archive) { throw "Release archive already exists: $archive" }
Add-Type -AssemblyName System.IO.Compression
$zip=[IO.Compression.ZipFile]::Open($archive,[IO.Compression.ZipArchiveMode]::Create)
try {
    $files=@{
        'DisplayCD.dll'=$dll
        'LICENSE'=(Join-Path $PSScriptRoot 'LICENSE')
        'NOTICE.md'=(Join-Path $PSScriptRoot 'NOTICE.md')
        'README.md'=(Join-Path $PSScriptRoot 'README.md')
        'MinHook-LICENSE.txt'=(Join-Path $PSScriptRoot 'vendor\minhook\LICENSE.txt')
    }
    foreach ($entry in $files.GetEnumerator()) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$entry.Value,$entry.Key) | Out-Null
    }
    $writer=[IO.StreamWriter]::new($zip.CreateEntry('config.ini').Open(),[Text.UTF8Encoding]::new($false))
    try { $writer.Write($config) } finally { $writer.Dispose() }
} finally { $zip.Dispose() }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'store\install.lua') -Destination $output
$metadata | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $output 'metadata.json') -Encoding utf8
$compression=Join-Path (Split-Path -Parent $dll) 'compression.json'
if (Test-Path -LiteralPath $compression) { Copy-Item -LiteralPath $compression -Destination $output }
[ordered]@{
    id=$metadata.id
    version=$metadata.version
    archive_file_name=$metadata.archive_file_name
    archive_sha256=(Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    dll_sha256=(Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash.ToLowerInvariant()
    installer_sha256=(Get-FileHash -LiteralPath (Join-Path $output 'install.lua') -Algorithm SHA256).Hash.ToLowerInvariant()
    uploaded=$false
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'package-hashes.json') -Encoding utf8
Write-Output "Store upload artifacts: $output"
