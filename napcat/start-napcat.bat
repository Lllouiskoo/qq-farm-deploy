@echo off
rem ============================================================
rem NapCat launcher for QQ Farm Bot
rem Usage: copy this file into your NapCat.Shell extracted folder
rem        (same level as launcher.bat), then double-click it.
rem Prerequisites:
rem   1. NapCat.Shell.zip extracted, QQ NT client installed (>= 9.9.27)
rem   2. qq-miniapp-openauth plugin installed (see README)
rem   3. token set in config/webui.json
rem   4. (optional) same token saved in napcat-token.txt next to this file
rem ============================================================
setlocal DisableDelayedExpansion
cd /d "%~dp0" || exit /b 1
chcp 65001 >nul

rem Optional: pin WebUI token from a local (git-ignored) token file.
rem webui.json remains the source of truth; this only overrides at startup.
if exist "%~dp0napcat-token.txt" (
    for /f "usebackq delims=" %%t in ("%~dp0napcat-token.txt") do set "NAPCAT_WEBUI_SECRET_KEY=%%t"
)

net session >nul 2>&1
if not errorlevel 1 goto :napcat_admin
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0launcher-elevate.ps1" wt.exe "%~f0" %*
exit /b %ERRORLEVEL%

:napcat_admin
echo [NapCat] Administrator mode detected.
echo [NapCat] WebUI: http://127.0.0.1:6099/webui

set "NAPCAT_PATCH_PACKAGE=%cd%\qqnt.json"
set "NAPCAT_LOAD_PATH=%cd%\loadNapCat.js"
set "NAPCAT_INJECT_PATH=%cd%\NapCatWinBootHook.dll"
set "NAPCAT_LAUNCHER_PATH=%cd%\NapCatWinBootMain.exe"
set "NAPCAT_MAIN_PATH=%cd%\napcat.mjs"
set "RetString="
for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\QQ" /v "UninstallString"') do (
    set "RetString=%%~b"
    goto :napcat_boot
)
echo QQ installation was not found in the registry.
pause
exit /b 1

:napcat_boot
for %%a in ("%RetString%") do (
    set "pathWithoutUninstall=%%~dpa"
)

set "QQPath=%pathWithoutUninstall%QQ.exe"

if not exist "%QQPath%" (
    echo provided QQ path is invalid
    pause
    exit /b 1
)

"%NAPCAT_LAUNCHER_PATH%" "%QQPath%" "%NAPCAT_INJECT_PATH%" %*
set "napcat_exit_code=%ERRORLEVEL%"
pause
exit /b %napcat_exit_code%
