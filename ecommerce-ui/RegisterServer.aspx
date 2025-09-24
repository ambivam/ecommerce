<%@ Page Language="C#" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>

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
                        <form id="form1" runat="server" method="post">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="firstName" class="form-label">First Name *</label>
                                        <asp:TextBox ID="firstName" runat="server" CssClass="form-control" Required="true" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="lastName" class="form-label">Last Name *</label>
                                        <asp:TextBox ID="lastName" runat="server" CssClass="form-control" Required="true" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="username" class="form-label">Username *</label>
                                        <asp:TextBox ID="username" runat="server" CssClass="form-control" Required="true" />
                                        <div class="form-text">Must be 3-50 characters long</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Email *</label>
                                        <asp:TextBox ID="email" runat="server" CssClass="form-control" TextMode="Email" Required="true" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="password" class="form-label">Password *</label>
                                        <asp:TextBox ID="password" runat="server" CssClass="form-control" TextMode="Password" Required="true" />
                                        <div class="form-text">Must be at least 6 characters long</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="confirmPassword" class="form-label">Confirm Password *</label>
                                        <asp:TextBox ID="confirmPassword" runat="server" CssClass="form-control" TextMode="Password" Required="true" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="phone" class="form-label">Phone Number</label>
                                <asp:TextBox ID="phone" runat="server" CssClass="form-control" />
                            </div>
                            
                            <div class="mb-3">
                                <label for="address" class="form-label">Address</label>
                                <asp:TextBox ID="address" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                            </div>
                            
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="city" class="form-label">City</label>
                                        <asp:TextBox ID="city" runat="server" CssClass="form-control" />
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="state" class="form-label">State</label>
                                        <asp:TextBox ID="state" runat="server" CssClass="form-control" />
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label for="zipCode" class="form-label">ZIP Code</label>
                                        <asp:TextBox ID="zipCode" runat="server" CssClass="form-control" />
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="country" class="form-label">Country</label>
                                <asp:DropDownList ID="country" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="">Select Country</asp:ListItem>
                                    <asp:ListItem Value="US">United States</asp:ListItem>
                                    <asp:ListItem Value="CA">Canada</asp:ListItem>
                                    <asp:ListItem Value="UK">United Kingdom</asp:ListItem>
                                    <asp:ListItem Value="IN">India</asp:ListItem>
                                    <asp:ListItem Value="AU">Australia</asp:ListItem>
                                    <asp:ListItem Value="DE">Germany</asp:ListItem>
                                    <asp:ListItem Value="FR">France</asp:ListItem>
                                    <asp:ListItem Value="JP">Japan</asp:ListItem>
                                    <asp:ListItem Value="Other">Other</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            
                            <div class="d-grid">
                                <asp:Button ID="btnRegister" runat="server" Text="Create Account" 
                                           CssClass="btn btn-primary btn-lg" OnClick="btnRegister_Click" />
                            </div>
                        </form>
                        
                        <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="mt-3">
                            <asp:Literal ID="litResult" runat="server" />
                        </asp:Panel>
                        
                        <hr>
                        <div class="text-center">
                            <p>Already have an account? <a href="LoginSimple.aspx">Login here</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script runat="server">
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate passwords match
                if (password.Text != confirmPassword.Text)
                {
                    ShowError("Passwords do not match!");
                    return;
                }
                
                if (password.Text.Length < 6)
                {
                    ShowError("Password must be at least 6 characters long!");
                    return;
                }
                
                // Prepare registration data
                var registerData = new Dictionary<string, object>
                {
                    {"username", username.Text.Trim()},
                    {"email", email.Text.Trim()},
                    {"password", password.Text},
                    {"firstName", firstName.Text.Trim()},
                    {"lastName", lastName.Text.Trim()},
                    {"phone", string.IsNullOrEmpty(phone.Text) ? null : phone.Text.Trim()},
                    {"address", string.IsNullOrEmpty(address.Text) ? null : address.Text.Trim()},
                    {"city", string.IsNullOrEmpty(city.Text) ? null : city.Text.Trim()},
                    {"state", string.IsNullOrEmpty(state.Text) ? null : state.Text.Trim()},
                    {"zipCode", string.IsNullOrEmpty(zipCode.Text) ? null : zipCode.Text.Trim()},
                    {"country", string.IsNullOrEmpty(country.SelectedValue) ? null : country.SelectedValue}
                };
                
                // Serialize to JSON
                var serializer = new JavaScriptSerializer();
                var json = serializer.Serialize(registerData);
                
                // Call backend API
                var apiUrl = ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "http://localhost:8080/ecommerce-backend/api";
                var url = apiUrl + "/users/register";
                
                using (var client = new WebClient())
                {
                    client.Headers.Add("Content-Type", "application/json");
                    client.Headers.Add("User-Agent", "ECommerce-ASP.NET/1.0");
                    
                    var response = client.UploadString(url, "POST", json);
                    var result = serializer.Deserialize<dynamic>(response);
                    
                    // Success
                    ShowSuccess($"Account created successfully! Welcome {result["firstName"]}! <a href='LoginSimple.aspx'>Click here to login</a>");
                    ClearForm();
                }
            }
            catch (WebException ex)
            {
                var response = ex.Response as HttpWebResponse;
                if (response != null)
                {
                    using (var reader = new StreamReader(response.GetResponseStream()))
                    {
                        var errorContent = reader.ReadToEnd();
                        try
                        {
                            var serializer = new JavaScriptSerializer();
                            var errorObj = serializer.Deserialize<dynamic>(errorContent);
                            ShowError("Registration failed: " + errorObj["error"]);
                        }
                        catch
                        {
                            ShowError("Registration failed: " + response.StatusDescription);
                        }
                    }
                }
                else
                {
                    ShowError("Registration failed: Unable to connect to backend API. Please ensure the Java backend is running on port 8080.");
                }
            }
            catch (Exception ex)
            {
                ShowError("Registration failed: " + ex.Message);
            }
        }
        
        private void ShowError(string message)
        {
            litResult.Text = $"<div class='alert alert-danger'><strong>Error:</strong> {message}</div>";
            pnlResult.Visible = true;
        }
        
        private void ShowSuccess(string message)
        {
            litResult.Text = $"<div class='alert alert-success'><strong>Success:</strong> {message}</div>";
            pnlResult.Visible = true;
        }
        
        private void ClearForm()
        {
            firstName.Text = "";
            lastName.Text = "";
            username.Text = "";
            email.Text = "";
            password.Text = "";
            confirmPassword.Text = "";
            phone.Text = "";
            address.Text = "";
            city.Text = "";
            state.Text = "";
            zipCode.Text = "";
            country.SelectedIndex = 0;
        }
    </script>
</body>
</html>
