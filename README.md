# E-Commerce Monolithic Application

## Architecture Overview

This is a monolithic e-commerce application built with a multi-tier architecture:

```
ASP.NET Web UI (Presentation Layer)
        |
        |  HTTP/REST Calls
        ↓
Java 8 Monolithic Backend (Business Layer)
    - Runs on Apache Tomcat
    - Handles Orders, Products, Payments, Users
        |
        ↓
PostgreSQL (Data Layer)
```

## Technology Stack

- **Frontend**: ASP.NET Web Forms/MVC (C#)
- **Backend**: Java 8 with JAX-RS for REST APIs
- **Application Server**: Apache Tomcat 9.0+
- **Database**: PostgreSQL
- **Build Tools**: Maven (Java), MSBuild (ASP.NET)

## Project Structure

```
ecommerce/
├── ecommerce-backend/          # Java 8 backend application
│   ├── src/main/java/         # Java source code
│   ├── src/main/resources/    # Configuration files
│   ├── src/main/webapp/       # Web application resources
│   └── pom.xml               # Maven configuration
├── ecommerce-ui/              # ASP.NET Web UI
│   ├── Pages/                # Web pages
│   ├── Models/               # View models
│   ├── Services/             # HTTP client services
│   └── Web.config           # ASP.NET configuration
├── database/                  # Database scripts
│   └── schema.sql            # PostgreSQL schema
└── deployment/               # Deployment configurations
    └── tomcat/              # Tomcat configuration files
```

## Features

- User registration and authentication
- Product catalog management
- Shopping cart functionality
- Order processing
- Payment integration
- Admin panel for product management

## Getting Started

### Prerequisites

- Java 8 JDK
- Apache Tomcat 9.0+
- PostgreSQL 12+
- Visual Studio or VS Code for ASP.NET development
- Maven 3.6+

### Setup Instructions

1. **Database Setup**
   ```sql
   -- Run the schema.sql file in PostgreSQL
   psql -U postgres -d ecommerce -f database/schema.sql
   ```

2. **Backend Setup**
   ```bash
   cd ecommerce-backend
   mvn clean package
   # Deploy the generated WAR file to Tomcat webapps directory
   cp target/ecommerce-backend.war $CATALINA_HOME/webapps/
   ```

3. **Frontend Setup**
   ```bash
   cd ecommerce-ui
   # Build and deploy to IIS or run in Visual Studio
   ```

## API Endpoints

The Java backend exposes the following REST endpoints:

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product
- `POST /api/users/register` - User registration
- `POST /api/users/login` - User login
- `GET /api/orders` - Get user orders
- `POST /api/orders` - Create new order
- `POST /api/payments` - Process payment

## Configuration

### Database Connection
Configure PostgreSQL connection in `ecommerce-backend/src/main/resources/application.properties`

### Tomcat Configuration
Tomcat configuration files are located in `deployment/tomcat/`

**Migration Note**: This application was migrated from IBM WebSphere to Apache Tomcat. All WebSphere-specific configuration files have been removed.

### ASP.NET Configuration
Update API base URL in `ecommerce-ui/Web.config`

## Migration from WebSphere to Tomcat

This application was originally designed for IBM WebSphere Application Server and has been successfully migrated to Apache Tomcat. Here are the key changes made:

### Backend Changes
- **JAX-RS Implementation**: Added Jersey JAX-RS implementation since Tomcat doesn't provide it
- **Servlet Configuration**: Updated `web.xml` to configure Jersey servlet container
- **Maven Dependencies**: Added Jersey dependencies and Tomcat Maven plugin
- **Connection Pooling**: Continues to use HikariCP (no JNDI dependency)

### Deployment Changes
- **WAR Deployment**: Changed from WebSphere admin console to Tomcat webapps directory
- **Port Changes**: Default port changed from 9080 to 8080
- **Context Path**: Application context changed from `/ecommerce` to `/ecommerce-backend`
- **Management**: Tomcat Manager replaces WebSphere admin console

### Configuration Files
- **Tomcat**: Configuration files in `deployment/tomcat/`
  - `context.xml` - Application context configuration
  - `server.xml` - Sample server configuration
  - `tomcat-users.xml` - User management configuration

### Benefits of Migration
- **Cost Reduction**: Eliminated IBM WebSphere licensing costs
- **Simplified Deployment**: Easier WAR file deployment process
- **Better Performance**: Faster startup and lower memory footprint
- **Community Support**: Larger open-source community and documentation

## Deployment Options

### Local Development
```bash
# Using Maven Tomcat plugin
mvn clean package tomcat7:run

# Or deploy to local Tomcat
mvn clean package
cp target/ecommerce-backend.war $CATALINA_HOME/webapps/
```

### Production Deployment
1. Build the application: `mvn clean package`
2. Copy WAR to Tomcat: `cp target/ecommerce-backend.war $CATALINA_HOME/webapps/`
3. Configure database connection in `application.properties`
4. Start Tomcat: `$CATALINA_HOME/bin/startup.sh`

## Testing

### Backend API Testing
```bash
# Test product endpoint
curl http://localhost:8080/ecommerce-backend/api/products

# Test with authentication
curl -H "Authorization: Bearer <jwt-token>" \
     http://localhost:8080/ecommerce-backend/api/orders
```

### Frontend Testing
- Access the application at: `http://localhost/ecommerce-ui`
- Test user registration and login
- Verify product catalog functionality
- Test shopping cart operations

## Troubleshooting

### Common Issues
1. **Port Conflicts**: Ensure port 8080 is available for Tomcat
2. **Database Connection**: Verify PostgreSQL is running and accessible
3. **CORS Issues**: Check CORS configuration in the backend
4. **JAR Dependencies**: Ensure all Maven dependencies are resolved

### Log Locations
- **Tomcat Logs**: `$CATALINA_HOME/logs/catalina.out`
- **Application Logs**: Check Tomcat logs for application-specific errors
- **Database Logs**: PostgreSQL logs for database connection issues

## Support and Documentation

- **Installation Guide**: See `INSTALL.md` for detailed setup instructions
- **Deployment Guide**: See `DEPLOYMENT.md` for production deployment
- **Database Schema**: See `database/schema.sql` for database structure
