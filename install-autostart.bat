@echo off
rem Creates a Startup shortcut for start-all.bat (auto-run at logon).
rem Run this once. Safe to re-run; it overwrites the existing shortcut.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-autostart.ps1"
pause
