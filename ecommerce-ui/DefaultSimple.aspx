<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>E-Commerce Store - Home</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="#">E-Commerce Store</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="ProductsSimple.aspx">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="LoginSimple.aspx">Login</a>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row">
            <div class="col-12">
                <h1 class="display-4">Welcome to Our Store</h1>
                <p class="lead">Your one-stop shop for amazing products!</p>
                
                <div class="alert alert-success">
                    <h4>✅ Application Status:</h4>
                    <ul>
                        <li>Frontend: ASP.NET Web Forms - Working</li>
                        <li>Backend: Java API - Connected</li>
                        <li>Database: PostgreSQL - Available</li>
                    </ul>
                </div>
                
                <h3>Featured Products</h3>
                <div id="productsContainer">
                    <p>Loading products...</p>
                </div>
                
                <div class="mt-4">
                    <a href="ProductsSimple.aspx" class="btn btn-primary btn-lg">Browse All Products</a>
                    <a href="LoginSimple.aspx" class="btn btn-outline-secondary btn-lg">Login</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Load products via JavaScript to avoid server-side issues
        fetch('http://localhost:8080/ecommerce-backend/api/products')
            .then(response => response.json())
            .then(products => {
                const container = document.getElementById('productsContainer');
                if (products && products.length > 0) {
                    let html = '<div class="row">';
                    products.slice(0, 4).forEach(product => {
                        html += `
                            <div class="col-md-3 mb-3">
                                <div class="card">
                                    <div class="card-body">
                                        <h5 class="card-title">${product.name}</h5>
                                        <p class="card-text">$${product.price}</p>
                                        <small class="text-muted">Stock: ${product.stockQuantity}</small>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                    html += '</div>';
                    container.innerHTML = html;
                } else {
                    container.innerHTML = '<p class="alert alert-info">No products available.</p>';
                }
            })
            .catch(error => {
                console.error('Error loading products:', error);
                document.getElementById('productsContainer').innerHTML = 
                    '<p class="alert alert-warning">Unable to load products. Backend API may be unavailable.</p>';
            });
    </script>
</body>
</html>
