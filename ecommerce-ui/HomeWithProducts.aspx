<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechMart - Your Online Shopping Destination</title>
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
                    <a class="nav-link" href="ProductsWorking.aspx">Products</a>
                </li>
                <li class="nav-item">
                    <% if (isUserLoggedIn) { %>
                        <a class="nav-link" href="UserDashboardSimple.aspx">My Dashboard</a>
                    <% } %>
                </li>
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
                <%
                string productsHtml = "";
                try
                {
                    using (var client = new System.Net.WebClient())
                    {
                        client.Headers.Add("User-Agent", "TechMart-Frontend/1.0");
                        string url = "http://localhost:8080/ecommerce-backend/api/products";
                        string response = client.DownloadString(url);
                        
                        var serializer = new JavaScriptSerializer();
                        var products = serializer.Deserialize<dynamic[]>(response);
                        
                        if (products != null && products.Length > 0)
                        {
                            productsHtml = "<div class='row'>";
                            for (int i = 0; i < Math.Min(4, products.Length); i++)
                            {
                                var product = products[i];
                                productsHtml += string.Format(@"
                                    <div class='col-md-3 mb-3'>
                                        <div class='card h-100'>
                                            <div class='card-body'>
                                                <h5 class='card-title'>{0}</h5>
                                                <p class='card-text'>{1}</p>
                                                <div class='d-flex justify-content-between align-items-center'>
                                                    <span class='h5 text-primary'>${2}</span>
                                                    <small class='text-muted'>Stock: {3}</small>
                                                </div>
                                                <div class='mt-2'>
                                                    <button class='btn btn-primary btn-sm'>Add to Cart</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                ", product["name"], product["description"], product["price"], product["stockQuantity"]);
                            }
                            productsHtml += "</div>";
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
                        <div class='alert alert-warning'>
                            <h5>&#x26A0; Products Temporarily Unavailable</h5>
                            <p>We're experiencing technical difficulties loading our product catalog.</p>
                            <p><strong>Error:</strong> {0}</p>
                            <p><strong>What you can do:</strong></p>
                            <ul>
                                <li>Try refreshing the page in a few moments</li>
                                <li>Browse our <a href='ProductsWorking.aspx' class='alert-link'>full product catalog</a></li>
                                <li>Contact our support team if the issue persists</li>
                            </ul>
                            <button class='btn btn-outline-primary btn-sm' onclick='location.reload()'>
                                &#x1F504; Refresh Page
                            </button>
                        </div>
                    ", ex.Message);
                }
                %>
                
                <%= productsHtml %>
                
                <div class="mt-4">
                    <a href="ProductsWorking.aspx" class="btn btn-primary btn-lg">Browse All Products</a>
                    <a href="LoginWorking.aspx" class="btn btn-outline-secondary btn-lg">Login</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
