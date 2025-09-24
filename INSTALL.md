# E-Commerce Application Installation Guide

## Overview

This guide provides complete installation instructions for a full-stack e-commerce application with the following architecture:

```
ASP.NET Web Forms Frontend (IIS)
        ↕ HTTP/REST API Calls
JAX-RS Backend (Apache Tomcat)
        ↕ JDBC
PostgreSQL Database
```

### Technology Stack
- **Frontend**: ASP.NET Web Forms (.NET Framework 4.8) on IIS
- **Backend**: Java 8 with JAX-RS (Jersey) on Apache Tomcat 9.0+
- **Database**: PostgreSQL 14+
- **Build Tools**: Maven 3.8+
- **Authentication**: JWT tokens with BCrypt password hashing

### Key Features
- User registration and authentication
- Product catalog with search and filtering
- Shopping cart functionality
- Order management system
- Admin dashboard capabilities
- Responsive Bootstrap UI

## Quick Start (For Experienced Developers)

If you're familiar with the technology stack, here's the essential setup:

1. **Install Prerequisites**: JDK 8, PostgreSQL, Tomcat 9, Maven, IIS with ASP.NET
2. **Database**: Run `database/schema.sql` and `database/sample-data.sql`
3. **Backend**: `cd ecommerce-backend && mvn tomcat7:run` (NOT spring-boot:run)
4. **Frontend**: Deploy `ecommerce-ui` to IIS, update Web.config API URL
5. **Access**: Frontend at `http://localhost/ecommerce-ui`, Backend at `http://localhost:8080/ecommerce-backend/api`

⚠️ **Common Pitfalls**: This is JAX-RS (not Spring Boot), requires .NET Framework 4.8 compatibility fixes, and needs specific IIS feature enablement order.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Database Installation](#database-installation)
4. [Java Backend Setup](#java-backend-setup)
5. [Apache Tomcat Configuration](#apache-tomcat-configuration)
6. [ASP.NET Frontend Setup](#aspnet-frontend-setup)
7. [Running the Application](#running-the-application)
8. [Application Testing](#application-testing)
9. [Troubleshooting](#troubleshooting)
10. [Performance Optimization](#performance-optimization)
11. [Next Steps](#next-steps)

## Prerequisites

### System Requirements
- **Operating System**: Windows Server 2016+ or Windows 10+
- **RAM**: Minimum 8GB, Recommended 16GB+
- **Storage**: 20GB free space
- **Network**: Internet connection for downloading components

### Required Software Downloads
Before starting, download the following:

1. **Java Development Kit 8**
   - Download: [Oracle JDK 8](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html) or [OpenJDK 8](https://adoptium.net/temurin/releases/?version=8)

2. **PostgreSQL Database**
   - Download: [PostgreSQL 14+](https://www.postgresql.org/download/windows/)

3. **Apache Tomcat**
   - Download: [Apache Tomcat 9.0+](https://tomcat.apache.org/download-90.cgi)

4. **Apache Maven**
   - Download: [Maven 3.8+](https://maven.apache.org/download.cgi)

5. **Visual Studio or Build Tools**
   - Download: [Visual Studio Community](https://visualstudio.microsoft.com/downloads/) or [Build Tools for Visual Studio](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)

## Environment Setup

### Step 1: Install Java Development Kit 8

1. **Run the JDK installer**
   ```cmd
   # Example installation path
   C:\Program Files\Java\jdk1.8.0_XXX\
   ```

2. **Set JAVA_HOME environment variable**
   ```cmd
   # Open Command Prompt as Administrator
   setx JAVA_HOME "C:\Program Files\Java\jdk1.8.0_XXX" /M
   setx PATH "%JAVA_HOME%\bin;%PATH%" /M
   ```

3. **Verify Java installation**
   ```cmd
   java -version
   javac -version
   ```
   Expected output: `java version "1.8.0_XXX"`

### Step 2: Install Apache Maven

1. **Extract Maven to a directory**
   ```cmd
   # Extract to: C:\Program Files\Apache\maven\
   ```

2. **Set Maven environment variables**
   ```cmd
   setx MAVEN_HOME "C:\Program Files\Apache\maven" /M
   setx PATH "%MAVEN_HOME%\bin;%PATH%" /M
   ```

3. **Verify Maven installation**
   ```cmd
   mvn -version
   ```

### Step 3: Install Git (if not already installed)

1. **Download and install Git**
   - Download: [Git for Windows](https://git-scm.com/download/win)

2. **Verify Git installation**
   ```cmd
   git --version
   ```

## Database Installation

### Step 1: Install PostgreSQL

1. **Run PostgreSQL installer**
   - Choose installation directory: `C:\Program Files\PostgreSQL\14\`
   - Set superuser password (remember this!)
   - Port: `5432` (default)
   - Locale: `Default locale`

2. **Verify PostgreSQL installation**
   ```cmd
   # Add PostgreSQL to PATH
   setx PATH "C:\Program Files\PostgreSQL\14\bin;%PATH%" /M
   
   # Test connection
   psql --version
   ```

### Step 2: Create Database and User

1. **Connect to PostgreSQL as superuser**
   ```cmd
   psql -U postgres -h localhost
   ```

2. **Create database and user**
   ```sql
   -- Create the database
   CREATE DATABASE ecommerce;
   
   -- Create user with password
   CREATE USER ecommerce_user WITH PASSWORD 'ecommerce123';
   
   -- Grant privileges
   GRANT ALL PRIVILEGES ON DATABASE ecommerce TO ecommerce_user;
   
   -- Exit psql
   \q
   ```

### Step 3: Initialize Database Schema

1. **Navigate to the database folder**
   ```cmd
   cd C:\ecommerce\database
   ```

2. **Execute the schema script**
   ```cmd
   psql -U ecommerce_user -d ecommerce -h localhost -f schema.sql
   ```

3. **Verify database setup**
   ```cmd
   psql -U ecommerce_user -d ecommerce -h localhost
   ```
   ```sql
   -- Check tables
   \dt
   
   -- Check sample data
   SELECT COUNT(*) FROM products;
   SELECT COUNT(*) FROM users;
   
   -- Exit
   \q
   ```

## Java Backend Setup

### Step 1: Configure Database Connection

1. **Navigate to backend resources folder**
   ```cmd
   cd C:\ecommerce\ecommerce-backend\src\main\resources
   ```

2. **Edit application.properties**
   ```properties
   # Database Configuration
   db.url=jdbc:postgresql://localhost:5432/ecommerce
   db.username=ecommerce_user
   db.password=ecommerce123
   
   # Connection Pool Settings
   db.pool.maxSize=20
   db.pool.minIdle=5
   db.pool.connectionTimeout=30000
   db.pool.idleTimeout=600000
   db.pool.maxLifetime=1800000
   
   # JWT Configuration (Change this in production!)
   jwt.secret=mySecretKey123456789012345678901234567890
   jwt.expiration=86400000
   jwt.issuer=ecommerce-app
   
   # Application Settings
   app.name=E-Commerce Backend
   app.version=1.0.0
   app.environment=development
   ```

### Step 2: Build the Java Application

1. **Navigate to backend folder**
   ```cmd
   cd C:\ecommerce\ecommerce-backend
   ```

2. **Clean and build with Maven**
   ```cmd
   mvn clean compile
   mvn test
   mvn package
   ```

3. **Verify build success**
   ```cmd
   # Check if WAR file is created
   dir target\*.war
   ```
   You should see: `ecommerce-backend.war`

## Apache Tomcat Configuration

### Step 1: Install Apache Tomcat

1. **Download and extract Tomcat**
   ```cmd
   # Extract to: C:\Program Files\Apache\Tomcat\9.0
   # Or use the Windows installer
   ```

2. **Set CATALINA_HOME environment variable**
   ```cmd
   setx CATALINA_HOME "C:\Program Files\Apache\Tomcat\9.0" /M
   setx PATH "%CATALINA_HOME%\bin;%PATH%" /M
   ```

3. **Start Tomcat**
   ```cmd
   cd "C:\Program Files\Apache\Tomcat\9.0\bin"
   startup.bat
   ```

4. **Verify Tomcat is running**
   - Open browser: `http://localhost:8080`
   - Should show Tomcat welcome page

### Step 2: Configure Tomcat for E-Commerce Application

1. **Copy PostgreSQL JDBC Driver**
   ```cmd
   # Download PostgreSQL JDBC driver
   # Copy to Tomcat lib directory
   copy postgresql-42.5.1.jar "C:\Program Files\Apache\Tomcat\9.0\lib\"
   ```

2. **Configure Tomcat Users (for management)**
   ```cmd
   # Copy sample configuration
   copy C:\ecommerce\deployment\tomcat\tomcat-users.xml "C:\Program Files\Apache\Tomcat\9.0\conf\"
   ```

3. **Configure Server Settings (optional)**
   ```cmd
   # Backup original server.xml
   copy "C:\Program Files\Apache\Tomcat\9.0\conf\server.xml" "C:\Program Files\Apache\Tomcat\9.0\conf\server.xml.backup"
   
   # You can reference the sample server.xml in deployment/tomcat/
   ```

### Step 3: Deploy Application to Tomcat

1. **Build the WAR file**
   ```cmd
   cd C:\ecommerce\ecommerce-backend
   mvn clean package
   ```

2. **Deploy WAR file to Tomcat**
   ```cmd
   # Method 1: Copy WAR to webapps directory
   copy target\ecommerce-backend.war "C:\Program Files\Apache\Tomcat\9.0\webapps\"
   
   # Method 2: Use Maven Tomcat plugin (if Tomcat manager is configured)
   mvn tomcat7:deploy
   ```

3. **Configure Application Context (optional)**
   ```cmd
   # Copy context configuration
   mkdir "C:\Program Files\Apache\Tomcat\9.0\conf\Catalina\localhost"
   copy C:\ecommerce\deployment\tomcat\context.xml "C:\Program Files\Apache\Tomcat\9.0\conf\Catalina\localhost\ecommerce-backend.xml"
   ```

4. **Restart Tomcat**
   ```cmd
   cd "C:\Program Files\Apache\Tomcat\9.0\bin"
   shutdown.bat
   startup.bat
   ```

5. **Verify Deployment**
   ```cmd
   # Test API endpoint
   curl http://localhost:8080/ecommerce-backend/api/products
   ```

### Step 4: Configure Tomcat Manager (Optional)

1. **Enable Tomcat Manager**
   - The tomcat-users.xml file already includes manager configuration
   - Access manager at: `http://localhost:8080/manager/html`
   - Login with: username `admin`, password `admin123`

2. **Using Manager for Deployment**
   - Upload WAR files through the web interface
   - Start/stop applications
   - Monitor application status

## ASP.NET Frontend Setup

### Step 1: Install IIS and ASP.NET

1. **Enable IIS on Windows**
   ```cmd
   # Open PowerShell as Administrator
   
   # Step 1: Enable basic IIS features
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-HttpLogging, IIS-RequestFiltering, IIS-StaticContent, IIS-DefaultDocument, IIS-DirectoryBrowsing
   
   # Step 2: Enable .NET Framework features (required for ASP.NET)
   Enable-WindowsOptionalFeature -Online -FeatureName NetFx4Extended-ASPNET45
   
   # Step 3: Enable ASP.NET features
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-AspNet45
   ```

   **Important Notes:**
   - Commands must be run in the exact order shown above
   - Each command may require a system restart when prompted
   - If you get "parent features are disabled" error, ensure previous steps completed successfully

2. **Verify IIS installation**
   - Open browser: `http://localhost`
   - Should show IIS welcome page

### Step 2: Configure ASP.NET Application

1. **Update Web.config**
   ```cmd
   cd C:\ecommerce\ecommerce-ui
   notepad Web.config
   ```

2. **Update API configuration**
   ```xml
   <appSettings>
     <!-- Application Settings -->
     <add key="AppName" value="E-Commerce Application" />
     <add key="AppVersion" value="1.0.0" />
     <add key="Environment" value="Development" />
     
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
   ```

3. **Complete Web.config for .NET Framework 4.8 Compatibility**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <configuration>
     <appSettings>
       <!-- Application Settings -->
       <add key="AppName" value="E-Commerce Application" />
       <add key="AppVersion" value="1.0.0" />
       <add key="Environment" value="Development" />
       
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
       <!-- Compilation settings -->
       <compilation debug="true" targetFramework="4.8" />
       
       <!-- HTTP Runtime settings -->
       <httpRuntime targetFramework="4.8" />
       
       <!-- Authentication -->
       <authentication mode="Forms">
         <forms loginUrl="~/Account/Login.aspx" timeout="30" />
       </authentication>
       
       <!-- Authorization -->
       <authorization>
         <allow users="*" />
       </authorization>
       
       <!-- Session State -->
       <sessionState mode="InProc" timeout="30" />
       
       <!-- Custom Errors -->
       <customErrors mode="Off" />
     </system.web>

     <system.webServer>
       <!-- Default Documents -->
       <defaultDocument>
         <files>
           <clear />
           <add value="Default.aspx" />
         </files>
       </defaultDocument>
     </system.webServer>
   </configuration>
   ```

### Step 3: Prepare ASP.NET Web Site

**Note**: This is an ASP.NET Web Site project (not Web Application), so no compilation is required.

1. **Using Visual Studio (Optional)**
   ```cmd
   # Open the website folder directly
   "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" C:\ecommerce\ecommerce-ui
   
   # Or use File → Open → Web Site in Visual Studio
   ```

2. **Verify Web.config Settings**
   ```cmd
   cd C:\ecommerce\ecommerce-ui
   notepad Web.config
   ```
   
   Ensure the API URL is correct:
   ```xml
   <add key="ApiBaseUrl" value="http://localhost:8080/ecommerce-backend/api" />
   ```

### Step 4: Deploy to IIS

1. **Create IIS Application**
   ```cmd
   # Open IIS Manager
   inetmgr
   ```

2. **Configure IIS Site**
   - Right-click **Default Web Site** → **Add Application**
   - Alias: `ecommerce-ui`
   - Physical path: `C:\ecommerce\ecommerce-ui`
   - Application pool: `DefaultAppPool` (or create new with .NET Framework v4.0)

3. **Set Application Pool**
   - Go to **Application Pools**
   - Select the pool used by your application
   - **Advanced Settings**:
     - .NET CLR Version: `v4.0`
     - Managed Pipeline Mode: `Integrated`
     - Identity: `ApplicationPoolIdentity`

4. **Set Permissions**
   ```cmd
   # Grant IIS_IUSRS permission to application folder
   icacls "C:\ecommerce\ecommerce-ui" /grant IIS_IUSRS:(OI)(CI)F
   ```

## Running the Application

### Step 1: Start the Backend (Java/Tomcat)

**Important**: This is a JAX-RS application, NOT Spring Boot. Use these commands:

1. **Build the application**
   ```cmd
   cd C:\ecommerce\ecommerce-backend
   mvn clean compile
   mvn package
   ```

2. **Deploy to Tomcat (Method 1 - Manual)**
   ```cmd
   # Copy WAR file to Tomcat webapps
   copy target\ecommerce-backend.war "C:\Program Files\Apache\Tomcat\9.0\webapps\"
   
   # Start Tomcat
   cd "C:\Program Files\Apache\Tomcat\9.0\bin"
   startup.bat
   ```

3. **Deploy using Maven Tomcat Plugin (Method 2)**
   ```cmd
   cd C:\ecommerce\ecommerce-backend
   
   # Deploy to running Tomcat (requires manager app)
   mvn tomcat7:deploy
   
   # Or redeploy if already deployed
   mvn tomcat7:redeploy
   ```

4. **Run with embedded Tomcat (Method 3 - Development)**
   ```cmd
   cd C:\ecommerce\ecommerce-backend
   mvn tomcat7:run
   ```

### Step 2: Verify Backend is Running

1. **Check if Tomcat is listening on port 8080**
   ```cmd
   netstat -an | findstr :8080
   ```

2. **Test basic endpoints**
   ```cmd
   # Get all products
   curl http://localhost:8080/ecommerce-backend/api/products
   
   # Test user registration
   curl -X POST http://localhost:8080/ecommerce-backend/api/users/register ^
        -H "Content-Type: application/json" ^
        -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"password123\",\"firstName\":\"Test\",\"lastName\":\"User\"}"
   
   # Test user login
   curl -X POST http://localhost:8080/ecommerce-backend/api/users/login ^
        -H "Content-Type: application/json" ^
        -d "{\"username\":\"testuser\",\"password\":\"password123\"}"
   ```

### Step 2: Test Frontend Application

1. **Access the application**
   - Open browser: `http://localhost/ecommerce-ui`
   - Should show the home page with products

2. **Test user registration**
   - Navigate to: `http://localhost/ecommerce-ui/Account/Register.aspx`
   - Create a new user account

3. **Test user login**
   - Navigate to: `http://localhost/ecommerce-ui/Account/Login.aspx`
   - Login with demo credentials:
     - Username: `admin`, Password: `admin123`
     - Username: `johndoe`, Password: `user123`

4. **Test product browsing**
   - Navigate to: `http://localhost/ecommerce-ui/Products.aspx`
   - Test search and filtering functionality

### Step 3: End-to-End Testing

1. **Complete user flow**
   - Register new user
   - Login
   - Browse products
   - Add products to cart
   - View cart
   - Place order (if implemented)

## Troubleshooting

### Common Issues and Solutions

#### 1. Database Connection Issues

**Problem**: Cannot connect to PostgreSQL
```
Solution:
1. Check if PostgreSQL service is running:
   services.msc → PostgreSQL Database Server
2. Verify connection string in application.properties
3. Test manual connection:
   psql -U ecommerce_user -d ecommerce -h localhost
```

#### 2. Tomcat Deployment Issues

**Problem**: Application fails to start
```
Solution:
1. Check Tomcat logs:
   C:\Program Files\Apache\Tomcat\9.0\logs\catalina.out
   C:\Program Files\Apache\Tomcat\9.0\logs\localhost.log
2. Verify JDBC driver is in Tomcat lib directory
3. Check application context configuration
4. Verify WAR file deployment in webapps directory
```

#### 3. ASP.NET Configuration Issues

**Problem**: Cannot connect to backend API
```
Solution:
1. Verify API base URL in Web.config (should be http://localhost:8080/ecommerce-backend/api)
2. Check if Tomcat is running and accessible
3. Test API endpoints directly with curl
4. Check CORS configuration in backend
5. Verify application is deployed and started in Tomcat manager
```

#### 4. Build Issues

**Problem**: Maven build fails
```
Solution:
1. Check Java version: java -version
2. Verify Maven installation: mvn -version
3. Clear Maven cache: mvn clean
4. Check internet connection for dependencies
```

**Problem**: "No plugin found for prefix 'spring-boot'"
```
Error: [ERROR] No plugin found for prefix 'spring-boot' in the current project

Solution:
This is NOT a Spring Boot project! It's a JAX-RS application for Tomcat.
Use these commands instead:

1. Build the application:
   mvn clean compile
   mvn package

2. Run with embedded Tomcat:
   mvn tomcat7:run

3. Or deploy to standalone Tomcat:
   copy target\ecommerce-backend.war "C:\Program Files\Apache\Tomcat\9.0\webapps\"
   
DO NOT use: mvn spring-boot:run (this will fail)
```

**Problem**: "Address already in use: JVM_Bind :8080"
```
Error: java.net.BindException: Address already in use: JVM_Bind <null>:8080

Solution:
1. Find the process using port 8080:
   netstat -ano | findstr :8080

2. Kill the conflicting process:
   taskkill /PID <PID_NUMBER> /F
   
   Example: If PID is 13100:
   taskkill /PID 13100 /F

3. Verify port is free:
   netstat -ano | findstr :8080
   (Should return no results)

4. Restart your application:
   mvn tomcat7:run
```

**Problem**: Context path mismatch (/ecommerce vs /ecommerce-backend)
```
Error: Frontend can't connect to API, wrong URL path

Solution:
1. Update pom.xml Tomcat plugin configuration:
   <path>/ecommerce-backend</path>

2. Or update frontend Web.config to match actual path:
   <add key="ApiBaseUrl" value="http://localhost:8080/ecommerce/api" />
```

#### 5. Quick Troubleshooting Reference

**Most Common Issues:**

| Error | Quick Fix |
|-------|-----------|
| `spring-boot plugin not found` | Use `mvn tomcat7:run` instead |
| `CS1056: Unexpected character '$'` | Replace `$"{var}"` with `"" + var` |
| `CS0234: HttpClient not found` | Replace with WebClient |
| `CS0246: Newtonsoft not found` | Use JavaScriptSerializer |
| `HTTP 500.19 Configuration Error` | Enable IIS features in correct order |
| `ERR_TOO_MANY_REDIRECTS` | Check backend is running on port 8080 |
| `Connection refused :8080` | Start Tomcat: `mvn tomcat7:run` |
| `Address already in use :8080` | Kill existing process: `taskkill /PID <PID> /F` |
| `Database connection failed` | Check PostgreSQL service is running |

**Port Check Commands:**
```cmd
# Check if services are running
netstat -an | findstr ":8080"  # Tomcat
netstat -an | findstr ":80"    # IIS
netstat -an | findstr ":5432"  # PostgreSQL
```

#### 6. ASP.NET Compilation Errors

**Problem**: HTTP 500.19 - Internal Server Error (Configuration Error)
```
Error: "One or several parent features are disabled so current feature can not be enabled"

Solution:
1. Enable IIS features in correct order:
   # Step 1: Enable basic IIS features
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-HttpLogging, IIS-RequestFiltering, IIS-StaticContent, IIS-DefaultDocument, IIS-DirectoryBrowsing
   
   # Step 2: Enable .NET Framework features (required for ASP.NET)
   Enable-WindowsOptionalFeature -Online -FeatureName NetFx4Extended-ASPNET45
   
   # Step 3: Enable ASP.NET features
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-AspNet45

2. If Web.config has configuration conflicts, simplify it:
   - Remove complex handlers and modules
   - Remove EntityFramework configSections if not needed
   - Remove duplicate connectionStrings
   - Set customErrors mode="Off" for debugging
```

**Problem**: C# Compilation Errors (CS1056, CS0234, CS0246)
```
Common Issues and Solutions:

1. String Interpolation Error (CS1056: Unexpected character '$'):
   Problem: Using C# 6.0+ string interpolation in .NET Framework 4.8
   Fix: Replace $"{variable}" with string concatenation
   Example: $"{name} {age}" → name + " " + age

2. HttpClient Not Found (CS0234):
   Problem: System.Net.Http not available in older .NET Framework
   Fix: Replace HttpClient with WebClient
   - Change: using System.Net.Http;
   - To: using System.Net;
   - Replace: HttpClient → WebClient
   - Replace: GetAsync() → DownloadString()
   - Replace: PostAsync() → UploadString()

3. Newtonsoft.Json Not Found (CS0246):
   Problem: External JSON library not available
   Fix: Use built-in JavaScriptSerializer
   - Change: using Newtonsoft.Json;
   - To: using System.Web.Script.Serialization;
   - Replace: JsonConvert.SerializeObject() → new JavaScriptSerializer().Serialize()
   - Replace: JsonConvert.DeserializeObject<T>() → new JavaScriptSerializer().Deserialize<T>()

4. Expression-Bodied Properties (CS1002):
   Problem: Using C# 6.0+ syntax
   Fix: Convert to traditional property syntax
   Example: public string Name => FirstName + " " + LastName;
   To: public string Name { get { return FirstName + " " + LastName; } }

5. Async/Await Issues:
   Problem: Using async/await with incompatible methods
   Fix: Remove async/await and use synchronous methods
   - Remove: async from method signatures
   - Remove: await from method calls
   - Change: GetAsync<T>() → Get<T>()
   - Change: PostAsync<T>() → Post<T>()
```

**Problem**: ERR_TOO_MANY_REDIRECTS
```
Solution:
1. Check if backend API is running:
   netstat -an | findstr :8080
   
2. Verify API URL in Web.config:
   <add key="ApiBaseUrl" value="http://localhost:8080/ecommerce-backend/api" />
   
3. Test API endpoints directly:
   curl http://localhost:8080/ecommerce-backend/api/products
   
4. Check for infinite redirect loops in authentication logic
5. Ensure Default.aspx can handle API connection failures gracefully
```

**Problem**: ASP.NET build fails
```
Solution:
1. Check .NET Framework version
2. Verify Visual Studio/MSBuild installation
3. Check for missing NuGet packages
4. Rebuild solution: Build → Rebuild Solution
```

### Performance Optimization

1. **Database Performance**
   ```sql
   -- Check database performance
   SELECT * FROM pg_stat_activity;
   
   -- Analyze tables
   ANALYZE;
   ```

2. **Tomcat Performance**
   - Monitor JVM heap usage via JConsole or Tomcat manager
   - Adjust connection pool sizes in context.xml
   - Configure Tomcat connector settings
   - Enable application caching

3. **IIS Performance**
   - Enable output caching
   - Configure compression
   - Monitor application pool recycling

### Log File Locations

1. **PostgreSQL Logs**
   ```
   C:\Program Files\PostgreSQL\14\data\log\
   ```

2. **Tomcat Logs**
   ```
   C:\Program Files\Apache\Tomcat\9.0\logs\
   ```

3. **IIS Logs**
   ```
   C:\inetpub\logs\LogFiles\W3SVC1\
   ```

4. **Application Event Logs**
   ```
   Windows Event Viewer → Windows Logs → Application
   ```

## Deployment Checklist

Use this checklist to verify your installation is complete:

### ✅ **Environment Setup**
- [ ] JDK 8 installed and JAVA_HOME set
- [ ] PostgreSQL 14+ installed and running
- [ ] Apache Tomcat 9.0+ installed
- [ ] Maven 3.8+ installed and in PATH
- [ ] IIS with ASP.NET 4.8 features enabled

### ✅ **Database Configuration**
- [ ] PostgreSQL service running (services.msc)
- [ ] Database `ecommerce` created
- [ ] User `ecommerce_user` created with proper permissions
- [ ] Schema tables created (products, users, orders, etc.)
- [ ] Sample data loaded successfully
- [ ] Connection test successful: `psql -U ecommerce_user -d ecommerce -h localhost`

### ✅ **Backend Verification**
- [ ] Maven build successful: `mvn clean package`
- [ ] WAR file generated: `target/ecommerce-backend.war`
- [ ] Tomcat running on port 8080: `netstat -an | findstr :8080`
- [ ] API endpoints responding: `curl http://localhost:8080/ecommerce-backend/api/products`
- [ ] Database connection working (check Tomcat logs)

### ✅ **Frontend Verification**
- [ ] IIS application pool created and running
- [ ] Web.config properly configured with correct API URL
- [ ] ASP.NET compilation successful (no CS errors)
- [ ] Default.aspx loads without errors
- [ ] Frontend can communicate with backend API

### ✅ **Integration Testing**
- [ ] User registration works
- [ ] User login returns JWT token
- [ ] Product catalog displays
- [ ] Shopping cart functionality works
- [ ] No infinite redirect loops
- [ ] Error handling works gracefully

### ✅ **Security & Performance**
- [ ] JWT authentication working
- [ ] Password hashing enabled (BCrypt)
- [ ] CORS configured properly
- [ ] Connection pooling active
- [ ] Appropriate error messages (no sensitive data exposed)

## Final Verification Commands

Run these commands to verify everything is working:

```cmd
# Check all services are running
netstat -an | findstr ":8080 :80 :5432"

# Test backend API
curl http://localhost:8080/ecommerce-backend/api/products
curl http://localhost:8080/ecommerce-backend/api/categories

# Test database connection
psql -U ecommerce_user -d ecommerce -c "SELECT COUNT(*) FROM products;"

# Check IIS application
# Open browser: http://localhost/ecommerce-ui
```

## Next Steps

After successful installation:

1. **Security Hardening**
   - Change default passwords
   - Configure SSL certificates
   - Set up firewall rules
   - Review security settings

2. **Production Configuration**
   - Update connection strings for production database
   - Configure load balancing (if needed)
   - Set up monitoring and alerting
   - Configure backup strategies

3. **Additional Features**
   - Implement remaining pages (Cart, Checkout, Orders)
   - Add email notifications
   - Implement payment processing
   - Add admin dashboard

## Support

### Getting Help

If you encounter issues during installation:

1. **Check the Quick Troubleshooting Reference** (Section 5 above)
2. **Review log files** for detailed error messages:
   - Tomcat: `C:\Program Files\Apache\Tomcat\9.0\logs\catalina.out`
   - IIS: `C:\inetpub\logs\LogFiles\W3SVC1\`
   - PostgreSQL: `C:\Program Files\PostgreSQL\14\data\log\`
3. **Verify prerequisites** are properly installed and configured
4. **Test components individually** before integration
5. **Use the Deployment Checklist** to ensure nothing was missed

### Common Resolution Steps

1. **Restart services** in this order: PostgreSQL → Tomcat → IIS
2. **Clear browser cache** if frontend issues persist
3. **Check Windows Firewall** settings for blocked ports
4. **Verify file permissions** on application directories
5. **Run commands as Administrator** when needed

### Useful Diagnostic Commands

```cmd
# Check Java installation
java -version
javac -version
echo %JAVA_HOME%

# Check Maven installation
mvn -version

# Check PostgreSQL service
sc query postgresql-x64-14

# Check IIS application pools
%windir%\system32\inetsrv\appcmd list apppool

# Test network connectivity
telnet localhost 8080
telnet localhost 5432
```

---

## 🎉 **Installation Complete!**

Your E-Commerce application should now be running at:

| Component | URL | Purpose |
|-----------|-----|---------|
| **Frontend** | `http://localhost/ecommerce-ui` | Main application interface |
| **Backend API** | `http://localhost:8080/ecommerce-backend/api` | REST API endpoints |
| **Tomcat Manager** | `http://localhost:8080/manager/html` | Application management |
| **Database** | `localhost:5432/ecommerce` | PostgreSQL database |

### Test Your Installation

1. **Open Frontend**: Navigate to `http://localhost/ecommerce-ui`
2. **Browse Products**: Should display product catalog
3. **Register User**: Create a new account
4. **Login**: Test authentication
5. **Add to Cart**: Test shopping cart functionality

**Congratulations!** You have successfully deployed a full-stack e-commerce application! 🚀

---

*Last Updated: 2025-09-23*  
*Version: 1.0.0*
