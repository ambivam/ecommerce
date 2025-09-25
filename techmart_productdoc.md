# TechMart E-Commerce Application - Technical Documentation

## 📋 **Table of Contents**
1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Database Design](#database-design)
5. [Backend Components](#backend-components)
6. [Frontend Components](#frontend-components)
7. [Security Implementation](#security-implementation)
8. [API Documentation](#api-documentation)
9. [Deployment Architecture](#deployment-architecture)
10. [Development Workflow](#development-workflow)

---

## 🎯 **System Overview**

**TechMart** is a full-stack e-commerce application built with a hybrid architecture combining ASP.NET Web Forms frontend and Java 8 REST API backend. The application provides a complete online shopping experience with user authentication, product catalog, shopping cart, and checkout functionality.

### **Key Features**
- 🛍️ **Product Catalog**: Browse and search products with categories and filtering
- 👤 **User Management**: Registration, login, and profile management
- 🛒 **Shopping Cart**: Add, remove, and modify cart items
- 💳 **Checkout Process**: Complete order placement with payment information
- 🔐 **Authentication**: JWT-based secure authentication system
- 📱 **Responsive Design**: Mobile-friendly Bootstrap UI
- 🔍 **Product Details**: Comprehensive product information modals

---

## 🏗️ **Architecture**

### **High-Level Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Web Browser   │  │   Mobile App    │  │   Desktop    │ │
│  │   (Chrome, FF)  │  │   (Future)      │  │   (Future)   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                         HTTP/HTTPS
                              │
┌─────────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                          │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              IIS Web Server                             │ │
│  │  ┌─────────────────────────────────────────────────────┐│ │
│  │  │           ASP.NET Web Forms (C#)                    ││ │
│  │  │  • HomeWithProducts.aspx                           ││ │
│  │  │  • ProductsWorking.aspx                            ││ │
│  │  │  • LoginWorking.aspx / RegisterWorking.aspx        ││ │
│  │  │  • Cart.aspx / Checkout.aspx                       ││ │
│  │  │  • OrderSuccess.aspx                               ││ │
│  │  │  • UserDashboardSimple.aspx                        ││ │
│  │  └─────────────────────────────────────────────────────┘│ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                         REST API Calls
                              │
┌─────────────────────────────────────────────────────────────┐
│                  BUSINESS LAYER                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │            Apache Tomcat 9.0+                          │ │
│  │  ┌─────────────────────────────────────────────────────┐│ │
│  │  │              Java 8 Backend                         ││ │
│  │  │  ┌─────────────────────────────────────────────────┐││ │
│  │  │  │           JAX-RS Controllers                    │││ │
│  │  │  │  • UserController                               │││ │
│  │  │  │  • ProductController                            │││ │
│  │  │  │  • CartController                               │││ │
│  │  │  │  • OrderController                              │││ │
│  │  │  │  • CategoryController                           │││ │
│  │  │  └─────────────────────────────────────────────────┘││ │
│  │  │  ┌─────────────────────────────────────────────────┐││ │
│  │  │  │              Service Layer                      │││ │
│  │  │  │  • UserService                                  │││ │
│  │  │  │  • ProductService                               │││ │
│  │  │  │  • CartService                                  │││ │
│  │  │  │  • OrderService                                 │││ │
│  │  │  │  • CategoryService                              │││ │
│  │  │  └─────────────────────────────────────────────────┘││ │
│  │  │  ┌─────────────────────────────────────────────────┐││ │
│  │  │  │               DAO Layer                         │││ │
│  │  │  │  • UserDAO                                      │││ │
│  │  │  │  • ProductDAO                                   │││ │
│  │  │  │  • CartDAO                                      │││ │
│  │  │  │  • OrderDAO                                     │││ │
│  │  │  │  • CategoryDAO                                  │││ │
│  │  │  └─────────────────────────────────────────────────┘││ │
│  │  └─────────────────────────────────────────────────────┘│ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                         JDBC Connection
                              │
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              PostgreSQL Database                        │ │
│  │  • users                    • products                  │ │
│  │  • categories               • orders                    │ │
│  │  • order_items              • payments                  │ │
│  │  • cart                     • cart_items                │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### **Communication Flow**
1. **Client Request** → IIS Web Server (Port 80/443)
2. **ASP.NET Pages** → Process request, render UI
3. **JavaScript/AJAX** → Call Java Backend APIs (Port 8080)
4. **JAX-RS Controllers** → Route requests to services
5. **Service Layer** → Business logic processing
6. **DAO Layer** → Database operations via HikariCP
7. **PostgreSQL** → Data persistence (Port 5432)

---

## 💻 **Technology Stack**

### **Frontend Technologies**
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Web Framework** | ASP.NET Web Forms | 4.7+ | Server-side rendering |
| **UI Framework** | Bootstrap | 5.1.3 | Responsive design |
| **Icons** | Font Awesome | 6.0.0 | UI icons |
| **JavaScript** | Vanilla JS | ES6+ | Client-side interactivity |
| **Web Server** | IIS | 10.0+ | Hosting ASP.NET application |

### **Backend Technologies**
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Programming Language** | Java | 8 | Backend logic |
| **Web Framework** | JAX-RS (Jersey) | 2.29.1 | REST API framework |
| **Application Server** | Apache Tomcat | 9.0+ | Java application hosting |
| **Build Tool** | Maven | 3.6+ | Dependency management |
| **JSON Processing** | Jackson | 2.9.10 | JSON serialization |

### **Database & Infrastructure**
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Database** | PostgreSQL | 13+ | Data persistence |
| **Connection Pool** | HikariCP | 3.4.5 | Database connection management |
| **Authentication** | JWT | 0.9.1 | Token-based auth |
| **Password Hashing** | BCrypt | 0.4 | Secure password storage |
| **Logging** | SLF4J + Logback | 1.7.30 | Application logging |

---

## 🗄️ **Database Design**

### **Entity Relationship Diagram**
```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   categories    │       │    products     │       │      users      │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ id (PK)         │◄──────┤ id (PK)         │       │ id (PK)         │
│ name            │       │ name            │       │ username        │
│ description     │       │ description     │       │ email           │
│ created_at      │       │ price           │       │ password_hash   │
│ updated_at      │       │ stock_quantity  │       │ first_name      │
└─────────────────┘       │ category_id(FK) │       │ last_name       │
                          │ image_url       │       │ phone           │
                          │ is_active       │       │ address         │
                          │ created_at      │       │ city            │
                          │ updated_at      │       │ state           │
                          └─────────────────┘       │ zip_code        │
                                   │                │ country         │
                                   │                │ is_active       │
                                   │                │ is_admin        │
                                   │                │ created_at      │
                                   │                │ updated_at      │
                                   │                └─────────────────┘
                                   │                         │
                                   │                         │
┌─────────────────┐       ┌─────────────────┐               │
│   order_items   │       │     orders      │               │
├─────────────────┤       ├─────────────────┤               │
│ id (PK)         │       │ id (PK)         │               │
│ order_id (FK)   │◄──────┤ user_id (FK)    │◄──────────────┘
│ product_id (FK) │       │ total_amount    │
│ quantity        │       │ status          │
│ price           │       │ shipping_address│
│ created_at      │       │ created_at      │
└─────────────────┘       │ updated_at      │
         │                └─────────────────┘
         │                         │
         │                         │
         │                ┌─────────────────┐
         │                │    payments     │
         │                ├─────────────────┤
         │                │ id (PK)         │
         │                │ order_id (FK)   │◄─────┘
         │                │ amount          │
         │                │ payment_method  │
         │                │ status          │
         │                │ transaction_id  │
         │                │ created_at      │
         │                └─────────────────┘
         │
         │  ┌─────────────────┐       ┌─────────────────┐
         └─►│   cart_items    │       │      cart       │
            ├─────────────────┤       ├─────────────────┤
            │ id (PK)         │       │ id (PK)         │
            │ cart_id (FK)    │◄──────┤ user_id (FK)    │
            │ product_id (FK) │       │ created_at      │
            │ quantity        │       │ updated_at      │
            │ created_at      │       └─────────────────┘
            │ updated_at      │                │
            └─────────────────┘                │
                     │                         │
                     └─────────────────────────┘
```

### **Key Database Features**
- **Referential Integrity**: Foreign key constraints maintain data consistency
- **Indexing**: Optimized queries with strategic indexes
- **Constraints**: Check constraints for data validation
- **Timestamps**: Audit trail with created_at/updated_at
- **Soft Deletes**: is_active flags for logical deletion

---

## ⚙️ **Backend Components**

### **1. Controller Layer (JAX-RS)**
```java
@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ProductController {
    @GET
    @Path("/products")
    public Response getProducts() { ... }
    
    @GET
    @Path("/products/{id}")
    public Response getProduct(@PathParam("id") int id) { ... }
}
```

**Controllers:**
- `UserController`: Authentication, registration, profile management
- `ProductController`: Product CRUD operations, search, filtering
- `CartController`: Shopping cart management
- `OrderController`: Order processing and history
- `CategoryController`: Product category management

### **2. Service Layer**
```java
@Service
public class ProductService {
    private ProductDAO productDAO;
    
    public List<Product> getAllProducts() { ... }
    public Product getProductById(int id) { ... }
    public List<Product> searchProducts(String query) { ... }
}
```

**Services:**
- Business logic implementation
- Transaction management
- Data validation
- Cross-cutting concerns

### **3. Data Access Layer (DAO)**
```java
public class ProductDAO {
    private DataSource dataSource;
    
    public List<Product> findAll() { ... }
    public Product findById(int id) { ... }
    public void save(Product product) { ... }
    public void update(Product product) { ... }
}
```

**Features:**
- HikariCP connection pooling
- Prepared statements for security
- Transaction management
- Error handling

### **4. Security Components**
- **JWT Utility**: Token generation and validation
- **CORS Filter**: Cross-origin request handling
- **Authentication Filter**: Request authentication
- **Password Encryption**: BCrypt hashing

---

## 🎨 **Frontend Components**

### **1. Core Pages**
| Page | Purpose | Key Features |
|------|---------|--------------|
| `HomeWithProducts.aspx` | Landing page | Featured products, categories |
| `ProductsWorking.aspx` | Product catalog | Search, filter, pagination, details modal |
| `LoginWorking.aspx` | User authentication | JWT-based login |
| `RegisterWorking.aspx` | User registration | Form validation, account creation |
| `Cart.aspx` | Shopping cart | Item management, quantity updates |
| `Checkout.aspx` | Order placement | Shipping info, payment details |
| `OrderSuccess.aspx` | Order confirmation | Success message, order details |
| `UserDashboardSimple.aspx` | User profile | Account management |

### **2. JavaScript Features**
- **AJAX Communication**: REST API integration
- **Form Validation**: Client-side validation
- **Modal Management**: Product details, login prompts
- **Cart Management**: Real-time updates
- **Error Handling**: User-friendly error messages
- **Session Management**: JWT token handling

### **3. UI Components**
- **Responsive Design**: Bootstrap grid system
- **Interactive Elements**: Modals, dropdowns, forms
- **Navigation**: Breadcrumbs, pagination
- **Notifications**: Success/error alerts
- **Loading States**: Spinners, progress indicators

---

## 🔐 **Security Implementation**

### **Authentication Flow**
```
1. User Login → POST /api/users/login
2. Validate Credentials → BCrypt password check
3. Generate JWT Token → Include user info
4. Return Token → Store in session/localStorage
5. Subsequent Requests → Include Bearer token
6. Token Validation → Verify signature & expiry
7. Access Granted → Process request
```

### **Security Features**
- **JWT Authentication**: Stateless token-based auth
- **Password Hashing**: BCrypt with salt
- **CORS Protection**: Configured for cross-origin requests
- **Input Validation**: Server-side validation
- **SQL Injection Prevention**: Prepared statements
- **XSS Protection**: Input sanitization
- **Session Management**: Secure token handling

---

## 📡 **API Documentation**

### **Authentication Endpoints**
```
POST /api/users/login
POST /api/users/register
GET  /api/users/profile
PUT  /api/users/profile
```

### **Product Endpoints**
```
GET    /api/products
GET    /api/products/{id}
GET    /api/products/search?q={query}
GET    /api/products/category/{categoryId}
```

### **Cart Endpoints**
```
GET    /api/cart
POST   /api/cart
PUT    /api/cart/{id}
DELETE /api/cart/{id}
DELETE /api/cart/clear
```

### **Order Endpoints**
```
POST   /api/orders
GET    /api/orders
GET    /api/orders/{id}
PUT    /api/orders/{id}/status
```

### **Category Endpoints**
```
GET    /api/categories
GET    /api/categories/{id}
```

---

## 🚀 **Deployment Architecture**

### **Production Environment**
```
┌─────────────────────────────────────────────────────────────┐
│                    LOAD BALANCER                            │
│                  (Nginx/Apache)                             │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
┌─────────────────────────────┐ ┌─────────────────────────────┐
│      WEB SERVER 1           │ │      WEB SERVER 2           │
│  ┌─────────────────────────┐ │ │  ┌─────────────────────────┐ │
│  │         IIS             │ │ │  │         IIS             │ │
│  │   ASP.NET Frontend      │ │ │  │   ASP.NET Frontend      │ │
│  └─────────────────────────┘ │ │  └─────────────────────────┘ │
└─────────────────────────────┘ └─────────────────────────────┘
                    │                   │
                    └─────────┬─────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 API GATEWAY                                 │
│              (Optional - Future)                            │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
┌─────────────────────────────┐ ┌─────────────────────────────┐
│    APP SERVER 1             │ │    APP SERVER 2             │
│  ┌─────────────────────────┐ │ │  ┌─────────────────────────┐ │
│  │    Apache Tomcat        │ │ │  │    Apache Tomcat        │ │
│  │    Java Backend         │ │ │  │    Java Backend         │ │
│  └─────────────────────────┘ │ │  └─────────────────────────┘ │
└─────────────────────────────┘ └─────────────────────────────┘
                    │                   │
                    └─────────┬─────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                 DATABASE CLUSTER                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  PostgreSQL     │  │  PostgreSQL     │  │ PostgreSQL   │ │
│  │   (Master)      │  │   (Replica 1)   │  │ (Replica 2)  │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### **Development Environment**
- **Single Server**: All components on one machine
- **IIS**: Hosts ASP.NET frontend (Port 80)
- **Tomcat**: Hosts Java backend (Port 8080)
- **PostgreSQL**: Database server (Port 5432)

---

## 🔄 **Development Workflow**

### **Build Process**
```bash
# Backend Build
cd ecommerce-backend
mvn clean compile
mvn package
# Generates: target/ecommerce-backend.war

# Frontend Deployment
# Copy ASPX files to IIS wwwroot
# Configure IIS application pool
# Set up database connection strings
```

### **Testing Strategy**
- **Unit Tests**: JUnit for backend services
- **Integration Tests**: API endpoint testing
- **Manual Testing**: UI functionality verification
- **Database Testing**: Schema validation

### **Version Control**
- **Git**: Source code management
- **Branching**: Feature branches for development
- **CI/CD**: Automated build and deployment (future)

---

## 📊 **Performance Considerations**

### **Database Optimization**
- Connection pooling with HikariCP
- Indexed queries for fast lookups
- Pagination for large result sets
- Query optimization

### **Frontend Optimization**
- CDN for Bootstrap and Font Awesome
- Minified JavaScript and CSS
- Image optimization
- Caching strategies

### **Backend Optimization**
- Stateless design for scalability
- Efficient JSON serialization
- Connection pooling
- Logging and monitoring

---

## 🔮 **Future Enhancements**

### **Planned Features**
- **Order Tracking**: Real-time order status updates
- **Payment Integration**: Stripe/PayPal integration
- **Email Notifications**: Order confirmations and updates
- **Admin Panel**: Product and order management
- **Mobile App**: React Native or Flutter app
- **Search Enhancement**: Elasticsearch integration
- **Caching**: Redis for session and data caching
- **Microservices**: Break down monolith into services

### **Scalability Improvements**
- **Load Balancing**: Multiple server instances
- **Database Clustering**: Master-slave replication
- **CDN Integration**: Static asset delivery
- **API Gateway**: Centralized API management
- **Container Deployment**: Docker and Kubernetes

---

## 📝 **Conclusion**

TechMart represents a modern, scalable e-commerce solution built with proven technologies. The hybrid architecture leverages the strengths of both .NET and Java ecosystems, providing a robust foundation for future growth and enhancement.

The application demonstrates best practices in:
- **Security**: JWT authentication and secure coding practices
- **Architecture**: Layered design with clear separation of concerns
- **User Experience**: Responsive design and intuitive interfaces
- **Performance**: Optimized database queries and connection pooling
- **Maintainability**: Clean code structure and comprehensive documentation

This technical foundation supports the current feature set while providing flexibility for future enhancements and scaling requirements.
