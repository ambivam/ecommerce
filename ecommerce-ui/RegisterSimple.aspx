<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>Register - E-Commerce Store</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="/">E-Commerce Store</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="ProductsSimple.aspx">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="LoginSimple.aspx">Login</a>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h3 class="text-center">Create Your Account</h3>
                    </div>
                    <div class="card-body">
                        <form id="registerForm">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="firstName" class="form-label">First Name *</label>
                                        <input type="text" class="form-control" id="firstName" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="lastName" class="form-label">Last Name *</label>
                                        <input type="text" class="form-control" id="lastName" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="username" class="form-label">Username *</label>
                                        <input type="text" class="form-control" id="username" required>
                                        <div class="form-text">Must be 3-50 characters long</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Email *</label>
                                        <input type="email" class="form-control" id="email" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="password" class="form-label">Password *</label>
                                        <input type="password" class="form-control" id="password" required>
                                        <div class="form-text">Must be at least 6 characters long</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="confirmPassword" class="form-label">Confirm Password *</label>
                                        <input type="password" class="form-control" id="confirmPassword" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <input type="tel" class="form-control" id="phone">
                            </div>
                            
                            <div class="mb-3">
                                <label for="address" class="form-label">Address</label>
                                <textarea class="form-control" id="address" rows="2"></textarea>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="city" class="form-label">City</label>
                                        <input type="text" class="form-control" id="city">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="state" class="form-label">State</label>
                                        <input type="text" class="form-control" id="state">
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="zipCode" class="form-label">ZIP Code</label>
                                        <input type="text" class="form-control" id="zipCode">
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="country" class="form-label">Country</label>
                                <select class="form-select" id="country">
                                    <option value="">Select Country</option>
                                    <option value="US">United States</option>
                                    <option value="CA">Canada</option>
                                    <option value="UK">United Kingdom</option>
                                    <option value="IN">India</option>
                                    <option value="AU">Australia</option>
                                    <option value="DE">Germany</option>
                                    <option value="FR">France</option>
                                    <option value="JP">Japan</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg">Create Account</button>
                            </div>
                        </form>
                        
                        <div id="registerResult" class="mt-3"></div>
                        
                        <hr>
                        <div class="text-center">
                            <p>Already have an account? <a href="LoginSimple.aspx">Login here</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const resultDiv = document.getElementById('registerResult');
            
            // Validate passwords match
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                resultDiv.innerHTML = '<div class="alert alert-danger">Passwords do not match!</div>';
                return;
            }
            
            if (password.length < 6) {
                resultDiv.innerHTML = '<div class="alert alert-danger">Password must be at least 6 characters long!</div>';
                return;
            }
            
            // Show loading
            resultDiv.innerHTML = '<div class="alert alert-info">Creating account...</div>';
            
            // Prepare registration data
            const registerData = {
                username: document.getElementById('username').value,
                email: document.getElementById('email').value,
                password: password,
                firstName: document.getElementById('firstName').value,
                lastName: document.getElementById('lastName').value,
                phone: document.getElementById('phone').value || null,
                address: document.getElementById('address').value || null,
                city: document.getElementById('city').value || null,
                state: document.getElementById('state').value || null,
                zipCode: document.getElementById('zipCode').value || null,
                country: document.getElementById('country').value || null
            };
            
            // Call registration API
            fetch('http://localhost:8080/ecommerce-backend/api/users/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(registerData)
            })
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else if (response.status === 409) {
                    throw new Error('Username or email already exists');
                } else if (response.status === 400) {
                    throw new Error('Invalid data provided');
                } else {
                    throw new Error('Registration failed: ' + response.status);
                }
            })
            .then(data => {
                // Success
                resultDiv.innerHTML = `
                    <div class="alert alert-success">
                        <h5>Account Created Successfully!</h5>
                        <p>Welcome ${data.firstName}! Your account has been created.</p>
                        <p>Redirecting to login page...</p>
                    </div>
                `;
                
                // Redirect to login page
                setTimeout(() => {
                    window.location.href = 'LoginSimple.aspx';
                }, 2000);
            })
            .catch(error => {
                console.error('Registration error:', error);
                resultDiv.innerHTML = `
                    <div class="alert alert-danger">
                        <strong>Registration Failed:</strong> ${error.message}
                        <br><small>Make sure the backend API is running on port 8080</small>
                    </div>
                `;
            });
        });
        
        // Real-time password confirmation validation
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (confirmPassword && password !== confirmPassword) {
                this.setCustomValidity('Passwords do not match');
                this.classList.add('is-invalid');
            } else {
                this.setCustomValidity('');
                this.classList.remove('is-invalid');
            }
        });
        
        // Username validation
        document.getElementById('username').addEventListener('input', function() {
            const username = this.value;
            if (username.length > 0 && username.length < 3) {
                this.setCustomValidity('Username must be at least 3 characters long');
                this.classList.add('is-invalid');
            } else {
                this.setCustomValidity('');
                this.classList.remove('is-invalid');
            }
        });
    </script>
</body>
</html>
