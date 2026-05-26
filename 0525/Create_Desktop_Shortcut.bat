@echo off
setlocal

set "PROJECT_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%tools\create_shortcut.ps1" -ProjectDir "%PROJECT_DIR%"

endlocal

