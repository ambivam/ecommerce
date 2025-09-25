# TechMart E-Commerce Application - Complete Setup Guide

## 📋 **Overview**

TechMart is a complete e-commerce application built with:
- **Frontend**: ASP.NET Web Forms (C#) with Bootstrap UI
- **Backend**: Java 8 with JAX-RS REST APIs (Jersey implementation)
- **Application Server**: Apache Tomcat 9.0+ (embedded via Maven)
- **Database**: PostgreSQL 17
- **Authentication**: JWT tokens with BCrypt password hashing
- **Web Server**: IIS (Internet Information Services)

## 🚀 **Quick Start (5 Minutes)**

### **Step 1: Start PostgreSQL Database**
```cmd
# Start PostgreSQL service
net start postgresql-x64-17

# Verify it's running
netstat -an | findstr ":5432"
```

### **Step 2: Start Java Backend**
```cmd
# Navigate to backend directory
cd C:\ecommerce\ecommerce-backend

# Start the backend API server
mvn tomcat7:run

# Wait for this message:
# INFO: Starting ProtocolHandler ["http-bio-8080"]
```

### **Step 3: Verify Backend is Running**
```cmd
# Test the API
curl http://localhost:8080/ecommerce-backend/api/products

# Should return JSON with 7 products
```

### **Step 4: Access the Application**
Open your browser and go to: **`http://localhost/ecommerce-ui/`**

✅ **That's it! Your application is now running.**

---

## 🔧 **Detailed Setup Instructions**

### **Prerequisites**

Ensure you have the following installed and configured:

#### **1. Java 8 JDK**
```cmd
# Download: Oracle JDK 8 or OpenJDK 8
# Verify installation
java -version
javac -version

# Set JAVA_HOME environment variable
setx JAVA_HOME "C:\Program Files\Java\jdk1.8.0_XXX"
setx PATH "%PATH%;%JAVA_HOME%\bin"
```

#### **2. Apache Maven 3.8+**
```cmd
# Download: https://maven.apache.org/download.cgi
# Extract to C:\apache-maven-3.x.x
# Verify installation
mvn -version

# Set Maven environment variables
setx M2_HOME "C:\apache-maven-3.x.x"
setx PATH "%PATH%;%M2_HOME%\bin"
```

#### **3. PostgreSQL 17**
```cmd
# Download: https://www.postgresql.org/download/windows/
# Install with default settings
# Default port: 5432
# Remember your postgres user password

# Verify installation
psql --version

# Test connection
psql -U postgres -h localhost
```

#### **4. IIS (Internet Information Services)**
```cmd
# Enable IIS via Windows Features
# Control Panel > Programs > Turn Windows features on or off
# Check: Internet Information Services
# Check: World Wide Web Services
# Check: Application Development Features > ASP.NET 4.8

# Verify IIS is running
sc query W3SVC

# Start IIS if not running
net start W3SVC
```

### **Database Setup**

#### **1. Start PostgreSQL Service**
```cmd
# Start PostgreSQL service
net start postgresql-x64-17

# Verify service is running
sc query postgresql-x64-17

# Check if PostgreSQL is listening on port 5432
netstat -an | findstr ":5432"
```

#### **2. Create Database and Schema**
```cmd
# Connect to PostgreSQL as superuser
psql -U postgres -h localhost

# Create the ecommerce database
CREATE DATABASE ecommerce;

# Connect to the new database
\c ecommerce

# Run the main schema script
\i C:/ecommerce/database/schema.sql

# Run the cart schema script (for shopping cart functionality)
\i C:/ecommerce/database/cart_schema.sql

# Exit psql
\q
```

#### **3. Grant Database Permissions**
```cmd
# Connect to the ecommerce database
psql -U postgres -h localhost -d ecommerce

# Grant all permissions on all tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

# Specifically grant cart table permissions
GRANT ALL PRIVILEGES ON TABLE cart TO postgres;
GRANT ALL PRIVILEGES ON SEQUENCE cart_id_seq TO postgres;

# Exit psql
\q
```

#### **4. Verify Database Setup**
```sql
# Connect and verify
psql -U postgres -h localhost -d ecommerce

# Check all tables exist
\dt

# Verify sample data
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM categories;

# Test cart table
SELECT * FROM cart LIMIT 5;

# Exit
\q
```

### **Backend Setup (Java + Maven + Tomcat)**

#### **1. Configure Database Connection**
```cmd
# Edit application.properties file
notepad C:\ecommerce\ecommerce-backend\src\main\resources\application.properties
```

Ensure these settings match your PostgreSQL configuration:
```properties
# Database Configuration
db.url=jdbc:postgresql://localhost:5432/ecommerce
db.username=postgres
db.password=your_postgres_password
db.driver=org.postgresql.Driver

# Connection Pool Settings
db.pool.maxPoolSize=10
db.pool.minIdle=2
db.pool.maxLifetime=1800000

# JWT Configuration
jwt.secret=mySecretKey123456789012345678901234567890
jwt.expiration=86400000
jwt.issuer=ecommerce-app
```

#### **2. Resolve Maven Dependencies**
```cmd
cd C:\ecommerce\ecommerce-backend

# Clean any previous builds
mvn clean

# Download and resolve all dependencies
mvn dependency:resolve

# Compile the project
mvn compile

# If compilation fails due to port conflicts, kill existing processes
taskkill /f /im java.exe
```

#### **3. Handle Common Maven Issues**
```cmd
# If you get module-info.class errors (Java 8 compatibility)
# The pom.xml already excludes these files via maven-war-plugin

# If you get "Address already in use" error
netstat -ano | findstr ":8080"
taskkill /PID [process_id] /F

# If Maven cache is corrupted
mvn dependency:purge-local-repository
mvn clean install
```

#### **4. Start Backend Server**
```cmd
cd C:\ecommerce\ecommerce-backend

# Start embedded Tomcat server
mvn tomcat7:run

# Wait for successful startup message:
# INFO: Starting ProtocolHandler ["http-bio-8080"]
# INFO: Server startup in XXXX ms
```

#### **5. Verify Backend APIs**
```cmd
# Test products API
curl http://localhost:8080/ecommerce-backend/api/products

# Test user registration
curl -X POST http://localhost:8080/ecommerce-backend/api/users/register ^
     -H "Content-Type: application/json" ^
     -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"password123\",\"firstName\":\"Test\",\"lastName\":\"User\"}"

# Test user login
curl -X POST http://localhost:8080/ecommerce-backend/api/users/login ^
     -H "Content-Type: application/json" ^
     -d "{\"username\":\"testuser\",\"password\":\"password123\"}"

# Test cart API (requires authentication token)
curl http://localhost:8080/ecommerce-backend/api/simplecart/count ^
     -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### **Frontend Setup (IIS + ASP.NET)**

#### **1. Configure IIS Permissions**
```cmd
# Set proper permissions for IIS to access the application files
icacls "C:\ecommerce\ecommerce-ui" /grant IIS_IUSRS:(OI)(CI)F
icacls "C:\ecommerce\ecommerce-ui" /grant "IIS AppPool\DefaultAppPool":(OI)(CI)F
icacls "C:\ecommerce\ecommerce-ui" /grant "BUILTIN\Users":(OI)(CI)R

# Restart IIS to apply changes
iisreset /restart

# Verify IIS is running
sc query W3SVC
```

#### **2. Create IIS Application**
**Option A: Using IIS Manager (GUI)**
1. Open **IIS Manager** (Run → `inetmgr`)
2. Expand server node → Expand **Sites**
3. Right-click **Default Web Site** → **Add Application**
4. Configure:
   - **Alias**: `ecommerce-ui`
   - **Physical Path**: `C:\ecommerce\ecommerce-ui`
   - **Application Pool**: `DefaultAppPool`
5. Click **OK**

**Option B: Using Command Line**
```cmd
# Create IIS application using appcmd
%windir%\system32\inetsrv\appcmd add app /site.name:"Default Web Site" /path:/ecommerce-ui /physicalPath:"C:\ecommerce\ecommerce-ui"

# Verify application was created
%windir%\system32\inetsrv\appcmd list app
```

#### **3. Configure Application Pool**
```cmd
# Ensure DefaultAppPool is configured for .NET Framework 4.8
%windir%\system32\inetsrv\appcmd set apppool "DefaultAppPool" /managedRuntimeVersion:"v4.0"

# Set application pool identity
%windir%\system32\inetsrv\appcmd set apppool "DefaultAppPool" /processModel.identityType:ApplicationPoolIdentity

# Start the application pool
%windir%\system32\inetsrv\appcmd start apppool "DefaultAppPool"
```

#### **4. Verify Frontend Setup**
```cmd
# Test IIS application
curl http://localhost/ecommerce-ui/

# Check if default document loads
curl http://localhost/ecommerce-ui/HomeWithProducts.aspx

# Verify specific pages
curl http://localhost/ecommerce-ui/ProductsWorking.aspx
curl http://localhost/ecommerce-ui/LoginWorking.aspx
curl http://localhost/ecommerce-ui/RegisterWorking.aspx
```

#### **5. Configure Web.config (if needed)**
The `Web.config` should already be properly configured, but verify these settings:
```xml
<configuration>
  <system.web>
    <compilation debug="true" targetFramework="4.8" />
    <httpRuntime targetFramework="4.8" />
    <authentication mode="None" />
    <sessionState mode="InProc" timeout="30" />
  </system.web>
  
  <system.webServer>
    <defaultDocument>
      <files>
        <clear />
        <add value="HomeWithProducts.aspx" />
      </files>
    </defaultDocument>
  </system.webServer>
</configuration>
```

---

## 🎯 **Application URLs**

### **Main Application**
- **Homepage**: `http://localhost/ecommerce-ui/`
- **Products**: `http://localhost/ecommerce-ui/ProductsWorking.aspx`
- **Registration**: `http://localhost/ecommerce-ui/RegisterWorking.aspx`
- **Login**: `http://localhost/ecommerce-ui/LoginWorking.aspx`
- **User Dashboard**: `http://localhost/ecommerce-ui/UserDashboardSimple.aspx`

### **Backend APIs**
- **Products**: `http://localhost:8080/ecommerce-backend/api/products`
- **User Registration**: `http://localhost:8080/ecommerce-backend/api/users/register`
- **User Login**: `http://localhost:8080/ecommerce-backend/api/users/login`

### **Debug Pages**
- **Session Debug**: `http://localhost/ecommerce-ui/SessionDebug.aspx`
- **Test Session**: `http://localhost/ecommerce-ui/TestSession.aspx`

---

## 👤 **Demo Accounts**

### **Pre-created Users**
- **Admin**: username: `admin`, password: `admin123`
- **User**: username: `johndoe`, password: `user123`

### **Create New Account**
1. Go to: `http://localhost/ecommerce-ui/RegisterWorking.aspx`
2. Fill out the registration form
3. Click "Create Account"
4. Use the new credentials to login

---

## 🛠 **Troubleshooting & Debugging**

### **System Health Check Commands**

#### **1. Check All Services Status**
```cmd
# PostgreSQL Service
sc query postgresql-x64-17
net start postgresql-x64-17

# IIS Service
sc query W3SVC
net start W3SVC

# Check ports
netstat -an | findstr ":5432"  # PostgreSQL
netstat -an | findstr ":8080"  # Backend API
netstat -an | findstr ":80"    # IIS
```

#### **2. Process Management**
```cmd
# Kill all Java processes (if backend is stuck)
taskkill /f /im java.exe

# Kill specific process by PID
netstat -ano | findstr ":8080"
taskkill /PID [process_id] /F

# Restart IIS
iisreset /restart
```

### **Common Issues & Solutions**

#### **1. "Unable to load products" Error**
**Symptoms**: Frontend shows "Products Temporarily Unavailable"
```cmd
# Check if backend is running
netstat -an | findstr ":8080"

# If not running, start backend
cd C:\ecommerce\ecommerce-backend
mvn tomcat7:run

# Test API directly
curl http://localhost:8080/ecommerce-backend/api/products

# Check backend logs for errors
# Look for database connection issues or compilation errors
```

#### **2. Database Connection Errors**
**Symptoms**: Backend fails to start, "connection refused" errors
```cmd
# Check PostgreSQL service
sc query postgresql-x64-17
net start postgresql-x64-17

# Test database connection
psql -U postgres -h localhost -d ecommerce

# Check database configuration
notepad C:\ecommerce\ecommerce-backend\src\main\resources\application.properties

# Verify database exists and has data
psql -U postgres -h localhost -d ecommerce -c "SELECT COUNT(*) FROM products;"
```

#### **3. IIS Permission Errors**
**Symptoms**: "Access Denied", "500 Internal Server Error"
```cmd
# Fix file permissions
icacls "C:\ecommerce\ecommerce-ui" /grant IIS_IUSRS:(OI)(CI)F
icacls "C:\ecommerce\ecommerce-ui" /grant "IIS AppPool\DefaultAppPool":(OI)(CI)F

# Reset IIS
iisreset /restart

# Check application pool status
%windir%\system32\inetsrv\appcmd list apppool "DefaultAppPool"

# Restart application pool
%windir%\system32\inetsrv\appcmd start apppool "DefaultAppPool"
```

#### **4. Maven Build Errors**
**Symptoms**: Compilation failures, dependency issues
```cmd
# Clean Maven cache
cd C:\ecommerce\ecommerce-backend
mvn clean

# Force dependency re-download
mvn dependency:purge-local-repository
mvn clean compile

# Check Java version
java -version
mvn -version

# If module-info.class errors (already handled in pom.xml)
# The maven-war-plugin excludes these files
```

#### **5. CORS Errors**
**Symptoms**: "Access blocked by CORS policy" in browser console
```cmd
# Verify backend is running
curl http://localhost:8080/ecommerce-backend/api/products

# Check if CORS filter is working
curl -H "Origin: http://localhost" -H "Access-Control-Request-Method: POST" -X OPTIONS http://localhost:8080/ecommerce-backend/api/simplecart/add

# Use SimpleCartController endpoints (has built-in CORS)
# Frontend should use /api/simplecart/ instead of /api/cart/
```

#### **6. Cart Permission Errors**
**Symptoms**: "permission denied for table cart"
```cmd
# Connect to database and grant permissions
psql -U postgres -h localhost -d ecommerce

# Grant cart table permissions
GRANT ALL PRIVILEGES ON TABLE cart TO postgres;
GRANT ALL PRIVILEGES ON SEQUENCE cart_id_seq TO postgres;

# Verify permissions
\dp cart

# Exit
\q
```

#### **7. Session/Authentication Issues**
**Symptoms**: "Please login" message when user is logged in
```cmd
# Check session configuration in Web.config
notepad C:\ecommerce\ecommerce-ui\Web.config

# Verify session state is enabled:
# <sessionState mode="InProc" timeout="30" />

# Test JWT token generation
curl -X POST http://localhost:8080/ecommerce-backend/api/users/login ^
     -H "Content-Type: application/json" ^
     -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
```

### **Port Conflicts**
- **PostgreSQL**: 5432
- **Backend API**: 8080
- **Frontend**: 80 (IIS)

If ports are in use, check running processes:
```cmd
netstat -ano | findstr ":8080"
taskkill /PID [process_id] /F
```

### **Log Files**
- **Backend Logs**: Console output from `mvn tomcat7:run`
- **IIS Logs**: `C:\inetpub\logs\LogFiles\W3SVC1\`
- **PostgreSQL Logs**: `C:\Program Files\PostgreSQL\17\data\log\`

---

## 🔄 **Daily Operations**

### **Complete Startup Script**
Create `start-application.bat` in `C:\ecommerce\`:
```batch
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
```

### **Complete Shutdown Script**
Create `stop-application.bat` in `C:\ecommerce\`:
```batch
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
```

### **Health Check Script**
Create `health-check.bat` in `C:\ecommerce\`:
```batch
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
```

### **Manual Startup Commands**
```cmd
# 1. Start PostgreSQL
net start postgresql-x64-17

# 2. Start IIS
net start W3SVC

# 3. Start Backend (in separate command prompt)
cd C:\ecommerce\ecommerce-backend
mvn tomcat7:run

# 4. Open application
start http://localhost/ecommerce-ui/
```

---

## 📊 **System Health Check**

### **Quick Health Check Script**
```cmd
@echo off
echo === TechMart Health Check ===

echo Checking PostgreSQL...
netstat -an | findstr ":5432" >nul
if %errorlevel%==0 (echo ✅ PostgreSQL: Running) else (echo ❌ PostgreSQL: Not running)

echo Checking Backend API...
netstat -an | findstr ":8080" >nul
if %errorlevel%==0 (echo ✅ Backend API: Running) else (echo ❌ Backend API: Not running)

echo Checking IIS...
sc query W3SVC | findstr "RUNNING" >nul
if %errorlevel%==0 (echo ✅ IIS: Running) else (echo ❌ IIS: Not running)

echo.
echo Testing API endpoint...
curl -s http://localhost:8080/ecommerce-backend/api/products >nul
if %errorlevel%==0 (echo ✅ API: Responding) else (echo ❌ API: Not responding)

echo.
echo === Health Check Complete ===
pause
```

Save this as `health-check.bat` in the `C:\ecommerce\` directory.

---

## 🎉 **Success Indicators**

Your application is working correctly when:

✅ **Database**: PostgreSQL service running on port 5432
✅ **Backend**: Maven shows "Starting ProtocolHandler ["http-bio-8080"]"
✅ **API**: `curl http://localhost:8080/ecommerce-backend/api/products` returns JSON
✅ **Frontend**: `http://localhost/ecommerce-ui/` shows TechMart homepage
✅ **Products**: Homepage displays 4 featured products
✅ **Registration**: New users can create accounts
✅ **Login**: Users can login and see personalized dashboard
✅ **Navigation**: Logged-in users see "Welcome, [Name]!" and Logout option

---

## 📞 **Support**

If you encounter issues:

1. **Check the troubleshooting section** above
2. **Run the health check script** to identify problems
3. **Check log files** for detailed error messages
4. **Verify all prerequisites** are properly installed
5. **Ensure all ports** (5432, 8080, 80) are available

---

## 🔐 **Security Notes**

- **Development Mode**: This setup is for development/testing only
- **Production**: Use proper SSL certificates, secure passwords, and environment variables
- **Database**: Change default PostgreSQL passwords
- **Sessions**: Configure secure session storage for production
- **API Keys**: Use environment variables for sensitive configuration

---

**🎊 Congratulations! You now have a fully functional e-commerce application running locally.**
