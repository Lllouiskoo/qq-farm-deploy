@echo off
rem ============================================================
rem Push this kit to your GitHub repository.
rem Steps:
rem   1. Create an EMPTY repo on github.com (no README, no .gitignore)
rem   2. Edit REPO_URL below to your repo address
rem   3. Double-click this script (git will pop up login if needed)
rem ============================================================
set "REPO_URL=https://github.com/Lllouiskoo/qq-farm-deploy.git"

cd /d "%~dp0" || exit /b 1

if not exist ".git" (
    echo [INFO] Initializing local git repository ...
    git init -b main
    git add -A
    git commit -m "QQ Farm Bot Windows deploy kit (NapCat QR login, no Docker)"
)

echo [INFO] Pushing to %REPO_URL% ...
git remote remove origin >nul 2>&1
git remote add origin "%REPO_URL%"
git branch -M main
git push -u origin main
if errorlevel 1 (
    echo [ERROR] Push failed. Check REPO_URL, network and GitHub login.
    pause
    exit /b 1
)
echo [OK] Pushed. See it at your repo page.
pause
