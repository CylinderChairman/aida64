#!/usr/bin/env pwsh
<#
.SYNOPSIS
    One-command installer for AIDA64 Extreme Unlocker toolkit.
.DESCRIPTION
    Installs AIDA64 Extreme (via winget), downloads helper scripts,
    adds desktop shortcuts, and sets up the environment.
.NOTES
    Run as administrator for best results.
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"
$repoRaw = "https://raw.githubusercontent.com/CylinderChairman/aida64/main"

Write-Host "🚀 AIDA64 Extreme Unlocker – Setup" -ForegroundColor Cyan

# 1. Install winget if not present
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Installing winget (App Installer)..." -ForegroundColor Yellow
    & "$env:SystemRoot\System32\msiexec.exe" /i "https://aka.ms/getwinget" /quiet /norestart
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 2. Install AIDA64 Extreme (official)
Write-Host "🔧 Installing AIDA64 Extreme (official trial)..." -ForegroundColor Yellow
winget install --id FinalWire.AIDA64.Extreme --silent --accept-package-agreements --accept-source-agreements
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ winget installation failed. Download manually from https://www.aida64.com/downloads" -ForegroundColor Red
    exit 1
}

# 3. Locate AIDA64 install path
$regPath = "HKLM:\SOFTWARE\WOW6432Node\FinalWire\AIDA64"
if (Test-Path $regPath) {
    $aidaPath = (Get-ItemProperty -Path $regPath -Name "Install_Dir" -ErrorAction SilentlyContinue).Install_Dir
}
if (-not $aidaPath) {
    $aidaPath = "${env:ProgramFiles(x86)}\FinalWire\AIDA64 Extreme"
}
if (-not (Test-Path "$aidaPath\aida64.exe")) {
    Write-Host "❌ Could not locate aida64.exe. Reinstall manually." -ForegroundColor Red
    exit 1
}
Write-Host "✅ AIDA64 found at $aidaPath" -ForegroundColor Green

# 4. Create our scripts folder
$scriptsDir = "$env:USERPROFILE\.aida64-unlocker"
New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null
$scriptsSubDir = "$scriptsDir\scripts"
$configDir = "$scriptsDir\config"
New-Item -ItemType Directory -Force -Path $scriptsSubDir | Out-Null
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

# 5. Download all scripts from repo
$files = @(
    @{url = "$repoRaw/scripts/unlock.ps1"; dest = "$scriptsSubDir\unlock.ps1"},
    @{url = "$repoRaw/scripts/benchmark.ps1"; dest = "$scriptsSubDir\benchmark.ps1"},
    @{url = "$repoRaw/scripts/stresstest.ps1"; dest = "$scriptsSubDir\stresstest.ps1"},
    @{url = "$repoRaw/scripts/report.ps1"; dest = "$scriptsSubDir\report.ps1"},
    @{url = "$repoRaw/config/settings.json"; dest = "$configDir\settings.json"}
)

foreach ($f in $files) {
    Write-Host "⬇️  Downloading $($f.url)" -ForegroundColor DarkCyan
    Invoke-WebRequest -Uri $f.url -OutFile $f.dest -UseBasicParsing
}

# 6. Create module stub to expose functions globally
$profileScript = @"
# AIDA64 Unlocker Module
`$aidaPath = "$aidaPath"
`$scriptsDir = "$scriptsSubDir"

. `$scriptsDir\unlock.ps1
. `$scriptsDir\benchmark.ps1
. `$scriptsDir\stresstest.ps1
. `$scriptsDir\report.ps1

function Unlock-AIDA64 {
    param([switch]`$Full)
    Unlock-Performance -ApplyTweaks -RunBenchmarks -RunStressTest:(`$Full)
}
"@
$profilePath = "$scriptsDir\AIDA64Unlocker.psm1"
$profileScript | Out-File -FilePath $profilePath -Encoding utf8

# 7. Add to PowerShell profile (optional)
$userProfile = $PROFILE.CurrentUserCurrentHost
if (-not (Test-Path $userProfile)) { New-Item -Path $userProfile -ItemType File -Force | Out-Null }
$importLine = "Import-Module `"$profilePath`" -Force"
if ((Get-Content $userProfile -Raw) -notmatch [regex]::Escape($importLine)) {
    Add-Content -Path $userProfile -Value "`n$importLine"
    Write-Host "✅ Added module to your PowerShell profile" -ForegroundColor Green
}

# 8. Create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\AIDA64 Unlocker.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoExit -Command `"Import-Module '$profilePath'; Unlock-AIDA64 -Full`""
$shortcut.IconLocation = "$aidaPath\aida64.exe,0"
$shortcut.Save()
Write-Host "🖥️  Desktop shortcut created" -ForegroundColor Green

Write-Host "`n🎉 Installation complete!" -ForegroundColor Green
Write-Host "👉 Run 'Unlock-AIDA64 -Full' in any PowerShell to unleash your system." -ForegroundColor Yellow
Write-Host "👉 Or double-click the desktop shortcut." -ForegroundColor Yellow
