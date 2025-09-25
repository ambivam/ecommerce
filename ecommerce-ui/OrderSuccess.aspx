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
    <title>Order Confirmation - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <style>
        .success-icon {
            font-size: 4rem;
            color: #28a745;
            margin-bottom: 20px;
        }
        .order-details {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        .order-item {
            border-bottom: 1px solid #dee2e6;
            padding: 10px 0;
        }
        .order-item:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in
    bool isUserLoggedIn = false;
    string userFirstName = "";
    string authToken = "";
    string orderId = Request.QueryString["orderId"];
    
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
        Response.Redirect("LoginWorking.aspx");
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

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="text-center">
                    <i class="fas fa-check-circle success-icon"></i>
                    <h1 class="text-success">Order Placed Successfully!</h1>
                    <p class="lead">Thank you for your purchase. Your order has been confirmed and is being processed.</p>
                </div>

                <div class="order-details">
                    <h4>Order Details</h4>
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Order ID:</strong> <span id="orderIdDisplay"><%= orderId %></span></p>
                            <p><strong>Order Date:</strong> <span id="orderDate"></span></p>
                            <p><strong>Status:</strong> <span class="badge bg-success">Confirmed</span></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Estimated Delivery:</strong> <span id="estimatedDelivery"></span></p>
                            <p><strong>Payment Method:</strong> Credit Card</p>
                        </div>
                    </div>
                </div>

                <div class="order-details">
                    <h4>Order Summary</h4>
                    <div id="orderItems">
                        <!-- Order items will be loaded here -->
                    </div>
                    <hr>
                    <div class="row">
                        <div class="col-md-8"></div>
                        <div class="col-md-4">
                            <div class="d-flex justify-content-between">
                                <span>Subtotal:</span>
                                <span id="orderSubtotal">$0.00</span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Shipping:</span>
                                <span class="text-success">FREE</span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Tax:</span>
                                <span id="orderTax">$0.00</span>
                            </div>
                            <hr>
                            <div class="d-flex justify-content-between fw-bold">
                                <span>Total:</span>
                                <span id="orderTotal">$0.00</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <div class="alert alert-info">
                        <h5><i class="fas fa-info-circle"></i> What's Next?</h5>
                        <ul class="list-unstyled mb-0">
                            <li><i class="fas fa-envelope"></i> You'll receive an order confirmation email shortly</li>
                            <li><i class="fas fa-truck"></i> We'll send you tracking information once your order ships</li>
                            <li><i class="fas fa-user"></i> You can track your order status in your dashboard</li>
                        </ul>
                    </div>
                    
                    <div class="d-grid gap-2 d-md-block">
                        <a href="UserDashboardSimple.aspx" class="btn btn-primary btn-lg">
                            <i class="fas fa-user"></i> View My Orders
                        </a>
                        <a href="ProductsWorking.aspx" class="btn btn-outline-primary btn-lg">
                            <i class="fas fa-shopping-bag"></i> Continue Shopping
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const authToken = '<%= authToken %>';
        const orderId = '<%= orderId %>';

        document.addEventListener('DOMContentLoaded', function() {
            setOrderDate();
            setEstimatedDelivery();
            loadOrderDetails();
        });

        function setOrderDate() {
            const now = new Date();
            const options = { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            };
            document.getElementById('orderDate').textContent = now.toLocaleDateString('en-US', options);
        }

        function setEstimatedDelivery() {
            const deliveryDate = new Date();
            deliveryDate.setDate(deliveryDate.getDate() + 5); // 5 business days
            const options = { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric'
            };
            document.getElementById('estimatedDelivery').textContent = deliveryDate.toLocaleDateString('en-US', options);
        }

        function loadOrderDetails() {
            if (!orderId) {
                showError('Order ID not found');
                return;
            }

            // First try to load from session storage (mock order)
            const lastOrder = sessionStorage.getItem('lastOrder');
            if (lastOrder) {
                const orderSummary = JSON.parse(lastOrder);
                if (orderSummary.orderId === orderId) {
                    displayMockOrderDetails(orderSummary);
                    return;
                }
            }

            // Try to load from API
            fetch(`http://localhost:8080/ecommerce-backend/api/orders/${orderId}`, {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayOrderDetails(data.order);
                } else {
                    // If order API is not available, show a generic success message
                    console.log('Order API not available, showing generic success');
                    displayGenericOrder();
                }
            })
            .catch(error => {
                console.error('Error loading order details:', error);
                // Show generic order details if API fails
                displayGenericOrder();
            });
        }

        function displayOrderDetails(order) {
            const orderItemsContainer = document.getElementById('orderItems');
            let itemsHtml = '';

            order.items.forEach(item => {
                itemsHtml += `
                    <div class="order-item">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h6 class="mb-1">${item.productName}</h6>
                                <small class="text-muted">Quantity: ${item.quantity}</small>
                            </div>
                            <div class="col-md-4 text-end">
                                <span>$${(parseFloat(item.price) * item.quantity).toFixed(2)}</span>
                            </div>
                        </div>
                    </div>
                `;
            });

            orderItemsContainer.innerHTML = itemsHtml;

            const subtotal = parseFloat(order.totalAmount);
            const tax = subtotal * 0.08;
            const total = subtotal + tax;

            document.getElementById('orderSubtotal').textContent = '$' + subtotal.toFixed(2);
            document.getElementById('orderTax').textContent = '$' + tax.toFixed(2);
            document.getElementById('orderTotal').textContent = '$' + total.toFixed(2);
        }

        function displayMockOrderDetails(orderSummary) {
            const cartData = orderSummary.cartData;
            const orderItemsContainer = document.getElementById('orderItems');
            let itemsHtml = '';

            if (cartData && cartData.items) {
                cartData.items.forEach(item => {
                    itemsHtml += `
                        <div class="order-item">
                            <div class="row align-items-center">
                                <div class="col-md-8">
                                    <h6 class="mb-1">${item.productName}</h6>
                                    <small class="text-muted">Quantity: ${item.quantity}</small>
                                </div>
                                <div class="col-md-4 text-end">
                                    <span>$${(parseFloat(item.price) * item.quantity).toFixed(2)}</span>
                                </div>
                            </div>
                        </div>
                    `;
                });

                const subtotal = parseFloat(cartData.totalAmount);
                const tax = subtotal * 0.08;
                const total = subtotal + tax;

                document.getElementById('orderSubtotal').textContent = '$' + subtotal.toFixed(2);
                document.getElementById('orderTax').textContent = '$' + tax.toFixed(2);
                document.getElementById('orderTotal').textContent = '$' + total.toFixed(2);
            } else {
                displayGenericOrder();
            }

            orderItemsContainer.innerHTML = itemsHtml;
        }

        function displayGenericOrder() {
            // Show a generic successful order message
            const orderItemsContainer = document.getElementById('orderItems');
            orderItemsContainer.innerHTML = `
                <div class="text-center py-4">
                    <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                    <p class="text-muted">Your order details are being processed and will be available shortly in your dashboard.</p>
                </div>
            `;

            // Set generic totals
            document.getElementById('orderSubtotal').textContent = 'Processing...';
            document.getElementById('orderTax').textContent = 'Processing...';
            document.getElementById('orderTotal').textContent = 'Processing...';
        }

        function showError(message) {
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
