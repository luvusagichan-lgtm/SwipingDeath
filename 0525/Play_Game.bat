@echo off
setlocal

set "PROJECT_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%tools\play_game.ps1" -ProjectDir "%PROJECT_DIR%"
if errorlevel 1 (
    echo.
    echo Could not start the game. See launch_log.txt in this folder.
    echo.
    pause
)

endlocal
