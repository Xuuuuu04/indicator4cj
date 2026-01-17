@echo off
REM Indicator4CJ Test Runner
REM This script ensures tests run in a clean environment

REM Set terminal width to avoid IllegalArgumentException
set COLUMNS=120

REM Set terminal type
set TERM=xterm-256color

REM Change to script directory
cd /d "%~dp0"

echo ========================================
echo Running Indicator4CJ Test Suite
echo ========================================
echo.

REM Run tests
cjpm test

REM Check exit code
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo All tests passed successfully!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Tests failed with exit code: %ERRORLEVEL%
    echo ========================================
    exit /b %ERRORLEVEL%
)
