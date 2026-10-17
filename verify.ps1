#!/usr/bin/env pwsh
param(
    [string]$PackZip,
    [string]$OfficialArchive,
    [string]$UnityLibsZip
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = $PSScriptRoot
$pin = Get-Content (Join-Path $root 'pack.json') -Raw | ConvertFrom-Json

# The optional file is checked when it is named, or in a call with no arguments (the whole dist/ folder).
$checkUnityLibs = [bool]$UnityLibsZip -or $PSBoundParameters.Count -eq 0
if (-not $UnityLibsZip) { $UnityLibsZip = Join-Path $root "dist/UnityLibs_SurvivalLog-$($pin.unityLibs.version).zip" }
if (-not $PackZip) { $PackZip = Join-Path $root "dist/BepInExPack_SurvivalLog-$($pin.build).zip" }
if (-not $OfficialArchive) { $OfficialArchive = Join-Path $root "cache/$($pin.archive)" }

$required = @($PackZip, $OfficialArchive)
if ($checkUnityLibs) { $required += $UnityLibsZip }
foreach ($p in $required) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Host "verify: file not found: $p"
        exit 2
    }
}

$addedFiles = @('BepInEx/NOTICE-BepInExPack.txt')
$excludedPrefixes = @('BepInEx/interop', 'BepInEx/unity-libs')
$emptyDirs = @('BepInEx/plugins/', 'BepInEx/patchers/')

function Read-Entries([string]$path) {
    $map = [ordered]@{}
    $zip = [System.IO.Compression.ZipFile]::OpenRead($path)
    try {
        foreach ($e in $zip.Entries) {
            $name = $e.FullName.Replace('\', '/')
            $isDir = $name.EndsWith('/')
            $hash = ''
            if (-not $isDir) {
                $s = $e.Open()
                try { $hash = [BitConverter]::ToString([System.Security.Cryptography.SHA256]::HashData($s)).Replace('-', '') }
                finally { $s.Dispose() }
            }
            $map[$name] = [pscustomobject]@{ IsDir = $isDir; Length = $e.Length; Hash = $hash }
        }
    }
    finally { $zip.Dispose() }
    return $map
}

$failures = [System.Collections.Generic.List[string]]::new()
function Add-Failure([string]$rule, [string]$detail) {
    $script:failures.Add("FAIL [$rule] $detail")
}

$official = Read-Entries $OfficialArchive
$pack = Read-Entries $PackZip

foreach ($name in $official.Keys) {
    if (-not $pack.Contains($name)) {
        Add-Failure 'official entry missing or changed' "$name is not in the pack"
        continue
    }
    $o = $official[$name]
    $p = $pack[$name]
    if ($o.IsDir -ne $p.IsDir) {
        Add-Failure 'official entry missing or changed' "$name is a directory entry in one zip and a file in the other"
    }
    elseif (-not $o.IsDir -and ($o.Length -ne $p.Length -or $o.Hash -ne $p.Hash)) {
        Add-Failure 'official entry missing or changed' "$name content differs from the official archive"
    }
}

foreach ($f in $addedFiles) {
    if (-not $pack.Contains($f)) { Add-Failure 'notice file missing' "$f is not in the pack" }
}

foreach ($name in $pack.Keys) {
    if (-not $official.Contains($name) -and $addedFiles -notcontains $name) {
        Add-Failure 'unexpected extra entry' "$name is in neither the official archive nor the allowed additions"
    }
}

foreach ($d in $emptyDirs) {
    if (-not $pack.Contains($d)) { Add-Failure 'plugins or patchers folder missing' "$d is not in the pack" }
    foreach ($name in $pack.Keys) {
        if ($name -ne $d -and $name.StartsWith($d)) {
            Add-Failure 'plugins or patchers folder not empty' "$name is under $d"
        }
    }
}

foreach ($name in $pack.Keys) {
    if (($name -split '/')[-1] -eq 'BepInEx.cfg') { Add-Failure 'BepInEx.cfg present' "$name is in the pack" }
    foreach ($prefix in $excludedPrefixes) {
        if ($name.StartsWith($prefix)) { Add-Failure 'excluded path present' "$name is under $prefix" }
    }
}

$topSegments = @($pack.Keys | ForEach-Object { ($_ -split '/')[0] } | Sort-Object -Unique)
if ($topSegments.Count -eq 1) {
    Add-Failure 'wrapping top folder' "every entry is under $($topSegments[0])/, so the zip does not extract into the game folder"
}

$zipName = Split-Path -Leaf $PackZip
if ($zipName -notlike "*$($pin.build)*") {
    Add-Failure 'zip name missing build identifier' "$zipName does not carry the build $($pin.build)"
}

if ($checkUnityLibs) {
    $unityVersion = $pin.unityLibs.version
    $unityEntry = "BepInEx/unity-libs/$unityVersion.zip"
    $unity = Read-Entries $UnityLibsZip
    if ($unity.Count -gt 1) {
        Add-Failure 'optional file has more than one entry' "$($unity.Keys -join ', ')"
    }
    if (-not $unity.Contains($unityEntry)) {
        Add-Failure 'optional file entry path' "$unityEntry is not in the optional file"
    }
    elseif ($unity[$unityEntry].Hash -ne $pin.unityLibs.sha256.ToUpperInvariant()) {
        Add-Failure 'optional file entry changed' "$unityEntry has SHA-256 $($unity[$unityEntry].Hash), the pin is $($pin.unityLibs.sha256)"
    }
    $unityName = Split-Path -Leaf $UnityLibsZip
    if ($unityName -notlike "*$unityVersion*") {
        Add-Failure 'optional file name missing Unity version' "$unityName does not carry the Unity version $unityVersion"
    }
}

Write-Host "pack:     $PackZip"
Write-Host "official: $OfficialArchive"
if ($checkUnityLibs) { Write-Host "optional: $UnityLibsZip" }

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host $_ }
    $brokenRules = $failures | ForEach-Object { ($_ -replace '^FAIL \[([^\]]+)\].*$', '$1') } | Sort-Object -Unique
    Write-Host "verify: FAILED, broken rules: $($brokenRules -join ', ')"
    exit 1
}

Write-Host "verify: PASSED"
exit 0
