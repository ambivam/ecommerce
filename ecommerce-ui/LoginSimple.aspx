<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - E-Commerce Store</title>
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
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="text-center">Login to Your Account</h3>
                    </div>
                    <div class="card-body">
                        <form id="loginForm">
                            <div class="mb-3">
                                <label for="username" class="form-label">Username</label>
                                <input type="text" class="form-control" id="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" required>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">Login</button>
                            </div>
                        </form>
                        
                        <div id="loginResult" class="mt-3"></div>
                        
                        <hr>
                        <div class="text-center">
                            <p>Don't have an account? <a href="RegisterSimple.aspx">Register here</a></p>
                        </div>
                        
                        <div class="alert alert-info">
                            <h6>Demo Credentials:</h6>
                            <ul class="mb-0">
                                <li><strong>Admin:</strong> username: <code>admin</code>, password: <code>admin123</code></li>
                                <li><strong>User:</strong> username: <code>johndoe</code>, password: <code>user123</code></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const resultDiv = document.getElementById('loginResult');
            
            // Show loading
            resultDiv.innerHTML = '<div class="alert alert-info">Logging in...</div>';
            
            // Prepare login request
            const loginData = {
                username: username,
                password: password
            };
            
            // Call login API
            fetch('http://localhost:8080/ecommerce-backend/api/users/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(loginData)
            })
            .then(response => {
                if (response.ok) {
                    return response.json();
                } else {
                    throw new Error('Login failed: ' + response.status);
                }
            })
            .then(data => {
                // Success
                resultDiv.innerHTML = '<div class="alert alert-success">Login successful! Redirecting...</div>';
                
                // Store token (in a real app, use secure storage)
                localStorage.setItem('authToken', data.token);
                localStorage.setItem('userInfo', JSON.stringify(data.user));
                
                // Redirect to home page
                setTimeout(() => {
                    window.location.href = '/';
                }, 1500);
            })
            .catch(error => {
                console.error('Login error:', error);
                resultDiv.innerHTML = `
                    <div class="alert alert-danger">
                        <strong>Login Failed:</strong> ${error.message}
                        <br><small>Make sure the backend API is running on port 8080</small>
                    </div>
                `;
            });
        });
    </script>
</body>
</html>
