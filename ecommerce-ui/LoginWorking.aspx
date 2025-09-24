<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - E-Commerce Store</title>
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
                        <%
                        string message = "";
                        string messageClass = "";
                        
                        if (Request.HttpMethod == "POST")
                        {
                            try
                            {
                                string username = Request.Form["username"];
                                string password = Request.Form["password"];
                                
                                // Validate
                                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
                                {
                                    message = "Username and password are required!";
                                    messageClass = "alert-danger";
                                }
                                else
                                {
                                    // Prepare JSON data
                                    string json = string.Format(@"{{
                                        ""username"": ""{0}"",
                                        ""password"": ""{1}""
                                    }}", username, password);
                                    
                                    // Call API
                                    using (var client = new System.Net.WebClient())
                                    {
                                        client.Headers.Add("Content-Type", "application/json");
                                        string url = "http://localhost:8080/ecommerce-backend/api/users/login";
                                        string response = client.UploadString(url, "POST", json);
                                        
                                        // Parse response to get token and user info
                                        var serializer = new JavaScriptSerializer();
                                        var loginResult = serializer.Deserialize<dynamic>(response);
                                        
                                        // Store in session (in production, use secure storage)
                                        Session["AuthToken"] = loginResult["token"];
                                        Session["UserInfo"] = loginResult["user"];
                                        
                                        message = string.Format("Login successful! Welcome {0}! <a href='/ecommerce-ui/'>Go to Homepage</a>", 
                                                              loginResult["user"]["firstName"]);
                                        messageClass = "alert-success";
                                    }
                                }
                            }
                            catch (System.Net.WebException ex)
                            {
                                var response = ex.Response as System.Net.HttpWebResponse;
                                if (response != null && response.StatusCode == HttpStatusCode.Unauthorized)
                                {
                                    message = "Invalid username or password. Please try again.";
                                    messageClass = "alert-danger";
                                }
                                else if (response != null)
                                {
                                    using (var reader = new System.IO.StreamReader(response.GetResponseStream()))
                                    {
                                        string errorContent = reader.ReadToEnd();
                                        message = "Login failed: " + errorContent;
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
                                message = "Login failed: " + ex.Message;
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
                            <div class="mb-3">
                                <label for="username" class="form-label">Username</label>
                                <input type="text" class="form-control" name="username" required 
                                       value="<%= Request.Form["username"] ?? "" %>" />
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" name="password" required />
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary">Login</button>
                            </div>
                        </form>
                        
                        <hr>
                        <div class="text-center">
                            <p>Don't have an account? <a href="RegisterWorking.aspx">Register here</a></p>
                        </div>
                        
                        <div class="alert alert-info">
                            <h6>Demo Credentials:</h6>
                            <ul class="mb-0">
                                <li><strong>Admin:</strong> username: <code>admin</code>, password: <code>admin123</code></li>
                                <li><strong>User:</strong> username: <code>johndoe</code>, password: <code>user123</code></li>
                                <li><strong>New User:</strong> Use account created via registration</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
