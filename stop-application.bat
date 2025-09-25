@echo off
echo === Stopping TechMart E-Commerce Application ===

echo.
echo 1. Stopping Backend (Java processes)...
taskkill /f /im java.exe >nul 2>&1
if %errorlevel%==0 (echo ✅ Backend stopped) else (echo ⚠️ No Java processes found)

echo.
echo 2. Stopping PostgreSQL...
net stop postgresql-x64-17
if %errorlevel%==0 (echo ✅ PostgreSQL stopped) else (echo ⚠️ PostgreSQL stop failed)

echo.
echo 3. Stopping IIS (optional)...
iisreset /stop
if %errorlevel%==0 (echo ✅ IIS stopped) else (echo ⚠️ IIS stop failed)

echo.
echo === Shutdown Complete ===
pause
