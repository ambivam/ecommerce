<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <%
    // Check if user is logged in
    if (Session["UserInfo"] == null || Session["AuthToken"] == null)
    {
        Response.Redirect("LoginWorking.aspx");
        return;
    }
    
    // Get user info from session
    var serializer = new JavaScriptSerializer();
    var userInfo = serializer.Deserialize<dynamic>(Session["UserInfo"].ToString());
    string userName = userInfo["firstName"] + " " + userInfo["lastName"];
    string userEmail = userInfo["email"];
    string userId = userInfo["id"].ToString();
    %>

    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/ecommerce-ui/">TechMart</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="ProductsWorking.aspx">All Products</a>
                </li>
                <li class="nav-item">
                    <span class="navbar-text text-light me-3">Welcome, <%= userInfo["firstName"] %>!</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="Logout.aspx">Logout</a>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h1 class="display-5">Welcome back, <%= userName %>!</h1>
                <p class="lead">Here's your personalized shopping experience</p>
            </div>
        </div>

        <!-- User Stats Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-primary text-white">
                    <div class="card-body text-center">
                        <h2>&#x1F6D2;</h2>
                        <h5>My Orders</h5>
                        <h3>0</h3>
                        <small>Total Orders</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success text-white">
                    <div class="card-body text-center">
                        <h2>&#x2764;</h2>
                        <h5>Wishlist</h5>
                        <h3>0</h3>
                        <small>Saved Items</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info text-white">
                    <div class="card-body text-center">
                        <h2>&#x1F4B3;</h2>
                        <h5>Rewards</h5>
                        <h3>$0</h3>
                        <small>Points Balance</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-warning text-white">
                    <div class="card-body text-center">
                        <h2>&#x1F381;</h2>
                        <h5>Offers</h5>
                        <h3>3</h3>
                        <small>Available Deals</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Personalized Recommendations -->
        <div class="row">
            <div class="col-12">
                <h3>Recommended for You</h3>
                <p class="text-muted">Based on your preferences and popular items</p>
                
                <%
                string recommendedProductsHtml = "";
                try
                {
                    using (var client = new System.Net.WebClient())
                    {
                        client.Headers.Add("User-Agent", "TechMart-Frontend/1.0");
                        string url = "http://localhost:8080/ecommerce-backend/api/products";
                        string response = client.DownloadString(url);
                        
                        var allProducts = serializer.Deserialize<dynamic[]>(response);
                        
                        if (allProducts != null && allProducts.Length > 0)
                        {
                            // For demo purposes, show products from different categories
                            // In a real app, this would be based on user's purchase history, browsing behavior, etc.
                            var recommendedProducts = new List<dynamic>();
                            
                            // Get one product from each category for variety
                            var categories = new HashSet<string>();
                            foreach (var product in allProducts)
                            {
                                string category = product["categoryName"]?.ToString() ?? "Other";
                                if (!categories.Contains(category) && recommendedProducts.Count < 6)
                                {
                                    categories.Add(category);
                                    recommendedProducts.Add(product);
                                }
                            }
                            
                            // Fill remaining slots with random products
                            var random = new Random();
                            while (recommendedProducts.Count < 6 && recommendedProducts.Count < allProducts.Length)
                            {
                                var randomProduct = allProducts[random.Next(allProducts.Length)];
                                bool alreadyExists = false;
                                foreach (var existing in recommendedProducts)
                                {
                                    if (existing["id"].ToString() == randomProduct["id"].ToString())
                                    {
                                        alreadyExists = true;
                                        break;
                                    }
                                }
                                if (!alreadyExists)
                                {
                                    recommendedProducts.Add(randomProduct);
                                }
                            }
                            
                            recommendedProductsHtml = "<div class='row'>";
                            foreach (var product in recommendedProducts)
                            {
                                recommendedProductsHtml += string.Format(@"
                                    <div class='col-md-4 mb-4'>
                                        <div class='card h-100'>
                                            <div class='card-body'>
                                                <div class='d-flex justify-content-between align-items-start mb-2'>
                                                    <h5 class='card-title'>{0}</h5>
                                                    <button class='btn btn-outline-danger btn-sm' onclick='toggleWishlist({5})'>
                                                        &#x2764;
                                                    </button>
                                                </div>
                                                <p class='card-text text-muted'>{1}</p>
                                                <div class='d-flex justify-content-between align-items-center mb-2'>
                                                    <span class='h5 text-primary'>${2}</span>
                                                    <small class='text-success'>In Stock: {3}</small>
                                                </div>
                                                <div class='mb-2'>
                                                    <span class='badge bg-secondary'>{4}</span>
                                                </div>
                                                <div class='d-grid gap-2'>
                                                    <button class='btn btn-primary' onclick='addToCart({5})'>
                                                        &#x1F6D2; Add to Cart
                                                    </button>
                                                    <button class='btn btn-outline-secondary btn-sm' onclick='viewDetails({6})'>
                                                        View Details
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
                                product["categoryName"] ?? "Other",
                                product["id"],
                                product["id"]);
                            }
                            recommendedProductsHtml += "</div>";
                        }
                        else
                        {
                            recommendedProductsHtml = "<div class='alert alert-info'>No products available for recommendations.</div>";
                        }
                    }
                }
                catch (Exception ex)
                {
                    recommendedProductsHtml = string.Format(@"
                        <div class='alert alert-warning'>
                            <h5>&#x26A0; Unable to Load Recommendations</h5>
                            <p>We're having trouble loading personalized recommendations.</p>
                            <p><a href='ProductsWorking.aspx' class='alert-link'>Browse all products instead</a></p>
                        </div>
                    ");
                }
                %>
                
                <%= recommendedProductsHtml %>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="row mt-4">
            <div class="col-12">
                <h3>Quick Actions</h3>
                <div class="row">
                    <div class="col-md-3 mb-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h2>&#x1F50D;</h2>
                                <h5>Browse Products</h5>
                                <a href="ProductsWorking.aspx" class="btn btn-outline-primary">Shop Now</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h2>&#x1F4E6;</h2>
                                <h5>Track Orders</h5>
                                <button class="btn btn-outline-primary" onclick="alert('Order tracking coming soon!')">Track</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h2>&#x1F464;</h2>
                                <h5>My Profile</h5>
                                <button class="btn btn-outline-primary" onclick="alert('Profile management coming soon!')">Edit</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card text-center">
                            <div class="card-body">
                                <h2>&#x1F4DE;</h2>
                                <h5>Support</h5>
                                <button class="btn btn-outline-primary" onclick="alert('Contact: support@techmart.com')">Contact</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function addToCart(productId) {
            alert('Product ' + productId + ' added to your cart! (Cart functionality will be implemented next)');
        }

        function viewDetails(productId) {
            alert('Viewing details for product ' + productId + ' (Product details page will be implemented next)');
        }

        function toggleWishlist(productId) {
            alert('Product ' + productId + ' added to wishlist! (Wishlist functionality will be implemented next)');
        }
    </script>
</body>
</html>
