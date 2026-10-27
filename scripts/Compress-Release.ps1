param(
    [string]$DllPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'bin/x64/Release/DisplayCD.dll'),
    [string]$WorkDirectory=(Join-Path (Split-Path -Parent $PSScriptRoot) 'obj/release'),
    [string]$UpxPath=''
)
$ErrorActionPreference='Stop'
$source=(Resolve-Path -LiteralPath $DllPath).Path
$work=[IO.Path]::GetFullPath($WorkDirectory)
if (Test-Path -LiteralPath $work) { throw "Compression directory already exists: $work" }
[IO.Directory]::CreateDirectory($work) | Out-Null
if (-not $UpxPath) {
    # Pin the same UPX version used by local compression verification.
    $upxVersion='5.2.0'
    $headers=@{ 'User-Agent'='DisplayCD-release'; 'Accept'='application/vnd.github+json' }
    if ($env:GH_TOKEN) { $headers.Authorization="Bearer $env:GH_TOKEN" }
    $release=Invoke-RestMethod -Uri "https://api.github.com/repos/upx/upx/releases/tags/v$upxVersion" -Headers $headers
    $asset=@($release.assets | Where-Object name -eq "upx-$upxVersion-win64.zip")
    if ($asset.Count -ne 1 -or $asset[0].digest -notmatch '^sha256:([0-9a-fA-F]{64})$') {
        throw 'UPX release asset or its published SHA256 is missing.'
    }
    $expectedHash=$Matches[1]
    $archive=Join-Path $work 'upx.zip'
    Invoke-WebRequest -Uri $asset[0].browser_download_url -OutFile $archive
    if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expectedHash) { throw 'UPX archive checksum mismatch.' }
    Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $work 'upx')
    $UpxPath=Join-Path $work "upx/upx-$upxVersion-win64/upx.exe"
}
$UpxPath=(Resolve-Path -LiteralPath $UpxPath).Path
$packed=Join-Path $work 'DisplayCD.dll'
$unpacked=Join-Path $work 'DisplayCD.unpacked.dll'
$originalHash=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
$originalSize=(Get-Item -LiteralPath $source).Length
# Exhaustively try UPX's extra methods/filters and retain its smallest result.
& $UpxPath --best --ultra-brute -o $packed $source
if ($LASTEXITCODE -ne 0) { throw 'UPX compression failed.' }
& $UpxPath --test $packed
if ($LASTEXITCODE -ne 0) { throw 'UPX integrity test failed.' }
& $UpxPath --decompress -o $unpacked $packed
if ($LASTEXITCODE -ne 0 -or (Get-Item -LiteralPath $unpacked).Length -ne $originalSize) { throw 'UPX decompression failed.' }
# UPX rebuilds PE import hints and drops debug records, so the unpacked file
# need not have the original file hash. Test the actual packed Windows loader.
& (Get-Process -Id $PID).Path -NoProfile -File (Join-Path $PSScriptRoot 'Test-DllLoad.ps1') -DllPath $packed
if ($LASTEXITCODE -ne 0) { throw 'Compressed DLL load check failed.' }
$packedSize=(Get-Item -LiteralPath $packed).Length
if ($packedSize -ge $originalSize) { throw 'UPX did not reduce DLL size.' }
[ordered]@{
    tool=(& $UpxPath --version | Select-Object -First 1)
    options='--best --ultra-brute'
    original_bytes=$originalSize
    compressed_bytes=$packedSize
    original_sha256=$originalHash.ToLowerInvariant()
    compressed_sha256=(Get-FileHash -LiteralPath $packed -Algorithm SHA256).Hash.ToLowerInvariant()
    integrity_test_passed=$true
    decompression_test_passed=$true
    load_test_passed=$true
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $work 'compression.json') -Encoding utf8
Write-Output "UPX verified: $originalSize -> $packedSize bytes."
