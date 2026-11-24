@echo off
setlocal enabledelayedexpansion

echo ===================================================================
echo     DPC DRUG PRICE COMPARISON - APACHE JMETER LOAD TESTING
echo ===================================================================

set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot"
set "PATH=%JAVA_HOME%\bin;C:\Program Files\apache-jmeter-5.6.3\apache-jmeter-5.6.3\bin;C:\Windows\System32;%PATH%"

set "JMETER_BAT=C:\Program Files\apache-jmeter-5.6.3\apache-jmeter-5.6.3\bin\jmeter.bat"
set "JMX_FILE=%~dp0tests\load_testing\dpc_load_test_plan.jmx"
set "REPORT_DIR=%~dp0docs\load_test_report"
set "RESULTS_JTL=%~dp0tests\load_testing\load_test_results.jtl"

echo [1/3] Verifying JMeter and Java installation...
if not exist "%JMETER_BAT%" (
    echo [ERROR] Could not find jmeter.bat at "%JMETER_BAT%".
    pause
    exit /b 1
)

echo [2/3] Checking if Django backend server is running on http://127.0.0.1:8000/ ...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/api/health/' -TimeoutSec 2 -UseBasicParsing; exit 0 } catch { exit 1 }"
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Django server is not currently reachable on http://127.0.0.1:8000/.
    echo Starting server in a new window...
    start "DPC Django Server" run_server.bat
    timeout /t 3 /nobreak >nul
)

echo.
echo Select Load Test Scenario:
echo   [1] Smoke Test           (5 users, 2 loops - ~130 requests)
echo   [2] Standard Load Test   (50 users, 10 loops - ~6,500 requests)
echo   [3] High Concurrency     (200 users, 5 loops - ~13,000 requests)
echo   [4] Peak SRS NFR-1.1     (500 users, 3 loops - ~19,500 requests)
echo.
set /p TIER="Enter choice [1-4, default=2]: "
if "%TIER%"=="" set TIER=2

if "%TIER%"=="1" (
    set THREADS=5
    set LOOPS=2
    set RAMPUP=2
) else if "%TIER%"=="2" (
    set THREADS=50
    set LOOPS=10
    set RAMPUP=5
) else if "%TIER%"=="3" (
    set THREADS=200
    set LOOPS=5
    set RAMPUP=10
) else if "%TIER%"=="4" (
    set THREADS=500
    set LOOPS=3
    set RAMPUP=20
) else (
    set THREADS=50
    set LOOPS=10
    set RAMPUP=5
)

echo.
echo ===================================================================
echo Running JMeter: %THREADS% threads, %LOOPS% loops, %RAMPUP%s ramp-up
echo Test Plan: %JMX_FILE%
echo ===================================================================

if exist "%RESULTS_JTL%" del /f /q "%RESULTS_JTL%"
if exist "%REPORT_DIR%" rd /s /q "%REPORT_DIR%"

call "%JMETER_BAT%" -n -t "%JMX_FILE%" -l "%RESULTS_JTL%" -e -o "%REPORT_DIR%" -Jthreads=%THREADS% -Jloops=%LOOPS% -Jrampup=%RAMPUP%

echo.
echo ===================================================================
echo LOAD TEST COMPLETE!
echo HTML Dashboard Report generated at:
echo   %REPORT_DIR%\index.html
echo ===================================================================
echo.
echo Opening HTML dashboard report in browser...
start "" "%REPORT_DIR%\index.html"
pause
