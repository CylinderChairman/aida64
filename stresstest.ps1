#!/usr/bin/env pwsh
# Generate HTML system report using AIDA64's built-in report feature.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\unlock.ps1"

$aida = Find-AIDA64Exe
if (-not $aida) {
    Write-Error "AIDA64 not found."
    exit 1
}

$outFile = "$env:USERPROFILE\Desktop\system_report.html"
& $aida /REPORT HTML /CUSTOM /SAFE /XMLSTDERR /REPORTFILE "$outFile"
Write-Host "📄 System report generated: $outFile" -ForegroundColor Green
