@echo off
setlocal enabledelayedexpansion
title DPC - Drug Price Comparison & Safety Network

echo ===================================================================
echo   DPC Platform: Drug Price Comparison & Healthcare Assistant
echo ===================================================================
echo.

:: Detect Python
set "PYTHON_EXE="
if exist "C:\Python314\python.exe" (
    set "PYTHON_EXE=C:\Python314\python.exe"
) else (
    for /f "tokens=*" %%i in ('where python 2^>nul') do (
        if not defined PYTHON_EXE set "PYTHON_EXE=%%i"
    )
)

if not defined PYTHON_EXE (
    echo [ERROR] Python was not found on your system!
    echo Please install Python 3.10+ or add it to your PATH.
    pause
    exit /b 1
)

echo [OK] Using Python: %PYTHON_EXE%
echo [INFO] Project directory: %~dp0
echo.

:: Check Django module
"%PYTHON_EXE%" -c "import django" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Django is not installed in %PYTHON_EXE%.
    echo Installing dependencies now...
    "%PYTHON_EXE%" -m pip install django pymongo django-cors-headers pypdf
)

echo [OK] Dependencies verified.
echo.
echo ===================================================================
echo   Starting Django Server at: http://127.0.0.1:8000/
echo   Press CTRL+C anytime in this window to stop the server.
echo ===================================================================
echo.

:: Automatically open browser after 2 seconds
start "" /b cmd /c "timeout /t 2 /nobreak >nul & start http://127.0.0.1:8000/"

:: Launch Django server
"%PYTHON_EXE%" "%~dp0backend\manage.py" runserver 127.0.0.1:8000

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Django server exited with error code %errorlevel%.
    pause
)
