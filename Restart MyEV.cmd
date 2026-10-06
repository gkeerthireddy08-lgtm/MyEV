@echo off
cd /d "%~dp0"
echo  Stopping the MyEV server that is using port 8080 (if any)...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /c:":8080 " ^| findstr LISTENING') do taskkill /PID %%p /FI "IMAGENAME eq node.exe" /F >nul 2>nul
ping -n 3 127.0.0.1 >nul
call "Start MyEV.cmd"
