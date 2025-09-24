# E-Commerce Application Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the E-Commerce monolithic application with the following architecture:

- **Frontend**: ASP.NET Web Forms (C#)
- **Backend**: Java 8 with JAX-RS REST APIs
- **Application Server**: Apache Tomcat 9.0+
- **Database**: PostgreSQL

## Prerequisites

### Software Requirements

1. **Java Development Kit (JDK) 8**
   - Download from Oracle or use OpenJDK 8
   - Set JAVA_HOME environment variable

2. **Apache Tomcat**
   - Version 9.0 or later
   - With Tomcat Manager (optional)

3. **PostgreSQL Database**
   - Version 12 or later
   - PostgreSQL JDBC Driver

4. **ASP.NET Framework**
   - .NET Framework 4.8
   - IIS (Internet Information Services)

5. **Build Tools**
   - Apache Maven 3.6+
   - Visual Studio or MSBuild

## Database Setup

### 1. Install PostgreSQL

```bash
# On Windows (using installer)
# Download from https://www.postgresql.org/download/windows/

# On Linux (Ubuntu/Debian)
sudo apt update
sudo apt install postgresql postgresql-contrib

# On macOS (using Homebrew)
brew install postgresql
```

### 2. Create Database and User

```sql
-- Connect as postgres superuser
psql -U postgres

-- Create database
CREATE DATABASE ecommerce;

-- Create user
CREATE USER ecommerce_user WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO ecommerce_user;

-- Connect to the database
\c ecommerce

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO ecommerce_user;
```

### 3. Run Database Schema

```bash
# Navigate to database folder
cd ecommerce/database

# Execute schema script
psql -U ecommerce_user -d ecommerce -f schema.sql
```

## Java Backend Deployment

### 1. Build the Application

```bash
# Navigate to backend folder
cd ecommerce/ecommerce-backend

# Clean and build
mvn clean install

# This creates ecommerce-backend.war in target/ folder
```

### 2. Configure Database Connection

Update `src/main/resources/application.properties`:

```properties
# Database Configuration
db.url=jdbc:postgresql://your-db-host:5432/ecommerce
db.username=ecommerce_user
db.password=your_secure_password

# Connection Pool Settings
db.pool.maxSize=20
db.pool.minIdle=5

# JWT Configuration
jwt.secret=your_jwt_secret_key_here
jwt.expiration=86400000
```

### 3. Apache Tomcat Setup

#### Install and Configure Tomcat

1. Download and install Apache Tomcat 9.0+
2. Set CATALINA_HOME environment variable
3. Configure Tomcat users for management (optional):
   ```xml
   <!-- In conf/tomcat-users.xml -->
   <role rolename="manager-gui"/>
   <role rolename="manager-script"/>
   <user username="admin" password="admin123" roles="manager-gui,manager-script"/>
   ```

#### Install PostgreSQL JDBC Driver

1. Download PostgreSQL JDBC driver (postgresql-42.x.x.jar)
2. Copy to Tomcat lib directory:
   ```bash
   cp postgresql-42.x.x.jar $CATALINA_HOME/lib/
   ```

#### Deploy WAR File

**Method 1: Direct Deployment**
```bash
# Copy WAR to webapps directory
cp ecommerce-backend.war $CATALINA_HOME/webapps/

# Tomcat will auto-deploy the application
```

**Method 2: Using Maven Plugin**
```bash
# Configure Maven settings for Tomcat manager
mvn tomcat7:deploy

# Or redeploy if already deployed
mvn tomcat7:redeploy
```

**Method 3: Using Tomcat Manager**
1. Access Tomcat Manager: `http://localhost:8080/manager/html`
2. Upload WAR file through web interface
3. Start the application

#### Configure Application Context (Optional)

Create `$CATALINA_HOME/conf/Catalina/localhost/ecommerce-backend.xml`:
```xml
<Context>
    <Parameter name="db.url" value="jdbc:postgresql://localhost:5432/ecommerce"/>
    <Parameter name="db.username" value="ecommerce_user"/>
    <Parameter name="db.password" value="your_secure_password"/>
</Context>
```

### 4. Verify Backend Deployment

Test API endpoints:

```bash
# Test health check
curl http://your-tomcat-host:8080/ecommerce-backend/api/products

# Test user registration
curl -X POST http://your-tomcat-host:8080/ecommerce-backend/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123","firstName":"Test","lastName":"User"}'
```

## ASP.NET Frontend Deployment

### 1. Configure API Connection

Update `Web.config`:

```xml
<appSettings>
  <!-- API Configuration -->
  <add key="ApiBaseUrl" value="http://your-tomcat-host:8080/ecommerce-backend/api" />
  <add key="ApiTimeout" value="30000" />
  
  <!-- JWT Settings -->
  <add key="JwtTokenKey" value="ecommerce_jwt_token" />
</appSettings>
```

### 2. Build and Deploy to IIS

#### Option A: Visual Studio Publish

1. Open project in Visual Studio
2. Right-click project → **Publish**
3. Choose **IIS, FTP, etc.**
4. Configure publish profile:
   - **Server**: Your IIS server
   - **Site name**: `Default Web Site/ecommerce-ui`
   - **Destination URL**: `http://your-iis-host/ecommerce-ui`

#### Option B: Manual Deployment

1. Build the application:
   ```bash
   msbuild ecommerce-ui.sln /p:Configuration=Release
   ```

2. Copy files to IIS:
   ```bash
   # Copy all files to IIS wwwroot
   xcopy /s /e ecommerce-ui\* C:\inetpub\wwwroot\ecommerce-ui\
   ```

3. Configure IIS Application:
   - Open IIS Manager
   - Create new application under Default Web Site
   - Alias: `ecommerce-ui`
   - Physical path: `C:\inetpub\wwwroot\ecommerce-ui`
   - Application pool: `.NET v4.0`

### 3. Configure Application Pool

1. In IIS Manager:
   - **Application Pools** → Select your app pool
   - **Advanced Settings**:
     - **.NET CLR Version**: `v4.0`
     - **Managed Pipeline Mode**: `Integrated`
     - **Identity**: `ApplicationPoolIdentity`

## Security Configuration

### 1. HTTPS Setup (Recommended)

#### Tomcat HTTPS

1. Generate or obtain SSL certificate
2. Configure HTTPS connector in server.xml:
   ```xml
   <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
              maxThreads="150" SSLEnabled="true">
       <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" />
       <SSLHostConfig>
           <Certificate certificateKeystoreFile="conf/keystore.jks"
                        type="RSA" />
       </SSLHostConfig>
   </Connector>
   ```

#### IIS HTTPS

1. Obtain SSL certificate
2. In IIS Manager:
   - Select site → **Bindings** → **Add**
   - Type: `https`
   - Port: `443`
   - SSL certificate: Select your certificate

### 2. Firewall Configuration

Open required ports:
- **Tomcat**: 8080 (HTTP), 8443 (HTTPS)
- **IIS**: 80 (HTTP), 443 (HTTPS)
- **PostgreSQL**: 5432 (database access)

## Monitoring and Maintenance

### 1. Log Files

#### Tomcat Logs
- Location: `$CATALINA_HOME/logs/`
- Key files: `catalina.out`, `localhost.log`, `manager.log`

#### IIS Logs
- Location: `C:\inetpub\logs\LogFiles\W3SVC1\`
- Format: W3C Extended Log Format

#### PostgreSQL Logs
- Location: PostgreSQL data directory
- File: `postgresql.log`

### 2. Performance Monitoring

#### Tomcat
- Use Tomcat Manager for application monitoring
- Monitor JVM heap usage with JConsole or VisualVM
- Configure connection pools in context.xml

#### IIS
- Use Performance Monitor (perfmon)
- Monitor ASP.NET performance counters

#### Database
- Monitor PostgreSQL with pg_stat_activity
- Use pgAdmin for database monitoring

### 3. Backup Strategy

#### Database Backup
```bash
# Daily backup script
pg_dump -U ecommerce_user -h localhost ecommerce > backup_$(date +%Y%m%d).sql

# Restore from backup
psql -U ecommerce_user -d ecommerce < backup_20241201.sql
```

#### Application Backup
- Backup Tomcat configuration and applications
- Backup IIS configuration and web files

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check PostgreSQL service is running
   - Verify connection string and credentials
   - Test network connectivity

2. **API Not Responding**
   - Check Tomcat application status in manager
   - Review catalina.out and localhost.log for errors
   - Verify database connection configuration

3. **Frontend Can't Connect to API**
   - Check CORS configuration
   - Verify API base URL in Web.config
   - Test API endpoints directly

4. **Authentication Issues**
   - Verify JWT secret key matches between frontend and backend
   - Check token expiration settings
   - Review authentication logs

### Performance Optimization

1. **Database**
   - Add indexes for frequently queried columns
   - Configure connection pooling
   - Regular VACUUM and ANALYZE

2. **Tomcat**
   - Tune JVM heap size (-Xmx, -Xms)
   - Configure connection pool sizes in context.xml
   - Enable application caching
   - Optimize Tomcat connectors

3. **IIS**
   - Enable output caching
   - Configure compression
   - Optimize static content delivery

## Production Checklist

- [ ] Database backup strategy implemented
- [ ] SSL certificates configured
- [ ] Firewall rules configured
- [ ] Monitoring tools set up
- [ ] Log rotation configured
- [ ] Performance baselines established
- [ ] Security patches applied
- [ ] Load testing completed
- [ ] Disaster recovery plan documented
- [ ] Operations team trained

## Support

For technical support:
- Review application logs first
- Check database connectivity
- Verify configuration files
- Test API endpoints independently
- Monitor system resources

## Version History

- **v1.0.0** - Initial release with core e-commerce functionality
- Authentication and user management
- Product catalog and search
- Shopping cart functionality
- Order processing system
