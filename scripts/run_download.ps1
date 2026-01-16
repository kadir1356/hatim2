# Quick runner script for Quran download
# This will try Python first, then PowerShell

Write-Host "Quran Text Downloader" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is available
$pythonAvailable = $false
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $pythonAvailable = $true
        Write-Host "Python found: $pythonVersion" -ForegroundColor Green
    }
} catch {
    Write-Host "Python not found" -ForegroundColor Yellow
}

# Try Python script first
if ($pythonAvailable) {
    Write-Host "`nTrying Python script..." -ForegroundColor Yellow
    try {
        # Install requests if needed
        python -m pip install requests --quiet 2>&1 | Out-Null
        
        # Run Python script
        python scripts\download_quran.py
        exit 0
    } catch {
        Write-Host "Python script failed, trying PowerShell..." -ForegroundColor Yellow
    }
}

# Fallback to PowerShell
Write-Host "`nUsing PowerShell script..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File scripts\download_quran.ps1
