# WebSphere to Tomcat Migration Guide

## Overview

This document outlines the migration process from IBM WebSphere Application Server to Apache Tomcat for the E-Commerce application. The migration was completed successfully with minimal code changes due to the application's well-designed architecture.

## Migration Summary

### Before (WebSphere)
- **Application Server**: IBM WebSphere Application Server 9.0+
- **JAX-RS**: Provided by WebSphere runtime
- **Deployment**: WebSphere Admin Console
- **Port**: 9080 (HTTP), 9443 (HTTPS)
- **Context Path**: `/ecommerce`
- **JNDI**: Used for some configurations
- **Cost**: Commercial license required

### After (Tomcat)
- **Application Server**: Apache Tomcat 9.0+
- **JAX-RS**: Jersey implementation (added as dependency)
- **Deployment**: WAR file to webapps directory
- **Port**: 8080 (HTTP), 8443 (HTTPS)
- **Context Path**: `/ecommerce-backend`
- **JNDI**: Eliminated (using HikariCP directly)
- **Cost**: Open source, no licensing fees

## Technical Changes Made

### 1. Maven Dependencies (pom.xml)

**Added Jersey JAX-RS Implementation:**
```xml
<!-- Jersey JAX-RS Implementation for Tomcat -->
<dependency>
    <groupId>org.glassfish.jersey.core</groupId>
    <artifactId>jersey-server</artifactId>
    <version>2.29.1</version>
</dependency>
<dependency>
    <groupId>org.glassfish.jersey.containers</groupId>
    <artifactId>jersey-container-servlet</artifactId>
    <version>2.29.1</version>
</dependency>
<dependency>
    <groupId>org.glassfish.jersey.inject</groupId>
    <artifactId>jersey-hk2</artifactId>
    <version>2.29.1</version>
</dependency>
<dependency>
    <groupId>org.glassfish.jersey.media</groupId>
    <artifactId>jersey-media-json-jackson</artifactId>
    <version>2.29.1</version>
</dependency>
```

**Added Tomcat Maven Plugin:**
```xml
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <url>http://localhost:8080/manager/text</url>
        <server>tomcat</server>
        <path>/ecommerce</path>
    </configuration>
</plugin>
```

### 2. Web Application Configuration (web.xml)

**Added Jersey Servlet Configuration:**
```xml
<!-- Jersey JAX-RS Configuration -->
<servlet>
    <servlet-name>Jersey REST Service</servlet-name>
    <servlet-class>org.glassfish.jersey.servlet.ServletContainer</servlet-class>
    <init-param>
        <param-name>jersey.config.server.provider.packages</param-name>
        <param-value>com.ecommerce.controller</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>

<servlet-mapping>
    <servlet-name>Jersey REST Service</servlet-name>
    <url-pattern>/api/*</url-pattern>
</servlet-mapping>
```

### 3. Database Connection

**No Changes Required:**
The application already used HikariCP for connection pooling instead of JNDI lookups, so no database connection changes were needed. This was a key factor in the smooth migration.

### 4. Frontend Configuration

**Updated API Base URL:**
```xml
<!-- Before (WebSphere) -->
<add key="ApiBaseUrl" value="http://localhost:9080/ecommerce/api" />

<!-- After (Tomcat) -->
<add key="ApiBaseUrl" value="http://localhost:8080/ecommerce-backend/api" />
```

## Deployment Configuration

### Tomcat Configuration Files

Created new configuration files in `deployment/tomcat/`:

1. **context.xml** - Application context configuration
2. **server.xml** - Sample Tomcat server configuration
3. **tomcat-users.xml** - User management for Tomcat Manager

### WebSphere Legacy Files

Kept existing WebSphere configuration files in `deployment/websphere/` for reference:
- `ibm-web-bnd.xml` - WebSphere binding configuration (deprecated)
- `ibm-web-ext.xml` - WebSphere extension configuration (deprecated)

## Migration Process

### Step 1: Backup Current System
```bash
# Backup WebSphere configuration
cp -r $WAS_HOME/profiles/AppSrv01/config/ backup/websphere-config/

# Backup application
cp ecommerce-backend.war backup/
```

### Step 2: Install and Configure Tomcat
```bash
# Download and install Tomcat 9.0+
# Set CATALINA_HOME environment variable
# Configure tomcat-users.xml for management
```

### Step 3: Update Application Code
```bash
# Update pom.xml with Jersey dependencies
# Update web.xml with Jersey servlet configuration
# Update frontend API URLs
```

### Step 4: Build and Deploy
```bash
# Build the updated application
mvn clean package

# Deploy to Tomcat
cp target/ecommerce-backend.war $CATALINA_HOME/webapps/

# Start Tomcat
$CATALINA_HOME/bin/startup.sh
```

### Step 5: Test and Validate
```bash
# Test API endpoints
curl http://localhost:8080/ecommerce-backend/api/products

# Test frontend connectivity
# Verify all functionality works as expected
```

## Benefits Achieved

### 1. Cost Savings
- **Eliminated IBM WebSphere licensing costs**
- **Reduced infrastructure complexity**
- **Lower maintenance overhead**

### 2. Performance Improvements
- **Faster application startup time**
- **Lower memory footprint**
- **Simplified deployment process**

### 3. Development Benefits
- **Easier local development setup**
- **Better IDE integration**
- **Larger community support**

### 4. Operational Benefits
- **Simplified monitoring and management**
- **Standard logging and debugging**
- **Better documentation and resources**

## Challenges and Solutions

### Challenge 1: JAX-RS Implementation
**Problem**: Tomcat doesn't provide JAX-RS implementation
**Solution**: Added Jersey dependencies to provide JAX-RS support

### Challenge 2: Servlet Configuration
**Problem**: Need to configure Jersey servlet container
**Solution**: Updated web.xml with Jersey servlet configuration

### Challenge 3: Context Path Changes
**Problem**: Application context path changed
**Solution**: Updated frontend configuration and documentation

### Challenge 4: Port Changes
**Problem**: Default ports changed from 9080 to 8080
**Solution**: Updated all configuration files and documentation

## Testing Results

### Functional Testing
- ✅ User registration and authentication
- ✅ Product catalog browsing
- ✅ Shopping cart functionality
- ✅ Order processing
- ✅ Payment integration
- ✅ Admin functionality

### Performance Testing
- ✅ API response times maintained
- ✅ Database connectivity stable
- ✅ Frontend-backend communication working
- ✅ Session management functioning

### Security Testing
- ✅ JWT authentication working
- ✅ CORS configuration proper
- ✅ HTTPS configuration (when enabled)
- ✅ Input validation maintained

## Rollback Plan

If rollback to WebSphere is needed:

1. **Stop Tomcat**: `$CATALINA_HOME/bin/shutdown.sh`
2. **Restore WebSphere**: Deploy original WAR file to WebSphere
3. **Revert Frontend**: Update API URLs back to WebSphere ports
4. **Restart WebSphere**: Start WebSphere application server
5. **Validate**: Test all functionality

## Maintenance and Support

### Monitoring
- **Tomcat Manager**: `http://localhost:8080/manager/html`
- **Application Logs**: `$CATALINA_HOME/logs/catalina.out`
- **JVM Monitoring**: Use JConsole or VisualVM

### Updates
- **Tomcat Updates**: Follow Apache Tomcat security advisories
- **Jersey Updates**: Keep JAX-RS implementation current
- **Java Updates**: Maintain Java 8 compatibility

### Backup Strategy
- **Application**: Regular WAR file backups
- **Configuration**: Backup Tomcat configuration files
- **Database**: Continue existing PostgreSQL backup strategy

## Conclusion

The migration from IBM WebSphere to Apache Tomcat was successful with minimal code changes. The application's architecture, particularly the use of HikariCP for database connections instead of JNDI, made the migration straightforward. The new setup provides cost savings, better performance, and easier maintenance while maintaining all existing functionality.

## Next Steps

1. **Performance Optimization**: Fine-tune Tomcat configuration for production
2. **Security Hardening**: Implement production security measures
3. **Monitoring Setup**: Configure application monitoring tools
4. **Documentation Updates**: Keep all documentation current
5. **Team Training**: Train operations team on Tomcat management
