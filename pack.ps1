#!/usr/bin/env pwsh
param(
    [string]$PinFile,
    [string]$OutDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
if (-not $PinFile) { $PinFile = Join-Path $root 'pack.json' }
if (-not $OutDir) { $OutDir = Join-Path $root 'dist' }

$pin = Get-Content -LiteralPath $PinFile -Raw | ConvertFrom-Json
$cacheDir = Join-Path $root 'cache'

function Get-CheckedArchive([string]$path, [string]$url, [string]$sha256) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path) | Out-Null
        Write-Host "downloading $url"
        Invoke-WebRequest -Uri $url -OutFile $path
    }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    if ($actual -ne $sha256.ToUpperInvariant()) {
        Write-Host "pack: SHA-256 mismatch for $path"
        Write-Host "  expected $($sha256.ToUpperInvariant())"
        Write-Host "  actual   $actual"
        exit 1
    }
}

# Both archives are checked before either zip is written.
$archive = Join-Path $cacheDir $pin.archive
Get-CheckedArchive $archive $pin.url $pin.sha256
$unityLibs = $pin.unityLibs
$unityArchive = Join-Path $cacheDir "unity-libs/$($unityLibs.version).zip"
Get-CheckedArchive $unityArchive $unityLibs.url $unityLibs.sha256

$zipPath = Join-Path $OutDir "BepInExPack_SurvivalLog-$($pin.build).zip"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
Copy-Item -LiteralPath $archive -Destination $zipPath -Force

$credits = Get-Content -LiteralPath (Join-Path $root 'credits.template.txt') -Raw
foreach ($token in 'build', 'commit', 'archive', 'sha256', 'url') {
    $credits = $credits.Replace("{{$token}}", [string]$pin.$token)
}
if ($credits -match '{{') { throw "credits template has an unresolved token: $credits" }
$credits = ($credits -replace "`r`n", "`n") -replace "`n", "`r`n"
$license = Get-Content -LiteralPath (Join-Path $root 'LICENSE') -Raw
$notice = $credits.TrimEnd() + "`r`n`r`n" + $license

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Update')
try {
    $creditStream = $zip.CreateEntry('BepInEx/NOTICE-BepInExPack.txt').Open()
    try {
        $creditBytes = [System.Text.Encoding]::UTF8.GetBytes($notice)
        $creditStream.Write($creditBytes, 0, $creditBytes.Length)
    }
    finally { $creditStream.Dispose() }
}
finally { $zip.Dispose() }

Write-Host "pack: $zipPath"

# The optional file is the raw zip of the site: Nexus quarantines an archive inside an archive.
$unityZipPath = Join-Path $OutDir "$($unityLibs.version).zip"
Copy-Item -LiteralPath $unityArchive -Destination $unityZipPath -Force

Write-Host "pack: $unityZipPath"
