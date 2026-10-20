# Creates a Startup-folder shortcut pointing to start-all.bat next to this script.
# Run: right-click install-autostart.bat -> Run as administrator is NOT required.
$ErrorActionPreference = 'Stop'
$startup = [Environment]::GetFolderPath('Startup')
$lnkPath = Join-Path $startup 'QQ Farm Bot.lnk'
$target = Join-Path $PSScriptRoot 'start-all.bat'
if (-not (Test-Path $target)) {
    Write-Error "start-all.bat not found next to this script: $target"
    exit 1
}
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)
$shortcut.TargetPath = $target
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.Description = 'QQ Farm Bot + NapCat auto startup'
$shortcut.Save()
Write-Host "Startup shortcut created:"
Write-Host "  $lnkPath"
Write-Host "It will run automatically at next logon."
