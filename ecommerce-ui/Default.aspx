<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>E-Commerce Store - Home</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="~/Content/site.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />
        
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <div class="container">
                <a class="navbar-brand" href="Default.aspx">
                    <i class="fas fa-shopping-cart"></i> E-Commerce Store
                </a>
                
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link active" href="Default.aspx">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Products.aspx">Products</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Categories.aspx">Categories</a>
                        </li>
                    </ul>
                    
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="Cart.aspx">
                                <i class="fas fa-shopping-cart"></i> Cart 
                                <span class="badge bg-warning text-dark" id="cartCount">0</span>
                            </a>
                        </li>
                        <li class="nav-item dropdown" id="userMenu" runat="server" visible="false">
                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user"></i> <asp:Literal ID="litUserName" runat="server" />
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="Account/Profile.aspx">Profile</a></li>
                                <li><a class="dropdown-item" href="Account/Orders.aspx">My Orders</a></li>
                                <li><hr class="dropdown-divider" /></li>
                                <li><asp:LinkButton ID="btnLogout" runat="server" CssClass="dropdown-item" OnClick="btnLogout_Click">Logout</asp:LinkButton></li>
                            </ul>
                        </li>
                        <li class="nav-item" id="loginMenu" runat="server">
                            <a class="nav-link" href="Account/Login.aspx">
                                <i class="fas fa-sign-in-alt"></i> Login
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Hero Section -->
        <section class="hero-section bg-light py-5">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-6">
                        <h1 class="display-4 fw-bold text-primary">Welcome to Our Store</h1>
                        <p class="lead">Discover amazing products at unbeatable prices. Shop with confidence and enjoy fast, secure delivery.</p>
                        <a href="Products.aspx" class="btn btn-primary btn-lg">Shop Now</a>
                    </div>
                    <div class="col-lg-6">
                        <img src="~/Images/hero-image.jpg" alt="Shopping" class="img-fluid rounded" />
                    </div>
                </div>
            </div>
        </section>

        <!-- Featured Products -->
        <section class="py-5">
            <div class="container">
                <h2 class="text-center mb-5">Featured Products</h2>
                
                <asp:UpdatePanel ID="upFeaturedProducts" runat="server">
                    <ContentTemplate>
                        <div class="row" id="featuredProducts">
                            <asp:Repeater ID="rptFeaturedProducts" runat="server">
                                <ItemTemplate>
                                    <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                                        <div class="card h-100 product-card">
                                            <img src='<%# ResolveUrl(Eval("ImageUrl", "~/Images/products/{0}").ToString()) %>' 
                                                 class="card-img-top" alt='<%# Eval("Name") %>' style="height: 200px; object-fit: cover;" />
                                            <div class="card-body d-flex flex-column">
                                                <h5 class="card-title"><%# Eval("Name") %></h5>
                                                <p class="card-text flex-grow-1"><%# Eval("Description") %></p>
                                                <div class="mt-auto">
                                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                                        <span class="h5 text-primary mb-0"><%# Eval("Price", "{0:C}") %></span>
                                                        <small class="text-muted">Stock: <%# Eval("StockQuantity") %></small>
                                                    </div>
                                                    <div class="btn-group w-100">
                                                        <a href='ProductDetails.aspx?id=<%# Eval("Id") %>' class="btn btn-outline-primary">View Details</a>
                                                        <button type="button" class="btn btn-primary" onclick="addToCart(<%# Eval("Id") %>)">
                                                            <i class="fas fa-cart-plus"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        
                        <asp:Label ID="lblNoProducts" runat="server" Text="No products available at the moment." 
                                   CssClass="alert alert-info text-center" Visible="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
                
                <div class="text-center mt-4">
                    <a href="Products.aspx" class="btn btn-outline-primary btn-lg">View All Products</a>
                </div>
            </div>
        </section>

        <!-- Categories Section -->
        <section class="py-5 bg-light">
            <div class="container">
                <h2 class="text-center mb-5">Shop by Category</h2>
                
                <asp:UpdatePanel ID="upCategories" runat="server">
                    <ContentTemplate>
                        <div class="row">
                            <asp:Repeater ID="rptCategories" runat="server">
                                <ItemTemplate>
                                    <div class="col-lg-2 col-md-3 col-sm-4 col-6 mb-4">
                                        <a href='Products.aspx?category=<%# Eval("Id") %>' class="text-decoration-none">
                                            <div class="card text-center category-card">
                                                <div class="card-body">
                                                    <i class="fas fa-tag fa-3x text-primary mb-3"></i>
                                                    <h6 class="card-title"><%# Eval("Name") %></h6>
                                                </div>
                                            </div>
                                        </a>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </section>

        <!-- Features Section -->
        <section class="py-5">
            <div class="container">
                <div class="row text-center">
                    <div class="col-lg-3 col-md-6 mb-4">
                        <div class="feature-box">
                            <i class="fas fa-shipping-fast fa-3x text-primary mb-3"></i>
                            <h5>Fast Shipping</h5>
                            <p>Free shipping on orders over $50</p>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-4">
                        <div class="feature-box">
                            <i class="fas fa-shield-alt fa-3x text-primary mb-3"></i>
                            <h5>Secure Payment</h5>
                            <p>Your payment information is safe with us</p>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-4">
                        <div class="feature-box">
                            <i class="fas fa-undo fa-3x text-primary mb-3"></i>
                            <h5>Easy Returns</h5>
                            <p>30-day return policy on all items</p>
                        </div>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-4">
                        <div class="feature-box">
                            <i class="fas fa-headset fa-3x text-primary mb-3"></i>
                            <h5>24/7 Support</h5>
                            <p>Customer support available around the clock</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Footer -->
        <footer class="bg-dark text-light py-4">
            <div class="container">
                <div class="row">
                    <div class="col-md-6">
                        <h5>E-Commerce Store</h5>
                        <p>Your trusted online shopping destination.</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <p>&copy; 2024 E-Commerce Store. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </footer>
    </form>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="~/Scripts/site.js"></script>
    
    <script type="text/javascript">
        // Add to cart functionality
        function addToCart(productId) {
            // This would typically make an AJAX call to add the product to cart
            PageMethods.AddToCart(productId, 1, onAddToCartSuccess, onAddToCartError);
        }
        
        function onAddToCartSuccess(result) {
            if (result.success) {
                updateCartCount();
                showNotification('Product added to cart!', 'success');
            } else {
                showNotification(result.message || 'Failed to add product to cart', 'error');
            }
        }
        
        function onAddToCartError(error) {
            showNotification('Error adding product to cart', 'error');
        }
        
        function updateCartCount() {
            // Update cart count in navigation
            var cart = getCartFromStorage();
            var totalItems = cart.reduce(function(sum, item) { return sum + item.quantity; }, 0);
            document.getElementById('cartCount').textContent = totalItems;
        }
        
        function getCartFromStorage() {
            var cart = localStorage.getItem('shoppingCart');
            return cart ? JSON.parse(cart) : [];
        }
        
        function showNotification(message, type) {
            // Simple notification system
            var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            var notification = '<div class="alert ' + alertClass + ' alert-dismissible fade show position-fixed" style="top: 20px; right: 20px; z-index: 9999;">' +
                              '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                              message + '</div>';
            document.body.insertAdjacentHTML('beforeend', notification);
            
            // Auto-dismiss after 3 seconds
            setTimeout(function() {
                var alerts = document.querySelectorAll('.alert');
                if (alerts.length > 0) {
                    alerts[alerts.length - 1].remove();
                }
            }, 3000);
        }
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            updateCartCount();
        });
    </script>
</body>
</html>
