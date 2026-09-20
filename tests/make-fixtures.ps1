#!/usr/bin/env pwsh
param(
    [string]$OutDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $PSScriptRoot
$pin = Get-Content (Join-Path $root 'pack.json') -Raw | ConvertFrom-Json
$archive = Join-Path $root "cache/$($pin.archive)"

if (-not $OutDir) { $OutDir = Join-Path $PSScriptRoot 'fixtures' }
if (-not (Test-Path -LiteralPath $archive)) { throw "official archive not found: $archive" }
if (Test-Path -LiteralPath $OutDir) { throw "fixture directory already exists: $OutDir" }
New-Item -ItemType Directory -Path $OutDir | Out-Null

function Fixture([string]$case) { Join-Path $OutDir "BepInExPack_SurvivalLog-$($pin.build)_$case.zip" }

function Set-TextEntry([string]$zipPath, [string]$name, [string]$text) {
    $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Update')
    try {
        $old = $zip.GetEntry($name)
        if ($old) { $old.Delete() }
        $stream = $zip.CreateEntry($name).Open()
        try {
            $writer = New-Object System.IO.StreamWriter($stream)
            $writer.Write($text)
            $writer.Flush()
            $writer.Dispose()
        }
        finally { $stream.Dispose() }
    }
    finally { $zip.Dispose() }
}

function Remove-ZipEntry([string]$zipPath, [string]$name) {
    $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Update')
    try {
        $entry = $zip.GetEntry($name)
        if (-not $entry) { throw "entry not found in $zipPath : $name" }
        $entry.Delete()
    }
    finally { $zip.Dispose() }
}

function Edit-OneByte([string]$zipPath, [string]$name) {
    $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Update')
    try {
        $entry = $zip.GetEntry($name)
        if (-not $entry) { throw "entry not found in $zipPath : $name" }
        $buffer = New-Object System.IO.MemoryStream
        $read = $entry.Open()
        try { $read.CopyTo($buffer) } finally { $read.Dispose() }
        $bytes = $buffer.ToArray()
        $bytes[$bytes.Length - 1] = $bytes[$bytes.Length - 1] -bxor 0xFF
        $entry.Delete()
        $write = $zip.CreateEntry($name).Open()
        try { $write.Write($bytes, 0, $bytes.Length) } finally { $write.Dispose() }
    }
    finally { $zip.Dispose() }
}

$baseline = Fixture 'baseline'
Copy-Item -LiteralPath $archive -Destination $baseline
Set-TextEntry $baseline 'BepInEx/NOTICE-BepInExPack.txt' "placeholder credits and license`n"

$topFolder = Fixture 'top-folder'
$src = [System.IO.Compression.ZipFile]::OpenRead($baseline)
try {
    $dst = [System.IO.Compression.ZipFile]::Open($topFolder, 'Create')
    try {
        foreach ($e in $src.Entries) {
            $copy = $dst.CreateEntry("BepInExPack/$($e.FullName)", [System.IO.Compression.CompressionLevel]::NoCompression)
            if (-not $e.FullName.EndsWith('/')) {
                $read = $e.Open()
                $write = $copy.Open()
                try { $read.CopyTo($write) } finally { $write.Dispose(); $read.Dispose() }
            }
        }
    }
    finally { $dst.Dispose() }
}
finally { $src.Dispose() }

$cfg = Fixture 'bepinex-cfg'
Copy-Item -LiteralPath $baseline -Destination $cfg
Set-TextEntry $cfg 'BepInEx/config/BepInEx.cfg' "[Logging.Console]`nEnabled = true`n"

$changedByte = Fixture 'changed-byte'
Copy-Item -LiteralPath $baseline -Destination $changedByte
Edit-OneByte $changedByte 'BepInEx/core/BepInEx.Core.dll'

$missingLicense = Fixture 'missing-license'
Copy-Item -LiteralPath $baseline -Destination $missingLicense
Remove-ZipEntry $missingLicense 'BepInEx/NOTICE-BepInExPack.txt'

$pluginFile = Fixture 'plugin-file'
Copy-Item -LiteralPath $baseline -Destination $pluginFile
Set-TextEntry $pluginFile 'BepInEx/plugins/SomePlugin.dll' "not a plugin`n"

$droppedPluginsDir = Fixture 'dropped-plugins-dir'
Copy-Item -LiteralPath $baseline -Destination $droppedPluginsDir
Remove-ZipEntry $droppedPluginsDir 'BepInEx/plugins/'

Get-ChildItem -LiteralPath $OutDir -Filter *.zip | ForEach-Object { Write-Host "fixture: $($_.Name)" }
