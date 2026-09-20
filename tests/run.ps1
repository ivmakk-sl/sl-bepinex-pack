#!/usr/bin/env pwsh
param(
    [switch]$KeepFixtures
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$pin = Get-Content (Join-Path $root 'pack.json') -Raw | ConvertFrom-Json
$verify = Join-Path $root 'verify.ps1'
$fixtureDir = Join-Path $PSScriptRoot 'fixtures'

& (Join-Path $PSScriptRoot 'make-fixtures.ps1') -OutDir $fixtureDir | Out-Null

$cases = @(
    @{ Case = 'baseline'; ShouldPass = $true }
    @{ Case = 'top-folder'; ShouldPass = $false; Rule = 'wrapping top folder' }
    @{ Case = 'bepinex-cfg'; ShouldPass = $false; Rule = 'BepInEx.cfg present' }
    @{ Case = 'changed-byte'; ShouldPass = $false; Rule = 'official entry missing or changed' }
    @{ Case = 'missing-license'; ShouldPass = $false; Rule = 'notice file missing' }
    @{ Case = 'plugin-file'; ShouldPass = $false; Rule = 'plugins or patchers folder not empty' }
    @{ Case = 'dropped-plugins-dir'; ShouldPass = $false; Rule = 'plugins or patchers folder missing' }
)

$failed = 0
foreach ($c in $cases) {
    $zip = Join-Path $fixtureDir "BepInExPack_SurvivalLog-$($pin.build)_$($c.Case).zip"
    $out = (& pwsh -NoProfile -File $verify $zip 2>&1 | Out-String)
    $code = $LASTEXITCODE
    $problems = @()
    if ($c.ShouldPass) {
        if ($code -ne 0) { $problems += "expected exit 0, got $code" }
    }
    else {
        if ($code -eq 0) { $problems += 'expected a non-zero exit' }
        if ($out -notmatch [regex]::Escape("[$($c.Rule)]")) { $problems += "message does not name the rule '$($c.Rule)'" }
    }
    if ($problems.Count -gt 0) {
        $failed++
        Write-Host "FAIL $($c.Case): $($problems -join '; ')"
        Write-Host $out.Trim()
    }
    else {
        Write-Host "ok   $($c.Case)"
    }
}

$builtDir = Join-Path $fixtureDir 'built'
$out = (& pwsh -NoProfile -File (Join-Path $root 'pack.ps1') -OutDir $builtDir 2>&1 | Out-String)
$problems = @()
if ($LASTEXITCODE -ne 0) { $problems += "pack build failed: $out" }
else {
    $builtZip = Join-Path $builtDir "BepInExPack_SurvivalLog-$($pin.build).zip"
    $archive = [IO.Compression.ZipFile]::OpenRead($builtZip)
    try {
        $entry = $archive.GetEntry('BepInEx/NOTICE-BepInExPack.txt')
        if (-not $entry) { $problems += 'combined notice is missing' }
        else {
            $reader = [IO.StreamReader]::new($entry.Open())
            try { $notice = $reader.ReadToEnd() } finally { $reader.Dispose() }
            $license = Get-Content -LiteralPath (Join-Path $root 'LICENSE') -Raw
            if (-not $notice.EndsWith($license)) { $problems += 'full license text was not preserved' }
            foreach ($token in 'build', 'commit', 'archive', 'sha256', 'url') {
                if (-not $notice.Contains([string]$pin.$token)) { $problems += "notice lacks $token" }
            }
            if ($notice.Contains('{{')) { $problems += 'notice has unresolved template tokens' }
        }
        $actualRoots = @($archive.Entries | ForEach-Object { ($_.FullName -split '/')[0] } | Sort-Object -Unique)
        $expectedRoots = @('.doorstop_version', 'BepInEx', 'changelog.txt', 'doorstop_config.ini', 'dotnet', 'winhttp.dll')
        if (Compare-Object $expectedRoots $actualRoots) { $problems += 'pack adds or removes root entries' }
    }
    finally { $archive.Dispose() }
    $out = (& pwsh -NoProfile -File $verify $builtZip 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0) { $problems += "built pack verification failed: $out" }
}
if ($problems.Count -gt 0) {
    $failed++
    Write-Host "FAIL built-notice: $($problems -join '; ')"
}
else { Write-Host 'ok   built-notice' }

$mismatchDir = Join-Path $fixtureDir 'hash-mismatch'
$mismatchOut = Join-Path $mismatchDir 'dist'
New-Item -ItemType Directory -Force -Path $mismatchDir | Out-Null
$wrongHash = '0' * 64
$badPinFile = Join-Path $mismatchDir 'pack.json'
$badPin = Get-Content (Join-Path $root 'pack.json') -Raw | ConvertFrom-Json
$badPin.sha256 = $wrongHash
$badPin | ConvertTo-Json | Set-Content -LiteralPath $badPinFile
$out = (& pwsh -NoProfile -File (Join-Path $root 'pack.ps1') -PinFile $badPinFile -OutDir $mismatchOut 2>&1 | Out-String)
$code = $LASTEXITCODE
$problems = @()
if ($code -eq 0) { $problems += 'expected a non-zero exit' }
if ($out -notmatch [regex]::Escape($wrongHash)) { $problems += 'message does not name the expected hash' }
if ($out -notmatch [regex]::Escape($pin.sha256)) { $problems += 'message does not name the actual hash' }
if (Test-Path -LiteralPath $mismatchOut) {
    if (@(Get-ChildItem -LiteralPath $mismatchOut -Filter *.zip).Count -gt 0) { $problems += 'a zip was produced' }
}
if ($problems.Count -gt 0) {
    $failed++
    Write-Host "FAIL hash-mismatch: $($problems -join '; ')"
    Write-Host $out.Trim()
}
else {
    Write-Host 'ok   hash-mismatch'
}

if (-not $KeepFixtures) {
    $resolvedFixtures = [IO.Path]::GetFullPath($fixtureDir)
    $expectedFixtures = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'fixtures'))
    if ($resolvedFixtures -ne $expectedFixtures) { throw "unexpected fixture directory: $resolvedFixtures" }
    Remove-Item -LiteralPath $resolvedFixtures -Recurse -Force
}

if ($failed -gt 0) {
    Write-Host "tests: FAILED ($failed)"
    exit 1
}
Write-Host "tests: PASSED ($($cases.Count + 2) cases)"
exit 0
