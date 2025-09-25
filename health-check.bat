@echo off
echo === TechMart Health Check ===

echo.
echo Checking PostgreSQL...
sc query postgresql-x64-17 | findstr "RUNNING" >nul
if %errorlevel%==0 (echo ✅ PostgreSQL: Running) else (echo ❌ PostgreSQL: Not running)

echo Checking IIS...
sc query W3SVC | findstr "RUNNING" >nul
if %errorlevel%==0 (echo ✅ IIS: Running) else (echo ❌ IIS: Not running)

echo Checking Backend API...
netstat -an | findstr ":8080" >nul
if %errorlevel%==0 (echo ✅ Backend API: Port 8080 in use) else (echo ❌ Backend API: Port 8080 not in use)

echo.
echo Testing API endpoints...
curl -s http://localhost:8080/ecommerce-backend/api/products >nul 2>&1
if %errorlevel%==0 (echo ✅ Products API: Responding) else (echo ❌ Products API: Not responding)

curl -s http://localhost/ecommerce-ui/ >nul 2>&1
if %errorlevel%==0 (echo ✅ Frontend: Responding) else (echo ❌ Frontend: Not responding)

echo.
echo === Health Check Complete ===
pause
