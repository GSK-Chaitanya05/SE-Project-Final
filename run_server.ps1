# DPC Platform PowerShell Startup Script
$ErrorActionPreference = "Continue"

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  DPC Platform: Drug Price Comparison & Healthcare Assistant" -ForegroundColor Green
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

$pythonExe = "C:\Python314\python.exe"
if (-not (Test-Path $pythonExe)) {
    $pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Source
}

if (-not $pythonExe) {
    Write-Host "[ERROR] Python was not found on your system." -ForegroundColor Red
    pause
    exit
}

Write-Host "[OK] Using Python: $pythonExe" -ForegroundColor Green
Write-Host "[INFO] Opening browser at http://127.0.0.1:8000/ ..." -ForegroundColor Yellow

# Launch browser asynchronously in 2 seconds
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 2
    Start-Process "http://127.0.0.1:8000/"
} | Out-Null

Write-Host "[OK] Starting Django server..." -ForegroundColor Green
$backendPath = Join-Path $PSScriptRoot "backend\manage.py"
& $pythonExe $backendPath runserver 127.0.0.1:8000
