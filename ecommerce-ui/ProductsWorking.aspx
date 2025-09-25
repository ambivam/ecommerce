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
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/ecommerce-ui/">TechMart</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/ecommerce-ui/">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="LoginWorking.aspx">Login</a>
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
        function addToCart(productId) {
            alert('Product ' + productId + ' added to cart! (Cart functionality will be implemented next)');
        }

        function viewDetails(productId) {
            alert('Viewing details for product ' + productId + ' (Details page will be implemented next)');
        }
    </script>
</body>
</html>
