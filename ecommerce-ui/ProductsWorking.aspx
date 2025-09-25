<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="System.Collections.Generic" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <%
    // Check if user is logged in for navigation
    bool isUserLoggedIn = false;
    string userFirstName = "";
    try
    {
        if (Session["UserInfo"] != null && Session["AuthToken"] != null)
        {
            var navSerializer = new JavaScriptSerializer();
            var navUserInfo = navSerializer.Deserialize<dynamic>(Session["UserInfo"].ToString());
            userFirstName = navUserInfo["firstName"];
            isUserLoggedIn = true;
        }
    }
    catch (Exception)
    {
        isUserLoggedIn = false;
    }
    %>

    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/ecommerce-ui/">TechMart</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <% if (isUserLoggedIn) { %>
                        <a class="nav-link" href="UserDashboardSimple.aspx">My Dashboard</a>
                    <% } else { %>
                        <a class="nav-link" href="/ecommerce-ui/">Home</a>
                    <% } %>
                </li>
                <% if (isUserLoggedIn) { %>
                <li class="nav-item">
                    <a class="nav-link position-relative" href="Cart.aspx">
                        &#128722; Cart
                        <span id="cartCounter" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="display: none;">
                            0
                        </span>
                    </a>
                </li>
                <% } %>
                <li class="nav-item">
                    <% if (isUserLoggedIn) { %>
                        <span class="navbar-text text-light me-3">Welcome, <%= userFirstName %>!</span>
                    <% } %>
                </li>
                <li class="nav-item">
                    <% if (isUserLoggedIn) { %>
                        <a class="nav-link" href="Logout.aspx">Logout</a>
                    <% } else { %>
                        <a class="nav-link" href="LoginWorking.aspx">Login</a>
                    <% } %>
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
                        <form method="get">
                            <div class="mb-3">
                                <input type="text" class="form-control" placeholder="Search products..." 
                                       name="search" value="<%= Request.QueryString["search"] ?? "" %>">
                            </div>
                            <div class="mb-3">
                                <select class="form-select" name="category">
                                    <option value="">All Categories</option>
                                    <option value="Electronics" <%= Request.QueryString["category"] == "Electronics" ? "selected" : "" %>>Electronics</option>
                                    <option value="Clothing" <%= Request.QueryString["category"] == "Clothing" ? "selected" : "" %>>Clothing</option>
                                    <option value="Books" <%= Request.QueryString["category"] == "Books" ? "selected" : "" %>>Books</option>
                                    <option value="Home & Garden" <%= Request.QueryString["category"] == "Home & Garden" ? "selected" : "" %>>Home & Garden</option>
                                    <option value="Sports" <%= Request.QueryString["category"] == "Sports" ? "selected" : "" %>>Sports</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary">Filter</button>
                            <% if (!string.IsNullOrEmpty(Request.QueryString["search"]) || !string.IsNullOrEmpty(Request.QueryString["category"])) { %>
                                <a href="ProductsWorking.aspx" class="btn btn-outline-secondary">Clear</a>
                            <% } %>
                        </form>
                    </div>
                </div>
            </div>
            <div class="col-md-9">
                <%
                string productsHtml = "";
                string searchTerm = Request.QueryString["search"] ?? "";
                string categoryFilter = Request.QueryString["category"] ?? "";
                
                try
                {
                    using (var client = new System.Net.WebClient())
                    {
                        client.Headers.Add("User-Agent", "TechMart-Frontend/1.0");
                        string url = "http://localhost:8080/ecommerce-backend/api/products";
                        string response = client.DownloadString(url);
                        
                        var serializer = new JavaScriptSerializer();
                        var allProducts = serializer.Deserialize<dynamic[]>(response);
                        
                        if (allProducts != null && allProducts.Length > 0)
                        {
                            // Filter products based on search and category
                            var filteredProducts = new List<dynamic>();
                            foreach (var product in allProducts)
                            {
                                bool matchesSearch = string.IsNullOrEmpty(searchTerm) || 
                                    product["name"].ToString().ToLower().Contains(searchTerm.ToLower()) ||
                                    (product["description"] != null && product["description"].ToString().ToLower().Contains(searchTerm.ToLower()));
                                
                                bool matchesCategory = string.IsNullOrEmpty(categoryFilter) ||
                                    (product["categoryName"] != null && product["categoryName"].ToString().Equals(categoryFilter, StringComparison.OrdinalIgnoreCase));
                                
                                if (matchesSearch && matchesCategory)
                                {
                                    filteredProducts.Add(product);
                                }
                            }
                            
                            if (filteredProducts.Count > 0)
                            {
                                productsHtml = "<div class='row'>";
                                foreach (var product in filteredProducts)
                                {
                                    productsHtml += string.Format(@"
                                        <div class='col-md-4 mb-4'>
                                            <div class='card h-100'>
                                                <div class='card-body'>
                                                    <h5 class='card-title'>{0}</h5>
                                                    <p class='card-text'>{1}</p>
                                                    <div class='d-flex justify-content-between align-items-center mb-2'>
                                                        <span class='h5 text-primary'>${2}</span>
                                                        <small class='text-muted'>Stock: {3}</small>
                                                    </div>
                                                    <div class='mb-2'>
                                                        <span class='badge bg-secondary'>{4}</span>
                                                    </div>
                                                    <div class='mt-3'>
                                                        <button class='btn btn-primary btn-sm' onclick='addToCart({5})'>
                                                            Add to Cart
                                                        </button>
                                                        <button class='btn btn-outline-secondary btn-sm' onclick='viewDetails({6})'>
                                                            Details
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    ", 
                                    product["name"], 
                                    product["description"] ?? "No description available", 
                                    product["price"], 
                                    product["stockQuantity"],
                                    product["categoryName"] ?? "Uncategorized",
                                    product["id"],
                                    product["id"]);
                                }
                                productsHtml += "</div>";
                                
                                // Add summary
                                string filterSummary = "";
                                if (!string.IsNullOrEmpty(searchTerm) || !string.IsNullOrEmpty(categoryFilter))
                                {
                                    filterSummary = string.Format("<div class='alert alert-info mb-3'>Showing {0} products", filteredProducts.Count);
                                    if (!string.IsNullOrEmpty(searchTerm))
                                        filterSummary += string.Format(" matching '<strong>{0}</strong>'", searchTerm);
                                    if (!string.IsNullOrEmpty(categoryFilter))
                                        filterSummary += string.Format(" in category '<strong>{0}</strong>'", categoryFilter);
                                    filterSummary += "</div>";
                                }
                                else
                                {
                                    filterSummary = string.Format("<div class='alert alert-success mb-3'>Showing all {0} products</div>", filteredProducts.Count);
                                }
                                
                                productsHtml = filterSummary + productsHtml;
                            }
                            else
                            {
                                productsHtml = "<div class='alert alert-warning'>No products found matching your criteria. <a href='ProductsWorking.aspx'>View all products</a></div>";
                            }
                        }
                        else
                        {
                            productsHtml = "<div class='alert alert-info'>No products available at the moment.</div>";
                        }
                    }
                }
                catch (Exception ex)
                {
                    productsHtml = string.Format(@"
                        <div class='alert alert-danger'>
                            <h5>&#x26A0; Unable to Load Products</h5>
                            <p>The backend API is not available. Please ensure the Java backend is running on port 8080.</p>
                            <p><strong>Error:</strong> {0}</p>
                            <p><strong>To start the backend:</strong></p>
                            <ol>
                                <li>Open command prompt</li>
                                <li>Navigate to: <code>cd C:\\ecommerce\\ecommerce-backend</code></li>
                                <li>Run: <code>mvn tomcat7:run</code></li>
                            </ol>
                            <button class='btn btn-outline-primary btn-sm' onclick='location.reload()'>
                                &#x1F504; Retry
                            </button>
                        </div>
                    ", ex.Message);
                }
                %>
                
                <%= productsHtml %>
            </div>
        </div>
    </div>

    <script>
        const authToken = '<%= Session["AuthToken"] != null ? Session["AuthToken"].ToString() : "" %>';
        const isLoggedIn = '<%= isUserLoggedIn.ToString().ToLower() %>' === 'true';

        function addToCart(productId) {
            if (!isLoggedIn) {
                alert('Please login to add items to cart');
                window.location.href = 'LoginWorking.aspx';
                return;
            }

            if (!authToken) {
                alert('Authentication required. Please login again.');
                window.location.href = 'LoginWorking.aspx';
                return;
            }

            // Show loading state
            const button = event.target;
            const originalText = button.innerHTML;
            button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Adding...';
            button.disabled = true;

            fetch('http://localhost:8080/ecommerce-backend/api/simplecart/add', {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    productId: productId,
                    quantity: 1
                })
            })
            .then(response => response.json())
            .then(data => {
                button.innerHTML = originalText;
                button.disabled = false;

                if (data.success) {
                    // Show success message
                    showNotification('&#10004; Item added to cart successfully!', 'success');
                    
                    // Update cart counter if it exists
                    updateCartCounter(data.cartItemCount);
                    
                    // Change button temporarily
                    button.innerHTML = '&#10004; Added!';
                    button.classList.remove('btn-primary');
                    button.classList.add('btn-success');
                    
                    setTimeout(() => {
                        button.innerHTML = originalText;
                        button.classList.remove('btn-success');
                        button.classList.add('btn-primary');
                    }, 2000);
                } else {
                    showNotification('&#10060; ' + (data.error || 'Failed to add item to cart'), 'error');
                }
            })
            .catch(error => {
                button.innerHTML = originalText;
                button.disabled = false;
                console.error('Error adding to cart:', error);
                showNotification('&#10060; Failed to add item to cart. Please check if the backend is running.', 'error');
            });
        }

        function viewDetails(productId) {
            alert('Product details page will be implemented next! Product ID: ' + productId);
        }

        function showNotification(message, type) {
            // Create notification element
            const notification = document.createElement('div');
            notification.className = `alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show position-fixed`;
            notification.style.cssText = 'top: 20px; right: 20px; z-index: 1050; min-width: 300px;';
            notification.innerHTML = `
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            
            document.body.appendChild(notification);
            
            // Auto-remove after 4 seconds
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.remove();
                }
            }, 4000);
        }

        function updateCartCounter(count) {
            // Update cart counter in navigation if it exists
            const cartCounter = document.getElementById('cartCounter');
            if (cartCounter) {
                cartCounter.textContent = count;
                cartCounter.style.display = count > 0 ? 'inline' : 'none';
            }
        }

        // Load cart count on page load for logged-in users
        document.addEventListener('DOMContentLoaded', function() {
            if (isLoggedIn && authToken) {
                loadCartCount();
            }
        });

        function loadCartCount() {
            fetch('http://localhost:8080/ecommerce-backend/api/simplecart/count', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateCartCounter(data.count);
                }
            })
            .catch(error => {
                console.error('Error loading cart count:', error);
            });
        }
    </script>
</body>
</html>
