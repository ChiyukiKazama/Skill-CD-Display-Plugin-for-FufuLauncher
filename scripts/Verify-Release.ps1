param(
    [Parameter(Mandatory)][string]$ExpectedVersion,
    [string]$Directory=(Join-Path (Split-Path -Parent $PSScriptRoot) 'dist'),
    [switch]$RequireCompression
)
$ErrorActionPreference='Stop'
$metadata=Get-Content -LiteralPath (Join-Path $Directory 'metadata.json') -Raw | ConvertFrom-Json
$hashes=Get-Content -LiteralPath (Join-Path $Directory 'package-hashes.json') -Raw | ConvertFrom-Json
if ($metadata.version -ne $ExpectedVersion -or $hashes.version -ne $ExpectedVersion) { throw 'Release versions differ.' }
if ($metadata.id -ne $hashes.id -or $metadata.dll_file_name -ne 'DisplayCD.dll') { throw 'Plugin identity differs.' }
if ($metadata.archive_file_name -ne "DisplayCD-$ExpectedVersion.zip") { throw 'Release archive name differs.' }
$archive=Join-Path $Directory $metadata.archive_file_name
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $hashes.archive_sha256) { throw 'Archive checksum mismatch.' }
if ((Get-FileHash -LiteralPath (Join-Path $Directory 'install.lua') -Algorithm SHA256).Hash -ne $hashes.installer_sha256) { throw 'Installer checksum mismatch.' }
Add-Type -AssemblyName System.IO.Compression
$zip=[IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($archive))
try {
    $expected=@('DisplayCD.dll','config.ini','LICENSE','NOTICE.md','README.md','MinHook-LICENSE.txt')
    if (@(Compare-Object $expected @($zip.Entries.FullName)).Count) { throw 'Unexpected archive contents.' }
    $stream=$zip.GetEntry('DisplayCD.dll').Open()
    $memory=[IO.MemoryStream]::new()
    try { $stream.CopyTo($memory); $dll=$memory.ToArray() } finally { $stream.Dispose(); $memory.Dispose() }
    $dllHash=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($dll)).ToLowerInvariant()
    if ($dllHash -ne $hashes.dll_sha256) { throw 'Packaged DLL checksum mismatch.' }
    if ($dll.Length -lt 64 -or [Text.Encoding]::ASCII.GetString($dll,0,2) -ne 'MZ') { throw 'Invalid DLL DOS header.' }
    $pe=[BitConverter]::ToInt32($dll,60)
    if ($pe -lt 0 -or $pe+26 -ge $dll.Length -or [BitConverter]::ToUInt32($dll,$pe) -ne 0x4550 -or
        [BitConverter]::ToUInt16($dll,$pe+4) -ne 0x8664 -or -not ([BitConverter]::ToUInt16($dll,$pe+22) -band 0x2000)) { throw 'Release DLL is not an x64 PE DLL.' }
    $reader=[IO.StreamReader]::new($zip.GetEntry('config.ini').Open())
    try { $config=$reader.ReadToEnd() } finally { $reader.Dispose() }
    $general=[regex]::Match($config,'(?ms)^\[General\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
    $version=[regex]::Match($general.Groups['body'].Value,'(?m)^Version\s*=\s*(\S+)\s*$').Groups[1].Value
    if ($version -ne $ExpectedVersion) { throw 'Packaged config version differs.' }
    if ($config -notmatch '(?m)^File\s*=\s*DisplayCD\.dll\s*$' -or $config -match '(?m)^\[DisplaySkillCD\]') { throw 'Packaged configuration is invalid.' }
    $sections=@([regex]::Matches($config,'(?m)^\[([^\]\r\n]+)\]') | ForEach-Object { $_.Groups[1].Value })
    if (@(Compare-Object @('General','ShowElementalSkillCD','ShowElementalBurstCD','ShowChargeIndicators') $sections).Count) { throw 'Packaged configuration sections differ.' }
} finally { $zip.Dispose() }
$compressionPath=Join-Path $Directory 'compression.json'
if ($RequireCompression -and -not (Test-Path -LiteralPath $compressionPath)) { throw 'Compression verification record is missing.' }
if (Test-Path -LiteralPath $compressionPath) {
    $compression=Get-Content -LiteralPath $compressionPath -Raw | ConvertFrom-Json
    if (-not $compression.integrity_test_passed -or -not $compression.decompression_test_passed -or
        -not $compression.load_test_passed -or $compression.compressed_sha256 -ne $hashes.dll_sha256 -or
        $compression.compressed_bytes -ge $compression.original_bytes) { throw 'Compressed DLL verification differs.' }
}
Write-Output "Verified release $ExpectedVersion, x64 DLL, package contents and SHA256."
