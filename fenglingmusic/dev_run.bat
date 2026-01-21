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

REM Performance optimization flags:
REM --fast-start: Skip unnecessary checks for faster startup
REM --start-paused: Optional - start paused for faster initial launch
REM --enable-software-rendering: Use if GPU issues occur
REM --verbose-system-logs: Disable for less console noise (commented out)

REM Run in debug mode with hot reload enabled and performance optimizations
REM This is much faster than full rebuilds
call flutter run -d windows --fast-start --device-timeout=10

if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo Failed to start development mode!
    echo ========================================
    echo.
    echo Troubleshooting tips:
    echo 1. Run "flutter doctor" to check your setup
    echo 2. Run "flutter pub get" to ensure dependencies are installed
    echo 3. Run "flutter clean" if you encounter build issues
    echo 4. Check that no other instance is running
    echo.
    pause
    exit /b %errorlevel%
)
