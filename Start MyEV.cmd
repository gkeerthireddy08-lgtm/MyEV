@echo off
title MyEV server
cd /d "%~dp0"
echo.
echo  ============================================
echo   MyEV - starting the server
echo  ============================================
echo.
where node >nul 2>nul
if errorlevel 1 (
  echo  Node.js is not installed on this computer.
  echo  Install the LTS version from https://nodejs.org
  echo  then double-click this file again.
  echo.
  pause
  exit /b 1
)
for /f "delims=" %%v in ('node -v') do set NODEVER=%%v
echo  Node.js %NODEVER% found.
if not exist ".env" (
  copy ".env.example" ".env" >nul
  echo  Created .env from .env.example
)
findstr /r /c:"^NVIDIA_API_KEY=nvapi-" ".env" >nul 2>nul
if errorlevel 1 (
  echo  NOTE: no NVIDIA key in .env yet, so the chatbot uses the simple built-in assistant.
  echo        Put your key after NVIDIA_API_KEY= in .env, save, then double-click Restart MyEV.cmd
  echo.
)
echo  The app will open at http://localhost:8080
echo  Keep this window open while you use MyEV. Close it to stop the server.
echo.
start "" /b cmd /c "ping -n 4 127.0.0.1 >nul & start http://localhost:8080"
node --disable-warning=ExperimentalWarning server\index.js
echo.
echo  The server stopped. See the message above.
pause
