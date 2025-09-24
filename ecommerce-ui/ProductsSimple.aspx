<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>Products - E-Commerce Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/">E-Commerce Store</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="LoginSimple.aspx">Login</a>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-4">
        <h1>Our Products</h1>
        <p class="lead">Browse our amazing collection of products</p>
        
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body">
                        <h5>Search & Filter</h5>
                        <div class="mb-3">
                            <input type="text" class="form-control" placeholder="Search products..." id="searchInput">
                        </div>
                        <div class="mb-3">
                            <select class="form-select" id="categoryFilter">
                                <option value="">All Categories</option>
                                <option value="electronics">Electronics</option>
                                <option value="clothing">Clothing</option>
                                <option value="books">Books</option>
                            </select>
                        </div>
                        <button class="btn btn-primary" onclick="filterProducts()">Filter</button>
                    </div>
                </div>
            </div>
            <div class="col-md-9">
                <div id="productsContainer">
                    <div class="text-center">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p>Loading products from API...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        let allProducts = [];

        // Load products from API
        fetch('http://localhost:8080/ecommerce-backend/api/products')
            .then(response => response.json())
            .then(products => {
                allProducts = products;
                displayProducts(products);
            })
            .catch(error => {
                console.error('Error loading products:', error);
                document.getElementById('productsContainer').innerHTML = `
                    <div class="alert alert-warning">
                        <h4>Unable to load products</h4>
                        <p>The backend API is not available. Please ensure the Java backend is running on port 8080.</p>
                        <p><strong>To start the backend:</strong></p>
                        <ol>
                            <li>Open command prompt</li>
                            <li>Navigate to: <code>cd C:\\ecommerce\\ecommerce-backend</code></li>
                            <li>Run: <code>mvn clean package</code></li>
                            <li>Deploy to Tomcat and start Tomcat</li>
                        </ol>
                    </div>
                `;
            });

        function displayProducts(products) {
            const container = document.getElementById('productsContainer');
            
            if (!products || products.length === 0) {
                container.innerHTML = '<div class="alert alert-info">No products found.</div>';
                return;
            }

            let html = '<div class="row">';
            products.forEach(product => {
                html += `
                    <div class="col-md-4 mb-4">
                        <div class="card h-100">
                            <div class="card-body">
                                <h5 class="card-title">${product.name}</h5>
                                <p class="card-text">${product.description || 'No description available'}</p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="h5 text-primary">$${product.price}</span>
                                    <small class="text-muted">Stock: ${product.stockQuantity}</small>
                                </div>
                                <div class="mt-3">
                                    <button class="btn btn-primary btn-sm" onclick="addToCart(${product.id})">
                                        Add to Cart
                                    </button>
                                    <button class="btn btn-outline-secondary btn-sm" onclick="viewDetails(${product.id})">
                                        Details
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                `;
            });
            html += '</div>';
            container.innerHTML = html;
        }

        function filterProducts() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const category = document.getElementById('categoryFilter').value.toLowerCase();
            
            let filtered = allProducts.filter(product => {
                const matchesSearch = !searchTerm || 
                    product.name.toLowerCase().includes(searchTerm) ||
                    (product.description && product.description.toLowerCase().includes(searchTerm));
                
                const matchesCategory = !category || 
                    (product.categoryName && product.categoryName.toLowerCase().includes(category));
                
                return matchesSearch && matchesCategory;
            });
            
            displayProducts(filtered);
        }

        function addToCart(productId) {
            alert('Product ' + productId + ' added to cart! (Cart functionality will be implemented next)');
        }

        function viewDetails(productId) {
            alert('Viewing details for product ' + productId + ' (Details page will be implemented next)');
        }

        // Search on Enter key
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                filterProducts();
            }
        });
    </script>
</body>
</html>
