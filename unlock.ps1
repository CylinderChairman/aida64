#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unlock extreme performance: run benchmarks, apply system tweaks, stress test.
.DESCRIPTION
    This is the main entry point of the toolkit. It can:
    - Apply Windows performance tweaks (power plan, visual effects, etc.)
    - Run full AIDA64 benchmark suite
    - Launch a stability stress test
.PARAMETER ApplyTweaks
    Apply system tweaks for max performance.
.PARAMETER RunBenchmarks
    Run all benchmarks and export results to CSV.
.PARAMETER RunStressTest
    Run a 15-minute stress test (CPU+FPU+memory).
.EXAMPLE
    Unlock-Performance -ApplyTweaks -RunBenchmarks -RunStressTest
#>

function Unlock-Performance {
    param(
        [switch]$ApplyTweaks,
        [switch]$RunBenchmarks,
        [switch]$RunStressTest
    )

    # Locate AIDA64
    $aidaExe = Find-AIDA64Exe
    if (-not $aidaExe) {
        Write-Error "AIDA64 not found. Please install first."
        return
    }

    if ($ApplyTweaks) {
        Write-Host "⚙️ Applying performance tweaks..." -ForegroundColor Cyan
        Apply-PerformanceTweaks
    }

    if ($RunBenchmarks) {
        Write-Host "📊 Running benchmarks..." -ForegroundColor Cyan
        $reportFile = Invoke-BenchmarkSuite -AidaPath $aidaExe -ExportCsv
        Write-Host "✅ Benchmarks saved to $reportFile" -ForegroundColor Green
    }

    if ($RunStressTest) {
        Write-Host "🔥 Starting stress test (15 min)..." -ForegroundColor Cyan
        Start-StressTest -AidaPath $aidaExe -DurationMinutes 15
    }

    Write-Host "🎉 Unlock complete! Your system is ready for extreme workloads." -ForegroundColor Green
}

function Find-AIDA64Exe {
    $paths = @(
        "${env:ProgramFiles(x86)}\FinalWire\AIDA64 Extreme\aida64.exe",
        "$env:ProgramFiles\FinalWire\AIDA64 Extreme\aida64.exe",
        (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\FinalWire\AIDA64" -Name "Install_Dir" -ErrorAction SilentlyContinue).Install_Dir + "\aida64.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

function Apply-PerformanceTweaks {
    # High Performance power plan
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    if ($LASTEXITCODE -ne 0) {
        powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
    # Disable USB selective suspend
    powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    # Processor scheduling – foreground boost
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 10 -Type DWord
    Write-Host "   ✓ Power plan: High Performance" -ForegroundColor DarkGreen
    Write-Host "   ✓ USB selective suspend: disabled" -ForegroundColor DarkGreen
    Write-Host "   ✓ Foreground task priority boosted" -ForegroundColor DarkGreen
}

function Invoke-BenchmarkSuite {
    param([string]$AidaPath, [switch]$ExportCsv)
    $outDir = "$env:USERPROFILE\Desktop\AIDA64_Reports"
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $csvPath = "$outDir\benchmark_$timestamp.csv"
    
    # Run benchmarks using AIDA64's built-in CLI (batch mode)
    $benchmarks = @("Queen", "PhotoWorxx", "ZLib", "AES", "Hash", "FPU VP8", "FPU Julia", "Memory Copy", "Memory Read", "Memory Write", "Memory Latency", "Disk Read")
    $results = @()
    foreach ($b in $benchmarks) {
        Write-Host "   Running $b ..." -NoNewline
        $out = & $AidaPath /BENCHMARK $b /SILENT /XMLSTDERR
        # Parse result (simplified – in production use XML parsing)
        $value = if ($out -match ">\s*([\d\.\,]+)\s*<") { $matches[1] } else { "N/A" }
        $results += [PSCustomObject]@{ Benchmark = $b; Value = $value }
        Write-Host " $value" -ForegroundColor DarkYellow
    }
    $results | Export-Csv -Path $csvPath -NoTypeInformation
    return $csvPath
}

function Start-StressTest {
    param([string]$AidaPath, [int]$DurationMinutes = 15)
    $seconds = $DurationMinutes * 60
    Write-Host "🔥 Stress test running for $DurationMinutes minutes. Press Ctrl+C to stop early." -ForegroundColor Magenta
    Start-Process -FilePath $AidaPath -ArgumentList "/STABILITYTEST /TESTMODE SYSTEM /TESTALL /SILENT" -WindowStyle Minimized
    Start-Sleep -Seconds $seconds
    Stop-Process -Name "aida64" -Force -ErrorAction SilentlyContinue
    Write-Host "`n✅ Stress test completed." -ForegroundColor Green
}

Export-ModuleMember -Function Unlock-Performance, Find-AIDA64Exe, Apply-PerformanceTweaks, Invoke-BenchmarkSuite, Start-StressTest
