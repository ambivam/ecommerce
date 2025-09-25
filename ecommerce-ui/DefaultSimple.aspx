<%@ Page Language="C#" CodePage="65001" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechMart - Your Online Shopping Destination</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/ecommerce-ui/">TechMart</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="ProductsSimple.aspx">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="LoginWorking.aspx">Login</a>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row">
            <div class="col-12">
                <h1 class="display-4">Welcome to TechMart</h1>
                <p class="lead">Discover amazing deals on electronics, clothing, books, and more!</p>
                
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card text-center h-100">
                            <div class="card-body">
                                <h2>&#x1F4F1;</h2>
                                <h5>Electronics</h5>
                                <p class="card-text">Latest gadgets and tech</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center h-100">
                            <div class="card-body">
                                <h2>&#x1F455;</h2>
                                <h5>Fashion</h5>
                                <p class="card-text">Trendy clothing & accessories</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center h-100">
                            <div class="card-body">
                                <h2>&#x1F4DA;</h2>
                                <h5>Books</h5>
                                <p class="card-text">Educational & entertainment</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card text-center h-100">
                            <div class="card-body">
                                <h2>&#x1F3E1;</h2>
                                <h5>Home & Garden</h5>
                                <p class="card-text">Everything for your home</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="alert alert-info">
                    <h4>&#x1F6CD; Why Shop With Us?</h4>
                    <ul class="mb-0">
                        <li><strong>&#x1F4E6; Fast Shipping:</strong> Free delivery on orders over $50</li>
                        <li><strong>&#x1F512; Secure Payments:</strong> Your data is protected with SSL encryption</li>
                        <li><strong>&#x1F4DE; 24/7 Support:</strong> Customer service available around the clock</li>
                        <li><strong>&#x1F501; Easy Returns:</strong> 30-day hassle-free return policy</li>
                    </ul>
                </div>
                
                <h3>Featured Products</h3>
                <div id="productsContainer">
                    <p>Loading products...</p>
                </div>
                
                <div class="mt-4">
                    <a href="ProductsSimple.aspx" class="btn btn-primary btn-lg">Browse All Products</a>
                    <a href="LoginWorking.aspx" class="btn btn-outline-secondary btn-lg">Login</a>
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
