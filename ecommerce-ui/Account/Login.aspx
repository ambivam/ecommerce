<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Account_Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - E-Commerce Store</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="~/Content/site.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <div class="container">
                <a class="navbar-brand" href="../Default.aspx">
                    <i class="fas fa-shopping-cart"></i> E-Commerce Store
                </a>
                
                <div class="navbar-nav ms-auto">
                    <a class="nav-link" href="../Default.aspx">
                        <i class="fas fa-home"></i> Home
                    </a>
                </div>
            </div>
        </nav>

        <!-- Login Form -->
        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-6 col-lg-4">
                    <div class="card shadow">
                        <div class="card-body p-4">
                            <div class="text-center mb-4">
                                <i class="fas fa-user-circle fa-3x text-primary mb-3"></i>
                                <h3>Sign In</h3>
                                <p class="text-muted">Welcome back! Please sign in to your account.</p>
                            </div>

                            <!-- Error/Success Messages -->
                            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-dismissible fade show">
                                <asp:Literal ID="litMessage" runat="server" />
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </asp:Panel>

                            <!-- Login Form -->
                            <div class="mb-3">
                                <label for="txtUsername" class="form-label">Username or Email</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" 
                                                placeholder="Enter your username or email" Required="true" />
                                </div>
                                <asp:RequiredFieldValidator ID="rfvUsername" runat="server" 
                                                          ControlToValidate="txtUsername" 
                                                          ErrorMessage="Username is required" 
                                                          CssClass="text-danger small" 
                                                          Display="Dynamic" />
                            </div>

                            <div class="mb-3">
                                <label for="txtPassword" class="form-label">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" 
                                                CssClass="form-control" placeholder="Enter your password" Required="true" />
                                    <button type="button" class="btn btn-outline-secondary" onclick="togglePassword()">
                                        <i class="fas fa-eye" id="passwordToggleIcon"></i>
                                    </button>
                                </div>
                                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                                                          ControlToValidate="txtPassword" 
                                                          ErrorMessage="Password is required" 
                                                          CssClass="text-danger small" 
                                                          Display="Dynamic" />
                            </div>

                            <div class="mb-3 form-check">
                                <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="chkRememberMe">
                                    Remember me
                                </label>
                            </div>

                            <div class="d-grid mb-3">
                                <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-primary btn-lg" 
                                           Text="Sign In" OnClick="btnLogin_Click" />
                            </div>

                            <div class="text-center">
                                <a href="ForgotPassword.aspx" class="text-decoration-none">Forgot your password?</a>
                            </div>

                            <hr class="my-4" />

                            <div class="text-center">
                                <p class="mb-0">Don't have an account?</p>
                                <a href="Register.aspx" class="btn btn-outline-primary">Create Account</a>
                            </div>
                        </div>
                    </div>

                    <!-- Demo Credentials -->
                    <div class="card mt-3">
                        <div class="card-body">
                            <h6 class="card-title">Demo Credentials</h6>
                            <small class="text-muted">
                                <strong>Admin:</strong> admin / admin123<br />
                                <strong>User:</strong> johndoe / user123
                            </small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-light py-3 mt-auto">
            <div class="container text-center">
                <p class="mb-0">&copy; 2024 E-Commerce Store. All rights reserved.</p>
            </div>
        </footer>
    </form>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script type="text/javascript">
        function togglePassword() {
            var passwordField = document.getElementById('<%= txtPassword.ClientID %>');
            var toggleIcon = document.getElementById('passwordToggleIcon');
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                toggleIcon.className = 'fas fa-eye-slash';
            } else {
                passwordField.type = 'password';
                toggleIcon.className = 'fas fa-eye';
            }
        }

        // Auto-focus on username field
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('<%= txtUsername.ClientID %>').focus();
        });

        // Handle Enter key press
        document.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                document.getElementById('<%= btnLogin.ClientID %>').click();
            }
        });
    </script>
</body>
</html>
