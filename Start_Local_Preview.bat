@echo off
setlocal
cd /d "%~dp0"
set "PORT=4174"

where python >nul 2>nul
if errorlevel 1 (
  echo Python was not found. Install Python or run a local static server from this folder.
  pause
  exit /b 1
)

echo Starting SwipingDeath local preview...
echo.
echo Open this URL if the browser does not open automatically:
echo http://127.0.0.1:%PORT%/index.html
echo.
start "" "http://127.0.0.1:%PORT%/index.html"
python -m http.server %PORT% --bind 127.0.0.1 --directory "%CD%"
