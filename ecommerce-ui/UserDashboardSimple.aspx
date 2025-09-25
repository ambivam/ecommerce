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
    <title>My Dashboard - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <%
    string userName = "User";
    string userEmail = "";
    bool isLoggedIn = false;
    
    try
    {
        // Check if user is logged in
        if (Session["UserInfo"] != null && Session["AuthToken"] != null)
        {
            var serializer = new JavaScriptSerializer();
            var userInfo = serializer.Deserialize<dynamic>(Session["UserInfo"].ToString());
            userName = userInfo["firstName"] + " " + userInfo["lastName"];
            userEmail = userInfo["email"];
            isLoggedIn = true;
        }
    }
    catch (Exception ex)
    {
        // If there's an error with session data, treat as not logged in
        isLoggedIn = false;
    }
    
    if (!isLoggedIn)
    {
        // Instead of redirect, show login message
        Response.Write("<div class='container mt-5'><div class='alert alert-warning'><h4>Please Login</h4><p>You need to be logged in to access your dashboard.</p><a href='LoginWorking.aspx' class='btn btn-primary'>Go to Login</a></div></div>");
        return;
    }
    %>

    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/ecommerce-ui/">TechMart</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="ProductsWorking.aspx">All Products</a>
                </li>
                <li class="nav-item">
                    <span class="navbar-text text-light me-3">Welcome, <%= userName.Split(' ')[0] %>!</span>
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

        <!-- Quick Actions -->
        <div class="row">
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
                                <button class="btn btn-outline-primary" onclick="showProfile()">View Profile</button>
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

        <!-- Featured Products for User -->
        <div class="row mt-4">
            <div class="col-12">
                <h3>Recommended for You</h3>
                <p class="text-muted">Popular products you might like</p>
                
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">Featured Product 1</h5>
                                <p class="card-text">Check out our latest products</p>
                                <a href="ProductsWorking.aspx" class="btn btn-primary">View All Products</a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 mb-3">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">Special Offers</h5>
                                <p class="card-text">Don't miss our amazing deals</p>
                                <button class="btn btn-success" onclick="alert('Special offers coming soon!')">View Offers</button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4 mb-3">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title">Your Account</h5>
                                <p class="card-text">Manage your account settings</p>
                                <button class="btn btn-outline-secondary" onclick="showProfile()">Account Settings</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function showProfile() {
            alert('Profile: <%= userEmail %>\nAccount management features coming soon!');
        }
    </script>
</body>
</html>
