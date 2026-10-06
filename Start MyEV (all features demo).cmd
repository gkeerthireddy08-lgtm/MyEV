@echo off
title MyEV - all features demo (stand-in services)
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo  Node.js is not installed. Install the LTS version from https://nodejs.org then run this again.
  pause
  exit /b 1
)
echo  Starting MyEV with stand-ins for Claude, Open Charge Map, Google and OpenWeather.
echo  These are NOT the real services. Use "Start MyEV.cmd" with your keys for the real thing.
echo  The app will open at http://localhost:8080 . Close this window to stop.
echo.
start "" /b cmd /c "ping -n 4 127.0.0.1 >nul & start http://localhost:8080"
node --disable-warning=ExperimentalWarning tools\full-stack-demo.js
pause
