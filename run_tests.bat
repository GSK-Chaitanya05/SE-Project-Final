@echo off
title DPC - Automated Test Suite
echo ===================================================
echo   Running DPC Automated Backend ^& MongoDB Tests
echo ===================================================
echo.
C:\Python314\python.exe "%~dp0backend\test_api_endpoints.py"
echo.
pause
