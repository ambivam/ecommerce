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
            <a class="navbar-brand" href="/ecommerce-ui/">E-Commerce Store</a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/ecommerce-ui/">Home</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="ProductsSimple.aspx">Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="LoginWorking.aspx">Login</a>
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
                        <%
                        string message = "";
                        string messageClass = "";
                        
                        if (Request.HttpMethod == "POST")
                        {
                            try
                            {
                                string firstName = Request.Form["firstName"];
                                string lastName = Request.Form["lastName"];
                                string username = Request.Form["username"];
                                string email = Request.Form["email"];
                                string password = Request.Form["password"];
                                string confirmPassword = Request.Form["confirmPassword"];
                                
                                // Validate
                                if (password != confirmPassword)
                                {
                                    message = "Passwords do not match!";
                                    messageClass = "alert-danger";
                                }
                                else if (password.Length < 6)
                                {
                                    message = "Password must be at least 6 characters long!";
                                    messageClass = "alert-danger";
                                }
                                else
                                {
                                    // Prepare JSON data
                                    string json = string.Format(@"{{
                                        ""username"": ""{0}"",
                                        ""email"": ""{1}"",
                                        ""password"": ""{2}"",
                                        ""firstName"": ""{3}"",
                                        ""lastName"": ""{4}""
                                    }}", username, email, password, firstName, lastName);
                                    
                                    // Call API
                                    using (var client = new System.Net.WebClient())
                                    {
                                        client.Headers.Add("Content-Type", "application/json");
                                        string url = "http://localhost:8080/ecommerce-backend/api/users/register";
                                        string response = client.UploadString(url, "POST", json);
                                        
                                        message = "Account created successfully! <a href='LoginSimple.aspx'>Click here to login</a>";
                                        messageClass = "alert-success";
                                    }
                                }
                            }
                            catch (System.Net.WebException ex)
                            {
                                var response = ex.Response as System.Net.HttpWebResponse;
                                if (response != null)
                                {
                                    using (var reader = new System.IO.StreamReader(response.GetResponseStream()))
                                    {
                                        string errorContent = reader.ReadToEnd();
                                        if (errorContent.Contains("already exists"))
                                        {
                                            message = "Username or email already exists. Please choose different ones.";
                                        }
                                        else
                                        {
                                            message = "Registration failed: " + errorContent;
                                        }
                                        messageClass = "alert-danger";
                                    }
                                }
                                else
                                {
                                    message = "Unable to connect to backend API. Please ensure the Java backend is running.";
                                    messageClass = "alert-danger";
                                }
                            }
                            catch (Exception ex)
                            {
                                message = "Registration failed: " + ex.Message;
                                messageClass = "alert-danger";
                            }
                        }
                        %>
                        
                        <% if (!string.IsNullOrEmpty(message)) { %>
                            <div class="alert <%= messageClass %>">
                                <%= message %>
                            </div>
                        <% } %>
                        
                        <form method="post">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="firstName" class="form-label">First Name *</label>
                                        <input type="text" class="form-control" name="firstName" required 
                                               value="<%= Request.Form["firstName"] ?? "" %>" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="lastName" class="form-label">Last Name *</label>
                                        <input type="text" class="form-control" name="lastName" required 
                                               value="<%= Request.Form["lastName"] ?? "" %>" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="username" class="form-label">Username *</label>
                                        <input type="text" class="form-control" name="username" required 
                                               value="<%= Request.Form["username"] ?? "" %>" />
                                        <div class="form-text">Must be 3-50 characters long</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Email *</label>
                                        <input type="email" class="form-control" name="email" required 
                                               value="<%= Request.Form["email"] ?? "" %>" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="password" class="form-label">Password *</label>
                                        <input type="password" class="form-control" name="password" required />
                                        <div class="form-text">Must be at least 6 characters long</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="confirmPassword" class="form-label">Confirm Password *</label>
                                        <input type="password" class="form-control" name="confirmPassword" required />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg">Create Account</button>
                            </div>
                        </form>
                        
                        <hr>
                        <div class="text-center">
                            <p>Already have an account? <a href="LoginWorking.aspx">Login here</a></p>
                        </div>
                        
                        <div class="alert alert-info mt-3">
                            <h6>Test Registration:</h6>
                            <p>Use any unique username and email to create a test account.</p>
                            <p><strong>Example:</strong> Username: <code>john2025</code>, Email: <code>john2025@test.com</code></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
