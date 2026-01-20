@echo off
REM Fast Windows Build Script for FengLing Music
REM This script optimizes the build process for faster iteration during development

echo ========================================
echo FengLing Music - Fast Windows Build
echo ========================================
echo.

REM Clean build cache for fresh start (optional - comment out if not needed)
REM flutter clean

echo [1/4] Running code generation (incremental)...
REM Use --delete-conflicting-outputs for faster incremental builds
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo Code generation failed!
    exit /b %errorlevel%
)

echo.
echo [2/4] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Dependency fetch failed!
    exit /b %errorlevel%
)

echo.
echo [3/4] Building Windows application (Profile mode for better performance)...
REM Use profile mode for faster builds with reasonable performance
REM Use --no-tree-shake-icons to skip icon tree shaking (faster builds)
call flutter build windows --profile --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo Build failed!
    exit /b %errorlevel%
)

echo.
echo [4/4] Build completed successfully!
echo Output: build\windows\x64\runner\Profile\fenglingmusic.exe
echo.
echo ========================================
echo Tips for even faster builds:
echo 1. Use "flutter run -d windows" for hot reload during development
echo 2. Only run "build_runner" when you change @freezed/@riverpod code
echo 3. Use "--fast-start" flag for quicker startup
echo ========================================
