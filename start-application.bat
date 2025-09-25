@echo off
echo === Starting TechMart E-Commerce Application ===

echo.
echo 1. Starting PostgreSQL...
net start postgresql-x64-17
if %errorlevel%==0 (echo ✅ PostgreSQL started) else (echo ❌ PostgreSQL failed to start)

echo.
echo 2. Starting IIS...
net start W3SVC
if %errorlevel%==0 (echo ✅ IIS started) else (echo ❌ IIS failed to start)

echo.
echo 3. Checking ports...
netstat -an | findstr ":5432" >nul
if %errorlevel%==0 (echo ✅ PostgreSQL port 5432: Available) else (echo ❌ PostgreSQL port 5432: Not available)

netstat -an | findstr ":80" >nul
if %errorlevel%==0 (echo ✅ IIS port 80: Available) else (echo ❌ IIS port 80: Not available)

echo.
echo 4. Starting Backend API...
echo Opening new window for backend server...
start "Backend Server" cmd /k "cd /d C:\ecommerce\ecommerce-backend && mvn tomcat7:run"

echo.
echo 5. Waiting for backend to start...
timeout /t 10 /nobreak >nul

echo.
echo 6. Testing application...
start http://localhost/ecommerce-ui/

echo.
echo === Startup Complete ===
echo Frontend: http://localhost/ecommerce-ui/
echo Backend:  http://localhost:8080/ecommerce-backend/api/products
echo.
pause
