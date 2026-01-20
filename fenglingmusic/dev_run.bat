@echo off
REM Quick development run script with hot reload
REM This is the FASTEST way to develop - supports hot reload!

echo ========================================
echo FengLing Music - Development Mode
echo ========================================
echo.
echo Starting in development mode with hot reload...
echo Press 'r' to hot reload, 'R' to hot restart, 'q' to quit
echo.

REM Run in debug mode with hot reload enabled
REM This is much faster than full rebuilds
call flutter run -d windows --fast-start

if %errorlevel% neq 0 (
    echo Failed to start development mode!
    exit /b %errorlevel%
)
