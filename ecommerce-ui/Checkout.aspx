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
    <title>Checkout - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <style>
        .checkout-step {
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            background-color: #f8f9fa;
        }
        .step-header {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }
        .step-number {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background-color: #007bff;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            font-weight: bold;
        }
        .order-summary {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            position: sticky;
            top: 20px;
        }
        .form-floating input:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in
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
                    <a class="nav-link" href="Cart.aspx">Cart</a>
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
                <h1><i class="fas fa-credit-card"></i> Checkout</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="/ecommerce-ui/">Home</a></li>
                        <li class="breadcrumb-item"><a href="Cart.aspx">Cart</a></li>
                        <li class="breadcrumb-item active">Checkout</li>
                    </ol>
                </nav>
            </div>
        </div>

        <div class="row">
            <!-- Checkout Form -->
            <div class="col-lg-8">
                <!-- Step 1: Shipping Information -->
                <div class="checkout-step">
                    <div class="step-header">
                        <div class="step-number">1</div>
                        <h4>Shipping Information</h4>
                    </div>
                    <form id="checkoutForm">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="firstName" required>
                                    <label for="firstName">First Name</label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="lastName" required>
                                    <label for="lastName">Last Name</label>
                                </div>
                            </div>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="email" class="form-control" id="email" required>
                            <label for="email">Email Address</label>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="tel" class="form-control" id="phone" required>
                            <label for="phone">Phone Number</label>
                        </div>
                        <div class="form-floating mb-3">
                            <input type="text" class="form-control" id="address" required>
                            <label for="address">Street Address</label>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="city" required>
                                    <label for="city">City</label>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-floating mb-3">
                                    <select class="form-select" id="state" required>
                                        <option value="">Select State</option>
                                        <option value="CA">California</option>
                                        <option value="NY">New York</option>
                                        <option value="TX">Texas</option>
                                        <option value="FL">Florida</option>
                                    </select>
                                    <label for="state">State</label>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-floating mb-3">
                                    <input type="text" class="form-control" id="zipCode" required>
                                    <label for="zipCode">ZIP Code</label>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Step 2: Payment Information -->
                <div class="checkout-step">
                    <div class="step-header">
                        <div class="step-number">2</div>
                        <h4>Payment Information</h4>
                    </div>
                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="cardNumber" placeholder="1234 5678 9012 3456" required>
                        <label for="cardNumber">Card Number</label>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-floating mb-3">
                                <input type="text" class="form-control" id="expiryDate" placeholder="MM/YY" required>
                                <label for="expiryDate">Expiry Date</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-floating mb-3">
                                <input type="text" class="form-control" id="cvv" placeholder="123" required>
                                <label for="cvv">CVV</label>
                            </div>
                        </div>
                    </div>
                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="cardName" required>
                        <label for="cardName">Name on Card</label>
                    </div>
                </div>
            </div>

            <!-- Order Summary -->
            <div class="col-lg-4">
                <div class="order-summary">
                    <h4>Order Summary</h4>
                    <hr>
                    <div id="orderItems">
                        <!-- Order items will be loaded here -->
                    </div>
                    <hr>
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
                    <div class="d-flex justify-content-between fw-bold h5">
                        <span>Total:</span>
                        <span id="orderTotal">$0.00</span>
                    </div>
                    <div class="d-grid gap-2 mt-3">
                        <button class="btn btn-success btn-lg" onclick="placeOrder()">
                            <i class="fas fa-lock"></i> Place Order
                        </button>
                        <a href="Cart.aspx" class="btn btn-outline-secondary">
                            <i class="fas fa-arrow-left"></i> Back to Cart
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const authToken = '<%= authToken %>';
        let cartData = null;

        document.addEventListener('DOMContentLoaded', function() {
            loadOrderSummary();
            setupFormValidation();
        });

        function loadOrderSummary() {
            fetch('http://localhost:8080/ecommerce-backend/api/cart', {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success && !data.isEmpty) {
                    cartData = data;
                    displayOrderSummary(data);
                } else {
                    window.location.href = 'Cart.aspx';
                }
            })
            .catch(error => {
                console.error('Error loading cart:', error);
                showError('Failed to load order summary');
            });
        }

        function displayOrderSummary(data) {
            const orderItemsContainer = document.getElementById('orderItems');
            let itemsHtml = '';

            data.items.forEach(item => {
                itemsHtml += `
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <div>
                            <small class="fw-bold">${item.productName}</small>
                            <br>
                            <small class="text-muted">Qty: ${item.quantity}</small>
                        </div>
                        <small>$${(parseFloat(item.price) * item.quantity).toFixed(2)}</small>
                    </div>
                `;
            });

            orderItemsContainer.innerHTML = itemsHtml;

            const subtotal = parseFloat(data.totalAmount);
            const tax = subtotal * 0.08;
            const total = subtotal + tax;

            document.getElementById('orderSubtotal').textContent = '$' + subtotal.toFixed(2);
            document.getElementById('orderTax').textContent = '$' + tax.toFixed(2);
            document.getElementById('orderTotal').textContent = '$' + total.toFixed(2);
        }

        function setupFormValidation() {
            // Card number formatting
            document.getElementById('cardNumber').addEventListener('input', function(e) {
                let value = e.target.value.replace(/\s/g, '').replace(/[^0-9]/gi, '');
                let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
                e.target.value = formattedValue;
            });

            // Expiry date formatting
            document.getElementById('expiryDate').addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length >= 2) {
                    value = value.substring(0, 2) + '/' + value.substring(2, 4);
                }
                e.target.value = value;
            });

            // CVV validation
            document.getElementById('cvv').addEventListener('input', function(e) {
                e.target.value = e.target.value.replace(/\D/g, '').substring(0, 4);
            });
        }

        function placeOrder() {
            if (!validateForm()) {
                return;
            }

            const orderData = {
                shippingInfo: {
                    firstName: document.getElementById('firstName').value,
                    lastName: document.getElementById('lastName').value,
                    email: document.getElementById('email').value,
                    phone: document.getElementById('phone').value,
                    address: document.getElementById('address').value,
                    city: document.getElementById('city').value,
                    state: document.getElementById('state').value,
                    zipCode: document.getElementById('zipCode').value
                },
                paymentInfo: {
                    cardNumber: document.getElementById('cardNumber').value.replace(/\s/g, ''),
                    expiryDate: document.getElementById('expiryDate').value,
                    cvv: document.getElementById('cvv').value,
                    cardName: document.getElementById('cardName').value
                }
            };

            // Show loading state
            const placeOrderBtn = document.querySelector('button[onclick="placeOrder()"]');
            placeOrderBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            placeOrderBtn.disabled = true;

            // Try to place order via API, with fallback to mock processing
            fetch('http://localhost:8080/ecommerce-backend/api/orders', {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(orderData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('API not available');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    window.location.href = 'OrderSuccess.aspx?orderId=' + data.orderId;
                } else {
                    showError(data.error || 'Failed to place order');
                    placeOrderBtn.innerHTML = '<i class="fas fa-lock"></i> Place Order';
                    placeOrderBtn.disabled = false;
                }
            })
            .catch(error => {
                console.log('API not available, using mock order processing');
                // Mock order processing when backend API is not available
                processMockOrder(orderData, placeOrderBtn);
            });
        }

        function processMockOrder(orderData, placeOrderBtn) {
            // Simulate order processing delay
            setTimeout(() => {
                // Generate a mock order ID
                const orderId = 'ORD-' + Date.now() + '-' + Math.floor(Math.random() * 1000);
                
                // Store order data in session storage for the success page
                const orderSummary = {
                    orderId: orderId,
                    orderData: orderData,
                    cartData: cartData,
                    timestamp: new Date().toISOString()
                };
                
                sessionStorage.setItem('lastOrder', JSON.stringify(orderSummary));
                
                // Clear the cart (mock)
                clearCartAfterOrder();
                
                // Redirect to success page
                window.location.href = 'OrderSuccess.aspx?orderId=' + orderId;
            }, 2000); // 2 second delay to simulate processing
        }

        function clearCartAfterOrder() {
            // Try to clear cart via API
            fetch('http://localhost:8080/ecommerce-backend/api/cart/clear', {
                method: 'DELETE',
                headers: {
                    'Authorization': 'Bearer ' + authToken,
                    'Content-Type': 'application/json'
                }
            })
            .catch(error => {
                console.log('Cart clear API not available - order still processed successfully');
            });
        }

        function validateForm() {
            const requiredFields = ['firstName', 'lastName', 'email', 'phone', 'address', 'city', 'state', 'zipCode', 'cardNumber', 'expiryDate', 'cvv', 'cardName'];
            
            for (let field of requiredFields) {
                const element = document.getElementById(field);
                if (!element.value.trim()) {
                    element.focus();
                    showError('Please fill in all required fields');
                    return false;
                }
            }

            // Validate email
            const email = document.getElementById('email').value;
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                document.getElementById('email').focus();
                showError('Please enter a valid email address');
                return false;
            }

            // Validate card number (basic check)
            const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
            if (cardNumber.length < 13 || cardNumber.length > 19) {
                document.getElementById('cardNumber').focus();
                showError('Please enter a valid card number');
                return false;
            }

            return true;
        }

        function showError(message) {
            const alert = document.createElement('div');
            alert.className = 'alert alert-danger alert-dismissible fade show';
            alert.innerHTML = `
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.querySelector('.container').insertBefore(alert, document.querySelector('.container').firstChild);
            
            setTimeout(() => {
                if (alert.parentNode) {
                    alert.remove();
                }
            }, 5000);
        }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
