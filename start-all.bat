@echo off
rem ============================================================
rem QQ Farm Bot one-click startup: NapCat first, then Farm Bot.
rem Place this file in the PARENT folder of qq-farm-bot, e.g.:
rem   D:\bots\
rem     start-all.bat          <-- this file
rem     qq-farm-bot\            <-- cloned repo
rem     napcat-shell\          <-- extracted NapCat.Shell (with start-napcat.bat)
rem ============================================================
setlocal EnableExtensions
cd /d "%~dp0" || exit /b 1

if not exist "qq-farm-bot\start.bat" (
    echo [ERROR] qq-farm-bot\start.bat not found.
    echo [HINT] Put this script in the parent folder of qq-farm-bot.
    pause
    exit /b 1
)
if not exist "napcat-shell\start-napcat.bat" (
    echo [ERROR] napcat-shell\start-napcat.bat not found.
    echo [HINT] Copy napcat\start-napcat.bat from this kit into your NapCat folder,
    echo        and rename that folder to napcat-shell (or edit this script).
    pause
    exit /b 1
)

echo [1/2] Starting NapCat (do NOT close its window) ...
start "" "%cd%\napcat-shell\start-napcat.bat"
timeout /t 5 /nobreak >nul
echo [2/2] Starting QQ Farm Bot panel (http://localhost:3007) ...
start "" "%cd%\qq-farm-bot\start.bat"
echo [OK] Both launched.
timeout /t 3 /nobreak >nul
exit /b 0
