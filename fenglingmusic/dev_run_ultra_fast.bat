@echo off
REM Ultra-Fast Development Script
REM Optimized for maximum development speed - skips all unnecessary checks
REM USE THIS if you're iterating quickly and know your setup is correct

echo ========================================
echo FengLing Music - ULTRA FAST Mode
echo ========================================
echo.
echo WARNING: This script skips dependency and setup checks!
echo Only use if you've already run a full build successfully.
echo.
echo Starting with MAXIMUM performance optimizations...
echo.

REM Ultra-fast flags:
REM --fast-start: Skip unnecessary startup checks
REM --device-timeout=5: Reduce device detection timeout from default 10s to 5s
REM --no-pub: Skip automatic pub get (assumes deps are already installed)
REM --no-build-number: Skip build number validation

REM Set Flutter environment variables for performance
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
set PUB_HOSTED_URL=https://pub.flutter-io.cn

REM Run with all performance optimizations enabled
call flutter run -d windows --fast-start --device-timeout=5 --no-pub

if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo Ultra-fast mode failed!
    echo ========================================
    echo.
    echo This can happen if:
    echo 1. Dependencies are not installed (run: flutter pub get)
    echo 2. Code generation is needed (run: flutter pub run build_runner build)
    echo 3. Project needs a clean build (run: flutter clean)
    echo.
    echo Try using dev_run.bat instead for a safer startup.
    echo.
    pause
    exit /b %errorlevel%
)
