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
$archive = Join-Path $cacheDir $pin.archive

if (-not (Test-Path -LiteralPath $archive)) {
    New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
    Write-Host "downloading $($pin.url)"
    Invoke-WebRequest -Uri $pin.url -OutFile $archive
}

$actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
if ($actual -ne $pin.sha256.ToUpperInvariant()) {
    Write-Host "pack: SHA-256 mismatch for $archive"
    Write-Host "  expected $($pin.sha256.ToUpperInvariant())"
    Write-Host "  actual   $actual"
    exit 1
}

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
