param([string]$OutputDirectory=(Join-Path $PSScriptRoot 'dist'))
$ErrorActionPreference='Stop'
$metadataPath=Join-Path $PSScriptRoot 'store\metadata.json'
$metadata=Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
$dll=Join-Path $PSScriptRoot 'bin\x64\Release\DisplayCD.dll'
if (-not (Test-Path -LiteralPath $dll)) { throw 'Build Release x64 before packaging.' }
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
        'config.ini'=(Join-Path $PSScriptRoot 'config.ini')
        'LICENSE'=(Join-Path $PSScriptRoot 'LICENSE')
        'NOTICE.md'=(Join-Path $PSScriptRoot 'NOTICE.md')
        'README.md'=(Join-Path $PSScriptRoot 'README.md')
        'MinHook-LICENSE.txt'=(Join-Path $PSScriptRoot 'vendor\minhook\LICENSE.txt')
    }
    foreach ($entry in $files.GetEnumerator()) {
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$entry.Value,$entry.Key) | Out-Null
    }
} finally { $zip.Dispose() }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'store\install.lua'),$metadataPath -Destination $output
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
