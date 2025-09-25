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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
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
        // Global variables
        let isLoggedIn = <%= isUserLoggedIn.ToString().ToLower() %>;
        let authToken = '<%= Session["AuthToken"] %>';
        let userInfo = '<%= Session["UserInfo"] %>';
        let productsData = []; // Store products data globally

        function addToCart(productId) {
            if (!isLoggedIn) {
                showLoginRequiredModal();
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
            // Find the product data
            let product = productsData.find(p => p.id == productId);
            
            // If products data not loaded yet, try to fetch it first
            if (!product && productsData.length === 0) {
                loadProductsData();
                // Use a fallback product data structure
                product = createFallbackProduct(productId);
            }
            
            if (!product) {
                showNotification('&#10060; Product not found', 'error');
                return;
            }
            
            // Populate modal with product details (with safe checks)
            document.getElementById('modalProductName').textContent = product.name || 'Product Name';
            document.getElementById('modalProductPrice').textContent = '$' + (product.price || '0.00');
            document.getElementById('modalProductDescription').textContent = product.description || 'No description available.';
            document.getElementById('modalProductCategory').textContent = product.category || 'General';
            document.getElementById('modalProductStock').textContent = product.stock || '0';
            
            // Set product image (use simple placeholder if no image)
            const modalImage = document.getElementById('modalProductImage');
            const productName = product.name || 'Product';
            
            // Check if product has a valid, accessible image URL
            if (product.imageUrl && product.imageUrl.startsWith('http')) {
                // Test if the image URL is accessible before setting it
                const testImg = new Image();
                testImg.onload = function() {
                    modalImage.src = product.imageUrl;
                };
                testImg.onerror = function() {
                    // If image fails to load, use canvas placeholder
                    createCanvasPlaceholder(modalImage, productName);
                };
                testImg.src = product.imageUrl;
            } else {
                // Use canvas placeholder for no image
                createCanvasPlaceholder(modalImage, productName);
            }
            
            modalImage.alt = productName;
            
            // Populate features based on product category and details
            const featuresContainer = document.getElementById('modalProductFeatures');
            const specsContainer = document.getElementById('modalProductSpecs');
            
            // Clear previous content
            featuresContainer.innerHTML = '';
            specsContainer.innerHTML = '';
            
            // Generate features and specs based on product type
            const features = getProductFeatures(product);
            const specs = getProductSpecs(product);
            
            // Add features
            features.forEach(feature => {
                const li = document.createElement('li');
                li.innerHTML = '<i class="fas fa-check text-success me-2"></i>' + feature;
                li.className = 'mb-1';
                featuresContainer.appendChild(li);
            });
            
            // Add specifications
            Object.entries(specs).forEach(([key, value]) => {
                const specDiv = document.createElement('div');
                specDiv.innerHTML = '<strong>' + key + ':</strong> ' + value;
                specDiv.className = 'mb-1';
                specsContainer.appendChild(specDiv);
            });
            
            // Update add to cart button in modal
            const modalAddToCartBtn = document.getElementById('modalAddToCartBtn');
            modalAddToCartBtn.onclick = () => {
                // Check login status first
                if (!isLoggedIn) {
                    closeModal(); // Close product details modal first
                    showLoginRequiredModal(); // Show login required modal
                    return;
                }
                
                const originalText = modalAddToCartBtn.innerHTML;
                const originalClass = modalAddToCartBtn.className;
                
                // Call addToCart function
                addToCart(productId, modalAddToCartBtn);
                
                // Show success state in modal button
                modalAddToCartBtn.innerHTML = '<i class="fas fa-check"></i> Added!';
                modalAddToCartBtn.className = 'btn btn-success';
                modalAddToCartBtn.disabled = true;
                
                // Close modal after showing success
                setTimeout(() => {
                    closeModal();
                    // Reset button state for next time
                    modalAddToCartBtn.innerHTML = originalText;
                    modalAddToCartBtn.className = originalClass;
                    modalAddToCartBtn.disabled = false;
                }, 1500); // Wait 1.5 seconds to show success message, then close
            };
            
            // Disable button if out of stock
            if (product.stock <= 0) {
                modalAddToCartBtn.disabled = true;
                modalAddToCartBtn.innerHTML = '<i class="fas fa-times"></i> Out of Stock';
                modalAddToCartBtn.className = 'btn btn-danger';
            } else {
                modalAddToCartBtn.disabled = false;
                modalAddToCartBtn.innerHTML = '<i class="fas fa-shopping-cart"></i> Add to Cart';
                modalAddToCartBtn.className = 'btn btn-primary';
            }
            
            // Show the modal and set up close handlers
            const modalElement = document.getElementById('productDetailsModal');
            
            // Always set up close button handlers
            const closeButtons = modalElement.querySelectorAll('[data-bs-dismiss="modal"], .btn-close');
            closeButtons.forEach(btn => {
                btn.onclick = function(e) {
                    e.preventDefault();
                    closeModal();
                };
            });
            
            // Add keyboard support (Escape key)
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && modalElement.classList.contains('show')) {
                    closeModal();
                }
            });
            
            if (typeof bootstrap !== 'undefined') {
                const modal = new bootstrap.Modal(modalElement);
                modal.show();
            } else {
                // Fallback: show modal manually if Bootstrap JS not loaded
                modalElement.style.display = 'block';
                modalElement.classList.add('show');
                modalElement.setAttribute('aria-hidden', 'false');
                document.body.classList.add('modal-open');
                
                // Add backdrop
                const backdrop = document.createElement('div');
                backdrop.className = 'modal-backdrop fade show';
                backdrop.id = 'modal-backdrop';
                document.body.appendChild(backdrop);
                
                // Close on backdrop click
                backdrop.onclick = function() {
                    closeModal();
                };
            }
        }
        
        function closeModal() {
            const modalElement = document.getElementById('productDetailsModal');
            
            // Try Bootstrap modal first
            if (typeof bootstrap !== 'undefined') {
                const modal = bootstrap.Modal.getInstance(modalElement);
                if (modal) {
                    modal.hide();
                    return;
                }
            }
            
            // Fallback manual close
            const backdrop = document.getElementById('modal-backdrop');
            
            modalElement.style.display = 'none';
            modalElement.classList.remove('show');
            modalElement.setAttribute('aria-hidden', 'true');
            document.body.classList.remove('modal-open');
            
            if (backdrop) {
                backdrop.remove();
            }
        }
        
        function createCanvasPlaceholder(imageElement, productName) {
            const canvas = document.createElement('canvas');
            canvas.width = 300;
            canvas.height = 200;
            const ctx = canvas.getContext('2d');
            
            // Draw background
            ctx.fillStyle = '#6c757d';
            ctx.fillRect(0, 0, 300, 200);
            
            // Draw text
            ctx.fillStyle = '#ffffff';
            ctx.font = '20px Arial';
            ctx.textAlign = 'center';
            ctx.fillText('No Image', 150, 100);
            
            imageElement.src = canvas.toDataURL();
        }
        
        function getProductFeatures(product) {
            const features = [];
            
            // Safe category check
            const category = product && product.category ? product.category.toLowerCase() : 'general';
            
            switch(category) {
                case 'electronics':
                    const productName = product && product.name ? product.name.toLowerCase() : '';
                    if (productName.includes('smartphone')) {
                        features.push('High-resolution display');
                        features.push('Advanced camera system');
                        features.push('Fast charging capability');
                        features.push('Water-resistant design');
                        features.push('Latest operating system');
                    } else if (productName.includes('laptop')) {
                        features.push('High-performance processor');
                        features.push('Full HD display');
                        features.push('Long battery life');
                        features.push('Lightweight and portable');
                        features.push('Multiple connectivity options');
                    }
                    break;
                case 'clothing':
                    features.push('Premium quality fabric');
                    features.push('Comfortable fit');
                    features.push('Machine washable');
                    features.push('Durable construction');
                    features.push('Available in multiple sizes');
                    break;
                case 'books':
                    features.push('Comprehensive coverage');
                    features.push('Easy to understand examples');
                    features.push('Updated content');
                    features.push('Practical exercises');
                    features.push('Expert author');
                    break;
                case 'home & garden':
                    features.push('Durable materials');
                    features.push('Easy to use');
                    features.push('Weather resistant');
                    features.push('Complete set included');
                    features.push('Ergonomic design');
                    break;
                default:
                    features.push('High quality construction');
                    features.push('Excellent value for money');
                    features.push('Reliable performance');
                    features.push('Customer satisfaction guaranteed');
            }
            
            return features;
        }
        
        function getProductSpecs(product) {
            const specs = {};
            
            // Safe category and name checks
            const category = product && product.category ? product.category.toLowerCase() : 'general';
            const productName = product && product.name ? product.name.toLowerCase() : '';
            
            switch(category) {
                case 'electronics':
                    if (productName.includes('smartphone')) {
                        specs['Display'] = '6.1" Super Retina XDR';
                        specs['Storage'] = '128GB / 256GB / 512GB';
                        specs['Camera'] = '12MP Triple Camera System';
                        specs['Battery'] = 'Up to 17 hours video playback';
                        specs['OS'] = 'Latest iOS';
                    } else if (productName.includes('laptop')) {
                        specs['Processor'] = 'Intel Core i7 / AMD Ryzen 7';
                        specs['RAM'] = '16GB DDR4';
                        specs['Storage'] = '512GB SSD';
                        specs['Display'] = '15.6" Full HD IPS';
                        specs['Graphics'] = 'Integrated / Dedicated GPU';
                    }
                    break;
                case 'clothing':
                    specs['Material'] = '100% Cotton Denim';
                    specs['Fit'] = 'Classic / Slim / Regular';
                    specs['Care'] = 'Machine wash cold';
                    specs['Origin'] = 'Made with premium materials';
                    break;
                case 'books':
                    specs['Pages'] = '400-500 pages';
                    specs['Publisher'] = 'Tech Publications';
                    specs['Language'] = 'English';
                    specs['Format'] = 'Paperback / Hardcover';
                    break;
                case 'home & garden':
                    specs['Material'] = 'Stainless Steel / Carbon Steel';
                    specs['Set Includes'] = 'Multiple tools and accessories';
                    specs['Warranty'] = '2 year manufacturer warranty';
                    specs['Weight'] = 'Lightweight design';
                    break;
            }
            
            specs['SKU'] = 'TECH-' + product.id.toString().padStart(4, '0');
            specs['Availability'] = product.stock > 0 ? 'In Stock' : 'Out of Stock';
            
            return specs;
        }
        
        function createFallbackProduct(productId) {
            // Create a basic product structure from the DOM if API data not available
            const productCards = document.querySelectorAll('.card');
            for (let card of productCards) {
                const button = card.querySelector('button[onclick*="viewDetails(' + productId + ')"]');
                if (button) {
                    const name = card.querySelector('.card-title')?.textContent || 'Product';
                    const price = card.querySelector('.text-success')?.textContent?.replace('$', '') || '0';
                    const category = card.querySelector('.badge')?.textContent || 'General';
                    const stockText = card.querySelector('.text-muted')?.textContent || 'Stock: 0';
                    const stock = stockText.match(/\d+/)?.[0] || '0';
                    
                    return {
                        id: productId,
                        name: name,
                        price: price,
                        description: 'Detailed product information will be available soon.',
                        category: category,
                        stock: parseInt(stock),
                        imageUrl: null
                    };
                }
            }
            return null;
        }

        function showNotification(message, type) {
            // Create notification element
            const notification = document.createElement('div');
            notification.className = `alert alert-${type === 'success' ? 'success' : 'danger'} alert-dismissible fade show position-fixed`;
            notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
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
        
        function showLoginRequiredModal() {
            // Create modal HTML
            const modalHtml = `
                <div class="modal fade show" id="loginRequiredModal" tabindex="-1" aria-labelledby="loginRequiredModalLabel" aria-hidden="false" style="display: block;">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="loginRequiredModalLabel">
                                    <i class="fas fa-sign-in-alt text-primary"></i> Login Required
                                </h5>
                                <button type="button" class="btn-close" onclick="closeLoginModal()" aria-label="Close"></button>
                            </div>
                            <div class="modal-body text-center">
                                <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                                <h6>Please log in to add items to your cart</h6>
                                <p class="text-muted">You need to be logged in to start shopping and add items to your cart.</p>
                            </div>
                            <div class="modal-footer justify-content-center">
                                <button type="button" class="btn btn-secondary" onclick="closeLoginModal()">Cancel</button>
                                <a href="LoginWorking.aspx" class="btn btn-primary">
                                    <i class="fas fa-sign-in-alt"></i> Login Now
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-backdrop fade show" id="loginModalBackdrop" onclick="closeLoginModal()"></div>
            `;
            
            // Remove existing modal if any
            const existingModal = document.getElementById('loginRequiredModal');
            if (existingModal) {
                existingModal.remove();
            }
            const existingBackdrop = document.getElementById('loginModalBackdrop');
            if (existingBackdrop) {
                existingBackdrop.remove();
            }
            
            // Add modal to page
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            document.body.classList.add('modal-open');
            
            // Add keyboard support (Escape key)
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && document.getElementById('loginRequiredModal')) {
                    closeLoginModal();
                }
            });
        }
        
        function closeLoginModal() {
            const modal = document.getElementById('loginRequiredModal');
            const backdrop = document.getElementById('loginModalBackdrop');
            
            if (modal) {
                modal.remove();
            }
            if (backdrop) {
                backdrop.remove();
            }
            document.body.classList.remove('modal-open');
        }

        // Load cart count and products data on page load
        document.addEventListener('DOMContentLoaded', function() {
            loadProductsData();
            if (isLoggedIn && authToken) {
                loadCartCount();
            }
        });
        
        function loadProductsData() {
            fetch('http://localhost:8080/ecommerce-backend/api/products')
            .then(response => response.json())
            .then(data => {
                if (data && Array.isArray(data)) {
                    productsData = data;
                } else {
                    console.error('Invalid products data received');
                }
            })
            .catch(error => {
                console.error('Error loading products data:', error);
            });
        }

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

    <!-- Product Details Modal -->
    <div class="modal fade" id="productDetailsModal" tabindex="-1" aria-labelledby="productDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="productDetailsModalLabel">Product Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <img id="modalProductImage" src="" alt="" class="img-fluid rounded mb-3" style="width: 100%; max-height: 300px; object-fit: cover;">
                        </div>
                        <div class="col-md-6">
                            <h4 id="modalProductName" class="text-primary mb-3"></h4>
                            <div class="mb-3">
                                <h5 class="text-success" id="modalProductPrice"></h5>
                            </div>
                            <div class="mb-3">
                                <strong>Category:</strong> <span id="modalProductCategory" class="badge bg-secondary ms-2"></span>
                            </div>
                            <div class="mb-3">
                                <strong>Stock Available:</strong> <span id="modalProductStock" class="text-info fw-bold"></span> units
                            </div>
                            <div class="mb-4">
                                <h6>Description:</h6>
                                <p id="modalProductDescription" class="text-muted"></p>
                            </div>
                            
                            <!-- Product Features -->
                            <div class="mb-4">
                                <h6>Key Features:</h6>
                                <ul id="modalProductFeatures" class="list-unstyled">
                                    <!-- Features will be populated dynamically -->
                                </ul>
                            </div>
                            
                            <!-- Product Specifications -->
                            <div class="mb-4">
                                <h6>Specifications:</h6>
                                <div id="modalProductSpecs" class="small text-muted">
                                    <!-- Specifications will be populated dynamically -->
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="modalAddToCartBtn">
                        <i class="fas fa-shopping-cart"></i> Add to Cart
                    </button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
