#!/usr/bin/env pwsh
# Standalone benchmark runner – exports CSV and shows quick summary.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\unlock.ps1"

$aida = Find-AIDA64Exe
if (-not $aida) {
    Write-Error "AIDA64 not found."
    exit 1
}

$csv = Invoke-BenchmarkSuite -AidaPath $aida -ExportCsv
Write-Host "`n📁 Results saved to: $csv" -ForegroundColor Green
Import-Csv $csv | Format-Table -AutoSize
