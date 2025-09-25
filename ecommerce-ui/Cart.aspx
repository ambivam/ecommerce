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
    <title>Shopping Cart - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        .cart-item-image {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 8px;
        }
        .quantity-input {
            width: 80px;
        }
        .cart-summary {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
        }
        .empty-cart {
            text-align: center;
            padding: 60px 20px;
        }
        .empty-cart-icon {
            font-size: 4rem;
            color: #6c757d;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in for navigation
    bool isUserLoggedIn = false;
    string userFirstName = "";
    string authToken = "";
    
    try
    {
        if (Session["UserInfo"] != null && Session["AuthToken"] != null)
        {
            var navSerializer = new JavaScriptSerializer();
            var navUserInfo = navSerializer.Deserialize<dynamic>(Session["UserInfo"].ToString());
            userFirstName = navUserInfo["firstName"];
            authToken = Session["AuthToken"].ToString();
            isUserLoggedIn = true;
        }
    }
    catch (Exception)
    {
        isUserLoggedIn = false;
    }
    
    if (!isUserLoggedIn)
    {
        Response.Write("<div class='container mt-5'><div class='alert alert-warning'><h4>Please Login</h4><p>You need to be logged in to view your cart.</p><a href='LoginWorking.aspx' class='btn btn-primary'>Go to Login</a></div></div>");
        return;
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
                    <a class="nav-link" href="UserDashboardSimple.aspx">My Dashboard</a>
                </li>
                <li class="nav-item">
                    <span class="navbar-text text-light me-3">Welcome, <%= userFirstName %>!</span>
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
                <h1>&#x1F6D2; My Shopping Cart</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="/ecommerce-ui/">Home</a></li>
                        <li class="breadcrumb-item"><a href="ProductsWorking.aspx">Products</a></li>
                        <li class="breadcrumb-item active">Cart</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Loading indicator -->
        <div id="loadingIndicator" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading cart...</span>
            </div>
            <p class="mt-2">Loading your cart...</p>
        </div>

        <!-- Cart content -->
        <div id="cartContent" style="display: none;">
            <div class="row">
                <!-- Cart Items -->
                <div class="col-lg-8">
                    <div id="cartItems">
                        <!-- Cart items will be loaded here -->
                    </div>
                </div>

                <!-- Cart Summary -->
                <div class="col-lg-4">
                    <div class="cart-summary sticky-top">
                        <h4>Order Summary</h4>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <span>Items (<span id="summaryItemCount">0</span>):</span>
                            <span id="summarySubtotal">$0.00</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Shipping:</span>
                            <span class="text-success">FREE</span>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Tax:</span>
                            <span id="summaryTax">$0.00</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between fw-bold">
                            <span>Total:</span>
                            <span id="summaryTotal">$0.00</span>
                        </div>
                        <div class="d-grid gap-2 mt-3">
                            <button id="checkoutBtn" class="btn btn-success btn-lg" onclick="proceedToCheckout()">
                                Proceed to Checkout
                            </button>
                            <a href="ProductsWorking.aspx" class="btn btn-outline-primary">
                                Continue Shopping
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Empty cart -->
        <div id="emptyCart" class="empty-cart" style="display: none;">
            <div class="empty-cart-icon">&#x1F6D2;</div>
            <h3>Your cart is empty</h3>
            <p class="text-muted">Looks like you haven't added any items to your cart yet.</p>
            <a href="ProductsWorking.aspx" class="btn btn-primary btn-lg">Start Shopping</a>
        </div>
    </div>

    <script>
        const authToken = '<%= authToken %>';
        let cartData = null;

        // Load cart on page load
        document.addEventListener('DOMContentLoaded', function() {
            loadCart();
        });

        // Load cart from API
        function loadCart() {
            fetch('http://localhost:8080/ecommerce-backend/api/cart', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                document.getElementById('loadingIndicator').style.display = 'none';
                
                if (data.success) {
                    cartData = data;
                    if (data.isEmpty) {
                        showEmptyCart();
                    } else {
                        displayCart(data);
                    }
                } else {
                    showError('Failed to load cart: ' + (data.error || 'Unknown error'));
                }
            })
            .catch(error => {
                document.getElementById('loadingIndicator').style.display = 'none';
                console.error('Error loading cart:', error);
                showError('Failed to load cart. Please check if the backend is running.');
            });
        }

        // Display cart items
        function displayCart(data) {
            const cartItemsContainer = document.getElementById('cartItems');
            let itemsHtml = '';

            data.items.forEach(item => {
                itemsHtml += `
                    <div class="card mb-3" id="cartItem-${item.id}">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-md-2">
                                    <img src="${item.productImageUrl || '/ecommerce-ui/images/default-product.jpg'}" 
                                         alt="${item.productName}" class="cart-item-image">
                                </div>
                                <div class="col-md-4">
                                    <h6 class="mb-1">${item.productName}</h6>
                                    <small class="text-muted">${item.categoryName || 'Uncategorized'}</small>
                                    <br>
                                    <small class="text-success">In Stock: ${item.stockQuantity}</small>
                                </div>
                                <div class="col-md-2">
                                    <strong>$${parseFloat(item.price).toFixed(2)}</strong>
                                </div>
                                <div class="col-md-2">
                                    <div class="input-group">
                                        <button class="btn btn-outline-secondary btn-sm" onclick="updateQuantity(${item.id}, ${item.quantity - 1})">-</button>
                                        <input type="number" class="form-control quantity-input text-center" 
                                               value="${item.quantity}" min="1" max="${item.stockQuantity}"
                                               onchange="updateQuantity(${item.id}, this.value)">
                                        <button class="btn btn-outline-secondary btn-sm" onclick="updateQuantity(${item.id}, ${item.quantity + 1})">+</button>
                                    </div>
                                </div>
                                <div class="col-md-2 text-end">
                                    <strong>$${(parseFloat(item.price) * item.quantity).toFixed(2)}</strong>
                                    <br>
                                    <button class="btn btn-outline-danger btn-sm mt-1" onclick="removeItem(${item.id})">
                                        Remove
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                `;
            });

            cartItemsContainer.innerHTML = itemsHtml;
            updateSummary(data);
            document.getElementById('cartContent').style.display = 'block';
        }

        // Update cart summary
        function updateSummary(data) {
            const subtotal = parseFloat(data.totalAmount);
            const tax = subtotal * 0.08; // 8% tax
            const total = subtotal + tax;

            document.getElementById('summaryItemCount').textContent = data.totalItems;
            document.getElementById('summarySubtotal').textContent = '$' + subtotal.toFixed(2);
            document.getElementById('summaryTax').textContent = '$' + tax.toFixed(2);
            document.getElementById('summaryTotal').textContent = '$' + total.toFixed(2);
        }

        // Update item quantity
        function updateQuantity(cartId, newQuantity) {
            if (newQuantity < 1) {
                removeItem(cartId);
                return;
            }

            fetch(`http://localhost:8080/ecommerce-backend/api/cart/${cartId}`, {
                method: 'PUT',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ quantity: parseInt(newQuantity) })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    loadCart(); // Reload cart to get updated data
                    showSuccess(data.message);
                } else {
                    showError(data.error || 'Failed to update quantity');
                }
            })
            .catch(error => {
                console.error('Error updating quantity:', error);
                showError('Failed to update quantity');
            });
        }

        // Remove item from cart
        function removeItem(cartId) {
            if (!confirm('Are you sure you want to remove this item from your cart?')) {
                return;
            }

            fetch(`http://localhost:8080/ecommerce-backend/api/cart/${cartId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    loadCart(); // Reload cart
                    showSuccess(data.message);
                } else {
                    showError(data.error || 'Failed to remove item');
                }
            })
            .catch(error => {
                console.error('Error removing item:', error);
                showError('Failed to remove item');
            });
        }

        // Clear entire cart
        function clearCart() {
            if (!confirm('Are you sure you want to clear your entire cart?')) {
                return;
            }

            fetch('http://localhost:8080/ecommerce-backend/api/cart/clear', {
                method: 'DELETE',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showEmptyCart();
                    showSuccess(data.message);
                } else {
                    showError(data.error || 'Failed to clear cart');
                }
            })
            .catch(error => {
                console.error('Error clearing cart:', error);
                showError('Failed to clear cart');
            });
        }

        // Show empty cart
        function showEmptyCart() {
            document.getElementById('cartContent').style.display = 'none';
            document.getElementById('emptyCart').style.display = 'block';
        }

        // Proceed to checkout
        function proceedToCheckout() {
            alert('Checkout functionality will be implemented next! Current total: ' + document.getElementById('summaryTotal').textContent);
        }

        // Show success message
        function showSuccess(message) {
            // Create and show success alert
            const alert = document.createElement('div');
            alert.className = 'alert alert-success alert-dismissible fade show';
            alert.innerHTML = `
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('.container').insertBefore(alert, document.querySelector('.container').firstChild);
            
            // Auto-dismiss after 3 seconds
            setTimeout(() => {
                if (alert.parentNode) {
                    alert.remove();
                }
            }, 3000);
        }

        // Show error message
        function showError(message) {
            // Create and show error alert
            const alert = document.createElement('div');
            alert.className = 'alert alert-danger alert-dismissible fade show';
            alert.innerHTML = `
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('.container').insertBefore(alert, document.querySelector('.container').firstChild);
        }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
