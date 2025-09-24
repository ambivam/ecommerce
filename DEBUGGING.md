# E-Commerce Application Debugging Guide

## Overview

This comprehensive debugging guide covers troubleshooting for a full-stack e-commerce application with:
- **Frontend**: ASP.NET Web Forms (.NET Framework 4.8) on IIS
- **Backend**: Java 8 with JAX-RS (Jersey) on Apache Tomcat
- **Database**: PostgreSQL 17
- **Build Tools**: Maven 3.8+

## Table of Contents
1. [Quick Diagnostic Commands](#quick-diagnostic-commands)
2. [Critical Issues (Application Won't Start)](#critical-issues)
3. [Database Connection Issues](#database-connection-issues)
4. [ASP.NET Compilation and Runtime Issues](#aspnet-issues)
5. [Java Backend Issues](#java-backend-issues)
6. [Component-Specific Debugging](#component-specific-debugging)
7. [Log File Analysis](#log-file-analysis)
8. [Performance Issues](#performance-issues)
9. [Network and Connectivity](#network-and-connectivity)
10. [Development Environment Issues](#development-environment-issues)
11. [Production Deployment Issues](#production-deployment-issues)
12. [Emergency Recovery Procedures](#emergency-recovery-procedures)

## Quick Diagnostic Commands

### System Status Check
```cmd
# Check all services are running
netstat -an | findstr ":80 :8081 :5432"

# Check Java processes
tasklist | findstr java

# Check IIS status
iisreset /status

# Check PostgreSQL service (try different service names)
sc query postgresql-x64-17
sc query postgresql-x64-16
sc query postgresql-x64-15
sc query postgresql-x64-14
# OR find all PostgreSQL services:
sc query | findstr -i postgres
# OR check if PostgreSQL is running as a process
tasklist | findstr -i postgres
```

### Application Health Check
```cmd
# Test frontend
curl http://localhost/ecommerce-ui
curl http://localhost/ecommerce-ui/Default.aspx

# Test backend API (check both possible ports)
curl http://localhost:8080/ecommerce-backend/api/products
curl http://localhost:8081/ecommerce-backend/api/products

# Test specific API endpoints
curl http://localhost:8080/ecommerce-backend/api/categories
curl http://localhost:8080/ecommerce-backend/api/users/health

# Test database connection
psql -U ecommerce_user -d ecommerce -c "SELECT COUNT(*) FROM products;"
psql -U ecommerce_user -d ecommerce -c "SELECT version();"

# Test with verbose output for debugging
curl -v http://localhost:8080/ecommerce-backend/api/products
```

### Complete System Health Check
```cmd
# Run all checks in sequence
echo "=== System Health Check ==="
echo "1. Checking PostgreSQL..."
sc query postgresql-x64-17
netstat -an | findstr :5432

echo "2. Checking Tomcat..."
tasklist | findstr java
netstat -an | findstr :8080

echo "3. Checking IIS..."
iisreset /status
netstat -an | findstr :80

echo "4. Testing API endpoints..."
curl -s http://localhost:8080/ecommerce-backend/api/products | echo "API Response: %ERRORLEVEL%"

echo "5. Testing frontend..."
curl -s http://localhost/ecommerce-ui | echo "Frontend Response: %ERRORLEVEL%"
```

## Critical Issues (Application Won't Start)

### 🔥 **Priority 1: Service Not Running**

#### 1. Port Conflicts

**Error**: `java.net.BindException: Address already in use: JVM_Bind :8080`

**Diagnosis**:
```cmd
netstat -ano | findstr :8080
```

**Solution**:
```cmd
# Kill conflicting process
taskkill /PID <PID_NUMBER> /F

# Or use different port in pom.xml
<port>8081</port>
```

#### 2. Spring Boot Plugin Error

**Error**: `No plugin found for prefix 'spring-boot'`

**Root Cause**: This is a JAX-RS application, NOT Spring Boot

**Solution**:
```cmd
# WRONG: mvn spring-boot:run
# CORRECT: mvn tomcat7:run
cd C:\ecommerce\ecommerce-backend
mvn tomcat7:run
```

#### 3. ASP.NET Compilation Errors

**Error**: `CS1056: Unexpected character '$'`
**Cause**: String interpolation not supported in .NET Framework 4.8

**Solution**:
```csharp
// WRONG: $"Hello {name}"
// CORRECT: "Hello " + name
```

**Error**: `CS0234: The type or namespace name 'Http' does not exist`
**Cause**: HttpClient not available in older .NET Framework

**Solution**:
```csharp
// Replace HttpClient with WebClient
using System.Net; // Instead of System.Net.Http
var client = new WebClient(); // Instead of HttpClient
```

**Error**: `CS0246: The type or namespace name 'Newtonsoft' could not be found`
**Cause**: External JSON library not available

**Solution**:
```csharp
// Replace Newtonsoft.Json with JavaScriptSerializer
using System.Web.Script.Serialization; // Instead of Newtonsoft.Json
var serializer = new JavaScriptSerializer(); // Instead of JsonConvert
```

### ⚠️ **Warning Issues**

#### 4. IIS Configuration Problems

**Error**: `HTTP 500.19 - Internal Server Error`

**Solution**:
```cmd
# Enable IIS features in correct order
# Step 1: Basic IIS
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures

# Step 2: .NET Framework
Enable-WindowsOptionalFeature -Online -FeatureName NetFx4Extended-ASPNET45

# Step 3: ASP.NET
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-AspNet45
```

#### 5. Database Connection Issues

**Error**: `The specified service does not exist as an installed service`

**Diagnosis**:
```cmd
# Find the correct PostgreSQL service name
sc query | findstr -i postgres

# Check if PostgreSQL is installed
dir "C:\Program Files\PostgreSQL"

# Check if PostgreSQL process is running
tasklist | findstr -i postgres

# Try common service names
sc query postgresql-x64-17
sc query postgresql-x64-16
sc query postgresql-x64-15
sc query postgresql-x64-14
```

**Solution**:
```cmd
# If PostgreSQL is not installed, install it first
# Download from: https://www.postgresql.org/download/windows/

# If installed but service name is different, use correct name:
net start postgresql-x64-17  # (adjust version number as needed)

# If installed but not running as service, start manually:
"C:\Program Files\PostgreSQL\17\bin\pg_ctl.exe" start -D "C:\Program Files\PostgreSQL\17\data"
```

**Error**: Connection refused to PostgreSQL

**Diagnosis**:
```cmd
# Test connection manually
psql -U ecommerce_user -d ecommerce -h localhost

# Check if PostgreSQL is listening on port 5432
netstat -an | findstr :5432
```

**Solution**:
```cmd
# Start PostgreSQL service (use correct service name)
net start postgresql-x64-17

# Check firewall settings
netsh advfirewall firewall show rule name="PostgreSQL"

# If firewall blocks, add rule:
netsh advfirewall firewall add rule name="PostgreSQL" dir=in action=allow protocol=TCP localport=5432
```

**Error**: `password authentication failed for user "ecommerce_user"`

**Diagnosis**:
```cmd
# Try connecting with postgres superuser
psql -U postgres -d postgres

# Check if user exists
psql -U postgres -c "\du"
```

**Solution**:
```sql
-- Connect as postgres superuser first
psql -U postgres -d postgres

-- If user doesn't exist, create it first:
CREATE USER ecommerce_user WITH PASSWORD 'newpassword123';

-- Create database if it doesn't exist:
CREATE DATABASE ecommerce OWNER ecommerce_user;

-- If user exists, just reset password:
ALTER USER ecommerce_user WITH PASSWORD 'newpassword123';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO ecommerce_user;

-- Exit PostgreSQL
\q
```

**Test the fix**:
```cmd
# Test connection with new password
psql -U ecommerce_user -d ecommerce -h localhost

# Update application configuration with new password
# Edit connection strings in your application

# If using application.properties, update:
# db.password=newpassword123
```

**Error**: Password mismatch between application and database
```
Error in logs: FATAL: password authentication failed for user "ecommerce_user"
HikariCP shows: username="ecommerce_user" but connection fails

Diagnosis:
1. Check application.properties password
2. Check what password was set in PostgreSQL
3. Verify they match

Solution:
# Option 1: Update PostgreSQL to match application
psql -U postgres -d postgres
ALTER USER ecommerce_user WITH PASSWORD 'ecommerce123';

# Option 2: Update application.properties to match PostgreSQL
# Edit: db.password=correctpassword

# Then rebuild and redeploy:
mvn clean package
copy target\ecommerce-backend.war "C:\Program Files\Apache\Tomcat\9.0\webapps\"

# Wait for auto-deployment (check logs)
tail -f "C:\Program Files\Apache\Tomcat\9.0\logs\catalina.out"
```

## Database Connection Issues

### 🔍 **Comprehensive Database Troubleshooting**

#### Step 1: Service and Process Verification
```cmd
# Check PostgreSQL service status
sc query postgresql-x64-17
sc queryex postgresql-x64-17

# Check PostgreSQL processes
tasklist /fi "imagename eq postgres.exe"
wmic process where "name='postgres.exe'" get processid,commandline

# Check port binding
netstat -ano | findstr :5432
```

#### Step 2: Connection Testing
```cmd
# Test with different connection methods
psql -U postgres -d postgres -h localhost
psql -U ecommerce_user -d ecommerce -h localhost
psql -U ecommerce_user -d ecommerce -h 127.0.0.1

# Test with connection string format
psql "postgresql://ecommerce_user:newpassword123@localhost:5432/ecommerce"

# Test connection timeout
psql -U ecommerce_user -d ecommerce -h localhost --connect-timeout=10
```

#### Step 3: Configuration Verification
```sql
-- Connect as superuser and check configuration
psql -U postgres -d postgres

-- Check user exists and permissions
\du ecommerce_user
SELECT usename, usecreatedb, usesuper FROM pg_user WHERE usename = 'ecommerce_user';

-- Check database exists and ownership
\l ecommerce
SELECT datname, datdba FROM pg_database WHERE datname = 'ecommerce';

-- Check connection limits
SELECT rolname, rolconnlimit FROM pg_roles WHERE rolname = 'ecommerce_user';

-- Check active connections
SELECT usename, application_name, client_addr, state FROM pg_stat_activity;
```

#### Step 4: Authentication Configuration
```cmd
# Check pg_hba.conf location
psql -U postgres -c "SHOW hba_file;"

# View authentication rules
type "C:\Program Files\PostgreSQL\17\data\pg_hba.conf" | findstr -v "#"

# Check postgresql.conf
psql -U postgres -c "SHOW config_file;"
psql -U postgres -c "SHOW listen_addresses;"
psql -U postgres -c "SHOW port;"
```

### 🔧 **Database Connection Solutions**

#### Password Authentication Issues
```sql
-- Reset user password (as postgres superuser)
psql -U postgres -d postgres

-- Method 1: Simple password reset
ALTER USER ecommerce_user WITH PASSWORD 'newpassword123';

-- Method 2: Encrypted password
ALTER USER ecommerce_user WITH ENCRYPTED PASSWORD 'newpassword123';

-- Method 3: Create user if doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'ecommerce_user') THEN
        CREATE USER ecommerce_user WITH PASSWORD 'newpassword123';
    END IF;
END
$$;

-- Grant comprehensive permissions
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO ecommerce_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ecommerce_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ecommerce_user;
GRANT USAGE ON SCHEMA public TO ecommerce_user;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ecommerce_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ecommerce_user;
```

#### Connection Pool Configuration Issues
```properties
# application.properties - Optimal settings for development
db.url=jdbc:postgresql://localhost:5432/ecommerce
db.username=ecommerce_user
db.password=newpassword123

# Connection Pool Settings - Tuned for local development
db.pool.maxSize=10
db.pool.minIdle=2
db.pool.connectionTimeout=20000
db.pool.idleTimeout=300000
db.pool.maxLifetime=1200000
db.pool.leakDetectionThreshold=60000

# Additional HikariCP settings
db.pool.cachePrepStmts=true
db.pool.prepStmtCacheSize=250
db.pool.prepStmtCacheSqlLimit=2048
db.pool.useServerPrepStmts=true
```

## ASP.NET Compilation and Runtime Issues

### 🔨 **Compilation Errors**

#### C# Language Compatibility Issues (.NET Framework 4.8)

**Error**: `CS1056: Unexpected character '$'`
```csharp
// PROBLEM: String interpolation not supported
string message = $"Hello {name}, you have {count} items";

// SOLUTION: Use string concatenation
string message = "Hello " + name + ", you have " + count + " items";

// OR use String.Format
string message = String.Format("Hello {0}, you have {1} items", name, count);
```

**Error**: `CS0234: The type or namespace name 'Http' does not exist`
```csharp
// PROBLEM: HttpClient not available in older .NET Framework
using System.Net.Http;
var client = new HttpClient();
var response = await client.GetAsync(url);

// SOLUTION: Use WebClient
using System.Net;
var client = new WebClient();
client.Headers.Add("Content-Type", "application/json");
string response = client.DownloadString(url);

// For POST requests
string postData = "data=value";
byte[] data = Encoding.UTF8.GetBytes(postData);
client.Headers.Add("Content-Type", "application/x-www-form-urlencoded");
string response = client.UploadString(url, "POST", postData);
```

**Error**: `CS0246: The type or namespace name 'Newtonsoft' could not be found`
```csharp
// PROBLEM: External JSON library not available
using Newtonsoft.Json;
var json = JsonConvert.SerializeObject(obj);
var obj = JsonConvert.DeserializeObject<MyClass>(json);

// SOLUTION: Use JavaScriptSerializer
using System.Web.Script.Serialization;
var serializer = new JavaScriptSerializer();
var json = serializer.Serialize(obj);
var obj = serializer.Deserialize<MyClass>(json);
```

**Error**: `CS1002: Syntax error, ',' expected` (Expression-bodied properties)
```csharp
// PROBLEM: Expression-bodied properties not supported
public string FullName => FirstName + " " + LastName;

// SOLUTION: Traditional property syntax
public string FullName 
{ 
    get { return FirstName + " " + LastName; } 
}
```

#### Async/Await Compatibility Issues
```csharp
// PROBLEM: Async/await with incompatible methods
public async Task<string> GetDataAsync()
{
    var result = await apiService.GetAsync<Product>();
    return result.Name;
}

// SOLUTION: Remove async/await, use synchronous methods
public string GetData()
{
    var result = apiService.Get<Product>();
    return result.Name;
}
```

### 🌐 **IIS Configuration Issues**

#### HTTP 500.19 - Internal Server Error
```cmd
# Enable IIS features in correct dependency order
# Step 1: Basic IIS features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-HttpLogging, IIS-RequestFiltering, IIS-StaticContent, IIS-DefaultDocument, IIS-DirectoryBrowsing

# Step 2: .NET Framework support (CRITICAL - must be before ASP.NET)
Enable-WindowsOptionalFeature -Online -FeatureName NetFx4Extended-ASPNET45

# Step 3: ASP.NET features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-AspNet45

# Step 4: Additional features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect, IIS-NetFxExtensibility, IIS-ASPNET
```

#### Web.config Optimization for .NET Framework 4.8
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <appSettings>
    <!-- API Configuration -->
    <add key="ApiBaseUrl" value="http://localhost:8080/ecommerce-backend/api" />
    <add key="ApiTimeout" value="30000" />
    
    <!-- Authentication Settings -->
    <add key="JwtTokenKey" value="ecommerce_jwt_token" />
    <add key="SessionTimeout" value="30" />
    
    <!-- UI Settings -->
    <add key="ProductsPerPage" value="12" />
    <add key="DefaultProductImage" value="~/Images/default-product.jpg" />
    
    <!-- Feature Flags -->
    <add key="EnableUserRegistration" value="true" />
    <add key="EnableGuestCheckout" value="true" />
    <add key="EnableProductReviews" value="false" />
  </appSettings>

  <system.web>
    <!-- Compilation settings for .NET Framework 4.8 -->
    <compilation debug="true" targetFramework="4.8" tempDirectory="~/App_Data/Temp/" />
    
    <!-- HTTP Runtime settings -->
    <httpRuntime targetFramework="4.8" maxRequestLength="51200" executionTimeout="300" />
    
    <!-- Authentication -->
    <authentication mode="Forms">
      <forms loginUrl="~/Account/Login.aspx" timeout="30" slidingExpiration="true" />
    </authentication>
    
    <!-- Authorization -->
    <authorization>
      <allow users="*" />
    </authorization>
    
    <!-- Session State -->
    <sessionState mode="InProc" timeout="30" cookieless="false" />
    
    <!-- Custom Errors - Set to Off for debugging -->
    <customErrors mode="Off" />
    
    <!-- Pages settings -->
    <pages controlRenderingCompatibilityVersion="4.0" clientIDMode="AutoID" />
    
    <!-- Trust level -->
    <trust level="Full" />
  </system.web>

  <system.webServer>
    <!-- Default Documents -->
    <defaultDocument>
      <files>
        <clear />
        <add value="Default.aspx" />
        <add value="index.html" />
      </files>
    </defaultDocument>
    
    <!-- Error pages -->
    <httpErrors errorMode="Detailed" />
    
    <!-- Static content caching -->
    <staticContent>
      <clientCache cacheControlMode="UseMaxAge" cacheControlMaxAge="7.00:00:00" />
    </staticContent>
    
    <!-- URL rewrite (if needed) -->
    <rewrite>
      <rules>
        <rule name="Redirect to HTTPS" stopProcessing="true">
          <match url=".*" />
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:0}" redirectType="Permanent" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

### 🔧 **ASP.NET Runtime Debugging**

#### Application Pool Issues
```cmd
# Check application pool status
%windir%\system32\inetsrv\appcmd list apppool "ecommerce-ui"

# Check application pool configuration
%windir%\system32\inetsrv\appcmd list apppool "ecommerce-ui" /config

# Reset application pool
%windir%\system32\inetsrv\appcmd recycle apppool "ecommerce-ui"

# Check worker processes
%windir%\system32\inetsrv\appcmd list wp

# Check application pool identity
%windir%\system32\inetsrv\appcmd list apppool "ecommerce-ui" /text:processModel.identityType
```

#### File Permissions
```cmd
# Grant IIS_IUSRS permission to application folder
icacls "C:\ecommerce\ecommerce-ui" /grant IIS_IUSRS:(OI)(CI)F

# Grant application pool identity permissions
icacls "C:\ecommerce\ecommerce-ui" /grant "IIS AppPool\ecommerce-ui":(OI)(CI)F

# Check current permissions
icacls "C:\ecommerce\ecommerce-ui"

# Grant permissions to Temp ASP.NET Files
icacls "%WINDOWS%\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files" /grant IIS_IUSRS:(OI)(CI)F
```

## Java Backend Issues

### ☕ **Maven Build Issues**

#### Build Failures and Locked Files
```cmd
# Stop all Java processes
taskkill /f /im java.exe

# Clean Maven cache and rebuild
mvn clean install -U

# Skip tests if they're failing
mvn clean package -DskipTests

# Force update dependencies
mvn clean install -U -Dmaven.test.skip=true

# Debug Maven build
mvn clean compile -X

# Check dependency tree
mvn dependency:tree
```

#### Tomcat Plugin Configuration Issues
```xml
<!-- Correct pom.xml configuration for Tomcat plugin -->
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <url>http://localhost:8080/manager/text</url>
        <server>tomcat</server>
        <path>/ecommerce-backend</path>
        <port>8080</port>
        <username>admin</username>
        <password>admin123</password>
        <!-- Additional configuration -->
        <update>true</update>
        <warFile>${project.build.directory}/${project.build.finalName}.war</warFile>
    </configuration>
</plugin>
```

### 🚀 **Tomcat Deployment Issues**

#### WAR File Deployment Problems
```cmd
# Manual deployment steps
cd C:\ecommerce\ecommerce-backend

# 1. Clean build
mvn clean package

# 2. Verify WAR file exists
dir target\*.war

# 3. Stop Tomcat
cd "C:\Program Files\Apache\Tomcat\9.0\bin"
shutdown.bat

# 4. Remove old deployment
rmdir /s /q "C:\Program Files\Apache\Tomcat\9.0\webapps\ecommerce-backend"
del "C:\Program Files\Apache\Tomcat\9.0\webapps\ecommerce-backend.war"

# 5. Copy new WAR file
copy "C:\ecommerce\ecommerce-backend\target\ecommerce-backend.war" "C:\Program Files\Apache\Tomcat\9.0\webapps\"

# 6. Start Tomcat
startup.bat

# 7. Monitor deployment
tail -f "C:\Program Files\Apache\Tomcat\9.0\logs\catalina.out"
```

#### Context Path Issues
```cmd
# Check if application is deployed with correct context path
curl http://localhost:8080/manager/text/list
curl http://localhost:8080/ecommerce-backend/api/products
curl http://localhost:8080/ecommerce/api/products

# If context path is wrong, check server.xml or context.xml
type "C:\Program Files\Apache\Tomcat\9.0\conf\server.xml" | findstr -i context
```

### 🔍 **JAX-RS and Jersey Issues**

#### Jersey Servlet Configuration
```xml
<!-- web.xml - Correct Jersey configuration -->
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee 
         http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    
    <display-name>E-Commerce Backend</display-name>
    
    <!-- Jersey Servlet -->
    <servlet>
        <servlet-name>jersey-servlet</servlet-name>
        <servlet-class>org.glassfish.jersey.servlet.ServletContainer</servlet-class>
        <init-param>
            <param-name>javax.ws.rs.Application</param-name>
            <param-value>com.ecommerce.config.RestApplication</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    
    <servlet-mapping>
        <servlet-name>jersey-servlet</servlet-name>
        <url-pattern>/api/*</url-pattern>
    </servlet-mapping>
    
    <!-- CORS Filter -->
    <filter>
        <filter-name>CorsFilter</filter-name>
        <filter-class>com.ecommerce.filter.CorsFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>CorsFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
    
</web-app>
```

## Component-Specific Debugging

### Frontend (ASP.NET) Debugging

#### Advanced IIS Diagnostics
```cmd
# Check IIS application configuration
%windir%\system32\inetsrv\appcmd list app
%windir%\system32\inetsrv\appcmd list vdir

# Check application pool detailed status
%windir%\system32\inetsrv\appcmd list apppool "ecommerce-ui" /text:*

# Check site bindings
%windir%\system32\inetsrv\appcmd list site "Default Web Site" /text:bindings

# Check failed request tracing
%windir%\system32\inetsrv\appcmd list config "Default Web Site/ecommerce-ui" -section:system.webServer/tracing/traceFailedRequests
```

#### Common ASP.NET Issues
```xml
<!-- Web.config debugging settings -->
<system.web>
  <compilation debug="true" targetFramework="4.8" />
  <customErrors mode="Off" />
</system.web>
```

#### API Connection Issues
```csharp
// Check Web.config API URL
<add key="ApiBaseUrl" value="http://localhost:8080/ecommerce-backend/api" />

// Test API connectivity in code-behind
try {
    var client = new WebClient();
    client.Headers.Add("Content-Type", "application/json");
    var response = client.DownloadString(ConfigurationManager.AppSettings["ApiBaseUrl"] + "/products");
    System.Diagnostics.Debug.WriteLine("API Response: " + response);
} catch (Exception ex) {
    System.Diagnostics.Debug.WriteLine("API Error: " + ex.Message);
    // Log to Event Viewer
    EventLog.WriteEntry("E-Commerce App", "API Connection Failed: " + ex.Message, EventLogEntryType.Error);
}
```

### Backend (Java) Debugging

#### Advanced Tomcat Diagnostics
```cmd
# Check Tomcat manager status
curl http://localhost:8080/manager/text/list --user admin:admin123

# Check application status
curl http://localhost:8080/manager/text/sessions?path=/ecommerce-backend --user admin:admin123

# Check server status
curl http://localhost:8080/manager/text/serverinfo --user admin:admin123

# Check JVM memory
curl http://localhost:8080/manager/text/vminfo --user admin:admin123
```

#### Database Connection Debugging in Java
```java
// Add to your DAO classes for debugging
public void testConnection() {
    try {
        Connection conn = dataSource.getConnection();
        System.out.println("Database connection successful: " + conn.getMetaData().getURL());
        System.out.println("Database user: " + conn.getMetaData().getUserName());
        System.out.println("Database product: " + conn.getMetaData().getDatabaseProductName());
        System.out.println("Database version: " + conn.getMetaData().getDatabaseProductVersion());
        
        // Test a simple query
        PreparedStatement stmt = conn.prepareStatement("SELECT 1");
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            System.out.println("Database query test successful");
        }
        
        rs.close();
        stmt.close();
        conn.close();
    } catch (SQLException e) {
        System.err.println("Database connection failed: " + e.getMessage());
        e.printStackTrace();
    }
}
```

## Log File Analysis

### 📋 **Log File Locations and Analysis**

#### Tomcat Logs
```cmd
# Main Tomcat logs directory
cd "C:\Program Files\Apache\Tomcat\9.0\logs"

# Key log files:
# catalina.out - Main application log
# localhost.log - Application-specific log  
# manager.log - Deployment log
# host-manager.log - Host manager log

# View recent errors
findstr /i "error\|exception\|severe" catalina.out | more
findstr /i "failed\|timeout\|refused" catalina.out | more

# View startup sequence
findstr /i "starting\|started\|deployed" catalina.out | more

# Monitor logs in real-time
tail -f catalina.out
```

#### IIS Logs
```cmd
# IIS access logs
cd C:\inetpub\logs\LogFiles\W3SVC1

# View recent access logs
dir /od *.log | more

# Search for errors (status codes 4xx, 5xx)
findstr " 4[0-9][0-9] \| 5[0-9][0-9] " ex*.log | more

# Search for specific URLs
findstr "ecommerce-ui" ex*.log | more
```

#### PostgreSQL Logs
```cmd
# PostgreSQL logs directory
cd "C:\Program Files\PostgreSQL\17\data\log"

# View recent errors
findstr /i "error\|fatal\|panic" postgresql-*.log | more

# View connection attempts
findstr /i "connection\|authentication" postgresql-*.log | more

# View slow queries (if enabled)
findstr /i "slow\|duration" postgresql-*.log | more
```

#### Windows Event Logs
```cmd
# View Application Event Log
eventvwr.msc

# PowerShell commands for event log analysis
Get-EventLog -LogName Application -Source "ASP.NET*" -EntryType Error -Newest 10
Get-EventLog -LogName Application -Source "PostgreSQL*" -EntryType Error -Newest 10
Get-EventLog -LogName System -EntryType Error -Newest 10 | Where-Object {$_.Message -like "*Tomcat*"}
```

### 🔍 **Log Analysis Patterns**

#### Common Error Patterns
```cmd
# Database connection errors
findstr /i "connection.*refused\|authentication.*failed\|timeout" *.log

# Memory issues
findstr /i "outofmemory\|heap\|gc" *.log

# Permission issues
findstr /i "access.*denied\|permission\|unauthorized" *.log

# Configuration issues
findstr /i "configuration\|missing.*property\|invalid.*parameter" *.log
```

## Performance Issues

### ⚡ **Memory and CPU Optimization**

#### Java/Tomcat Performance
```cmd
# Set optimal JVM options for development
set JAVA_OPTS=-Xms512m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:+UseG1GC -XX:+UseStringDeduplication

# For production, use more aggressive settings
set JAVA_OPTS=-Xms1024m -Xmx4096m -XX:NewRatio=3 -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication -XX:+OptimizeStringConcat

# Monitor JVM performance
jconsole
jvisualvm
```

#### Database Performance Tuning
```sql
-- PostgreSQL performance queries
-- Check slow queries
SELECT query, mean_time, calls, total_time
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch 
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;

-- Check table sizes
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check connection statistics
SELECT datname, numbackends, xact_commit, xact_rollback, 
       blks_read, blks_hit, tup_returned, tup_fetched, tup_inserted, tup_updated, tup_deleted
FROM pg_stat_database 
WHERE datname = 'ecommerce';
```

#### IIS Performance Optimization
```cmd
# Check IIS performance counters
typeperf "\ASP.NET Applications(__Total__)\Requests/Sec" -sc 10
typeperf "\ASP.NET Applications(__Total__)\Request Execution Time" -sc 10
typeperf "\Process(w3wp)\% Processor Time" -sc 10

# Application pool recycling settings
%windir%\system32\inetsrv\appcmd set apppool "ecommerce-ui" -recycling.periodicRestart.time:00:00:00
%windir%\system32\inetsrv\appcmd set apppool "ecommerce-ui" -recycling.periodicRestart.memory:500000
```

## Network and Connectivity

### 🌐 **Network Troubleshooting**

#### Firewall Configuration
```cmd
# Check Windows Firewall status
netsh advfirewall show allprofiles

# Check specific port rules
netsh advfirewall firewall show rule name=all | findstr "8080\|5432\|80"

# Add firewall rules if needed
netsh advfirewall firewall add rule name="Tomcat HTTP" dir=in action=allow protocol=TCP localport=8080
netsh advfirewall firewall add rule name="PostgreSQL" dir=in action=allow protocol=TCP localport=5432
netsh advfirewall firewall add rule name="IIS HTTP" dir=in action=allow protocol=TCP localport=80

# Temporarily disable firewall for testing (NOT recommended for production)
netsh advfirewall set allprofiles state off
```

#### Network Connectivity Testing
```cmd
# Test port connectivity
telnet localhost 8080
telnet localhost 5432
telnet localhost 80

# Test with PowerShell (if telnet not available)
Test-NetConnection -ComputerName localhost -Port 8080
Test-NetConnection -ComputerName localhost -Port 5432
Test-NetConnection -ComputerName localhost -Port 80

# Check routing table
route print

# Check DNS resolution
nslookup localhost
ping localhost
```

#### CORS Configuration
```java
// CORS Filter for Java backend
@WebFilter("/*")
public class CorsFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        
        // Allow specific origins (adjust for your frontend)
        httpResponse.setHeader("Access-Control-Allow-Origin", "http://localhost");
        httpResponse.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        httpResponse.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With");
        httpResponse.setHeader("Access-Control-Allow-Credentials", "true");
        httpResponse.setHeader("Access-Control-Max-Age", "3600");
        
        if ("OPTIONS".equalsIgnoreCase(httpRequest.getMethod())) {
            httpResponse.setStatus(HttpServletResponse.SC_OK);
        } else {
            chain.doFilter(request, response);
        }
    }
}
```

## Emergency Recovery Procedures

### 🚨 **Complete System Recovery**

#### Full Application Reset
```cmd
@echo off
echo === E-Commerce Application Emergency Recovery ===
echo.

echo Step 1: Stopping all services...
iisreset /stop
taskkill /f /im java.exe
net stop postgresql-x64-17

echo Step 2: Clearing temporary files...
del /q /s "%TEMP%\*" 2>nul
del /q /s "%WINDOWS%\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*" 2>nul
rmdir /s /q "C:\Program Files\Apache\Tomcat\9.0\work" 2>nul
rmdir /s /q "C:\Program Files\Apache\Tomcat\9.0\temp" 2>nul

echo Step 3: Restarting services...
net start postgresql-x64-17
timeout /t 5
iisreset /start

echo Step 4: Rebuilding and redeploying application...
cd C:\ecommerce\ecommerce-backend
mvn clean package -DskipTests
copy target\ecommerce-backend.war "C:\Program Files\Apache\Tomcat\9.0\webapps\"

echo Step 5: Starting Tomcat...
cd "C:\Program Files\Apache\Tomcat\9.0\bin"
startup.bat

echo.
echo === Recovery Complete ===
echo Wait 30 seconds, then test:
echo Frontend: http://localhost/ecommerce-ui
echo Backend:  http://localhost:8080/ecommerce-backend/api/products
```

#### Database Recovery
```sql
-- Emergency database recovery script
-- Connect as postgres superuser
psql -U postgres -d postgres

-- Terminate all connections to ecommerce database
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'ecommerce'
  AND pid <> pg_backend_pid();

-- Drop and recreate database (CAUTION: This will lose all data!)
DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce OWNER ecommerce_user;

-- Restore from backup (if available)
-- \i C:\backup\ecommerce_backup.sql

-- Or recreate basic structure
\c ecommerce

-- Create basic tables (adjust as needed)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ecommerce_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ecommerce_user;
```

### 📞 **Support and Escalation**

#### Diagnostic Information Collection
```cmd
# Create comprehensive diagnostic report
@echo off
set REPORT_FILE=ecommerce_diagnostic_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt

echo === E-Commerce Application Diagnostic Report === > %REPORT_FILE%
echo Generated: %date% %time% >> %REPORT_FILE%
echo. >> %REPORT_FILE%

echo === System Information === >> %REPORT_FILE%
systeminfo | findstr /i "OS Name\|OS Version\|Total Physical Memory" >> %REPORT_FILE%
echo. >> %REPORT_FILE%

echo === Java Information === >> %REPORT_FILE%
java -version 2>> %REPORT_FILE%
echo JAVA_HOME: %JAVA_HOME% >> %REPORT_FILE%
echo. >> %REPORT_FILE%

echo === Service Status === >> %REPORT_FILE%
sc query postgresql-x64-17 >> %REPORT_FILE%
iisreset /status >> %REPORT_FILE%
tasklist | findstr java >> %REPORT_FILE%
echo. >> %REPORT_FILE%

echo === Network Status === >> %REPORT_FILE%
netstat -an | findstr ":80 :8080 :5432" >> %REPORT_FILE%
echo. >> %REPORT_FILE%

echo === Recent Errors === >> %REPORT_FILE%
findstr /i "error\|exception" "C:\Program Files\Apache\Tomcat\9.0\logs\catalina.out" | tail -20 >> %REPORT_FILE%

echo Diagnostic report saved to: %REPORT_FILE%
```

---

## Quick Reference Card

### 🎯 **Most Common Issues - Quick Fixes**

| Issue | Quick Command | Expected Result |
|-------|---------------|-----------------|
| Port 8080 in use | `taskkill /f /im java.exe` | Process terminated |
| PostgreSQL not running | `net start postgresql-x64-17` | Service started |
| IIS not responding | `iisreset /restart` | IIS restarted |
| Database password wrong | `psql -U postgres -c "ALTER USER ecommerce_user WITH PASSWORD 'newpassword123';"` | Password updated |
| Maven build fails | `mvn clean package -DskipTests` | Build successful |
| API not accessible | `curl http://localhost:8080/ecommerce-backend/api/products` | JSON response |

### 📋 **Health Check Sequence**
```cmd
# Run this sequence to verify everything is working
echo "1. Services..." & sc query postgresql-x64-17 & tasklist | findstr java & iisreset /status
echo "2. Ports..." & netstat -an | findstr ":80 :8080 :5432"
echo "3. API..." & curl -s http://localhost:8080/ecommerce-backend/api/products
echo "4. Frontend..." & curl -s http://localhost/ecommerce-ui
echo "5. Database..." & psql -U ecommerce_user -d ecommerce -c "SELECT version();"
```

---

*Last Updated: 2025-09-24*  
*Version: 2.0.0 - Comprehensive Edition*

#### API Connection Issues
```csharp
// Check Web.config API URL
<add key="ApiBaseUrl" value="http://localhost:8081/ecommerce-backend/api" />

// Test API connectivity in code
try {
    var client = new WebClient();
    var response = client.DownloadString("http://localhost:8081/ecommerce-backend/api/products");
    System.Diagnostics.Debug.WriteLine("API Response: " + response);
} catch (Exception ex) {
    System.Diagnostics.Debug.WriteLine("API Error: " + ex.Message);
}
```

### Backend (Java) Debugging

#### Maven Build Issues
```cmd
# Clean and rebuild
mvn clean compile
mvn package

# Check dependencies
mvn dependency:tree

# Skip tests if needed
mvn package -DskipTests
```

#### Tomcat Plugin Issues
```xml
<!-- Correct pom.xml configuration -->
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <path>/ecommerce-backend</path>
        <port>8081</port>
    </configuration>
</plugin>
```

#### Database Connection Debugging
```java
// Add to your DAO classes for debugging
try {
    Connection conn = dataSource.getConnection();
    System.out.println("Database connection successful: " + conn.getMetaData().getURL());
    conn.close();
} catch (SQLException e) {
    System.err.println("Database connection failed: " + e.getMessage());
}
```

### Database (PostgreSQL) Debugging

#### Connection Testing
```sql
-- Test basic connectivity
SELECT version();

-- Check tables exist
\dt

-- Verify sample data
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM users;
```

#### Performance Queries
```sql
-- Check active connections
SELECT * FROM pg_stat_activity;

-- Check table sizes
SELECT schemaname,tablename,attname,n_distinct,correlation 
FROM pg_stats WHERE tablename = 'products';
```

## Log File Analysis

### Log File Locations

#### Tomcat Logs
```
C:\Program Files\Apache\Tomcat\9.0\logs\
- catalina.out (main log)
- localhost.log (application log)
- manager.log (deployment log)
```

#### IIS Logs
```
C:\inetpub\logs\LogFiles\W3SVC1\
- ex[YYMMDD].log (access logs)
```

#### PostgreSQL Logs
```
C:\Program Files\PostgreSQL\14\data\log\
- postgresql-[YYYY-MM-DD].log
```

#### Windows Event Logs
```
Event Viewer → Windows Logs → Application
Filter by Source: ASP.NET, IIS, PostgreSQL
```

### Log Analysis Commands

```cmd
# View recent Tomcat errors
findstr "ERROR\|SEVERE" "C:\Program Files\Apache\Tomcat\9.0\logs\catalina.out"

# View IIS errors (PowerShell)
Get-EventLog -LogName Application -Source "ASP.NET*" -EntryType Error -Newest 10

# View PostgreSQL errors
findstr "ERROR\|FATAL" "C:\Program Files\PostgreSQL\14\data\log\postgresql-*.log"
```

## Performance Issues

### Memory Issues

#### Java Heap Size
```cmd
# Set JVM options for Tomcat
set JAVA_OPTS=-Xms512m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m
mvn tomcat7:run
```

#### IIS Application Pool
```cmd
# Check application pool memory usage
%windir%\system32\inetsrv\appcmd list wp
```

### Database Performance

```sql
-- Check slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch 
FROM pg_stat_user_indexes 
ORDER BY idx_scan DESC;
```

## Network and Connectivity

### Firewall Issues
```cmd
# Check Windows Firewall
netsh advfirewall firewall show rule name=all | findstr "8081\|5432\|80"

# Add firewall rules if needed
netsh advfirewall firewall add rule name="Tomcat" dir=in action=allow protocol=TCP localport=8081
netsh advfirewall firewall add rule name="PostgreSQL" dir=in action=allow protocol=TCP localport=5432
```

### Network Connectivity
```cmd
# Test local connectivity
telnet localhost 8081
telnet localhost 5432
telnet localhost 80

# Check routing
route print

# DNS resolution
nslookup localhost
```

### CORS Issues
```java
// Add to your JAX-RS resources
@CrossOrigin(origins = "http://localhost")
@Path("/api")
public class YourResource {
    // Your methods
}
```

## Development Environment Issues

### Java Version Conflicts
```cmd
# Check Java version
java -version
javac -version
echo %JAVA_HOME%

# Check Maven Java version
mvn -version
```

### Path Issues
```cmd
# Check PATH variable
echo %PATH%

# Verify Maven in PATH
where mvn

# Verify Java in PATH
where java
```

### IDE Integration Issues

#### Visual Studio Issues
```cmd
# Reset IIS Express
taskkill /f /im iisexpress.exe
taskkill /f /im w3wp.exe

# Clear ASP.NET temporary files
del /q /s "%WINDOWS%\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*"
```

#### Maven Integration
```cmd
# Refresh Maven dependencies
mvn clean install -U

# Clear Maven cache
rmdir /s /q "%USERPROFILE%\.m2\repository"
```

## Emergency Recovery Procedures

### Complete System Reset
```cmd
# Stop all services
iisreset /stop
taskkill /f /im java.exe
net stop postgresql-x64-14

# Clear temporary files
del /q /s "%TEMP%\*"
del /q /s "%WINDOWS%\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files\*"

# Restart services
net start postgresql-x64-14
iisreset /start

# Rebuild and restart application
cd C:\ecommerce\ecommerce-backend
mvn clean package
mvn tomcat7:run
```

### Database Recovery
```sql
-- Backup database
pg_dump -U ecommerce_user -d ecommerce > backup.sql

-- Restore database
psql -U ecommerce_user -d ecommerce < backup.sql

-- Reset sequences
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
```

## Debugging Checklist

### Before Starting Debugging
- [ ] Check all services are running (PostgreSQL, IIS, Tomcat)
- [ ] Verify network connectivity (ports 80, 8081, 5432)
- [ ] Check log files for recent errors
- [ ] Confirm environment variables (JAVA_HOME, PATH)
- [ ] Test each component individually

### During Debugging
- [ ] Enable detailed logging (debug mode)
- [ ] Use browser developer tools for frontend issues
- [ ] Monitor system resources (CPU, memory)
- [ ] Check database connections and queries
- [ ] Verify API endpoints with curl/Postman

### After Fixing Issues
- [ ] Test complete user workflow
- [ ] Verify all features work end-to-end
- [ ] Check performance under load
- [ ] Update documentation with lessons learned
- [ ] Create backup of working configuration

---

## Support Resources

### Documentation
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [ASP.NET Documentation](https://docs.microsoft.com/en-us/aspnet/)
- [Jersey JAX-RS Documentation](https://eclipse-ee4j.github.io/jersey/)

### Tools
- **Database**: pgAdmin, DBeaver
- **API Testing**: Postman, curl
- **Log Analysis**: Notepad++, PowerShell
- **Performance**: JConsole, PerfMon

### Emergency Contacts
- System Administrator: [Contact Info]
- Database Administrator: [Contact Info]
- Development Team Lead: [Contact Info]

---

*Last Updated: 2025-09-23*  
*Version: 1.0.0*
