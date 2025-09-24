using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Account_Login : System.Web.UI.Page
{
    private ApiService apiService;

    protected void Page_Load(object sender, EventArgs e)
    {
        apiService = new ApiService();
        
        if (!IsPostBack)
        {
            // Check if user is already logged in
            var token = ApiService.GetAuthToken();
            if (!string.IsNullOrEmpty(token))
            {
                // Redirect to return URL or default page
                string returnUrl = Request.QueryString["ReturnUrl"];
                if (!string.IsNullOrEmpty(returnUrl))
                {
                    Response.Redirect(returnUrl);
                }
                else
                {
                    Response.Redirect("~/Default.aspx");
                }
            }

            // Check for logout message
            if (Request.QueryString["logout"] == "true")
            {
                ShowMessage("You have been successfully logged out.", "success");
            }

            // Check for registration success message
            if (Request.QueryString["registered"] == "true")
            {
                ShowMessage("Registration successful! Please sign in with your credentials.", "success");
            }
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        try
        {
            // Disable the login button to prevent double-clicking
            btnLogin.Enabled = false;
            btnLogin.Text = "Signing In...";

            // Create login request
            var loginRequest = new LoginRequest
            {
                Username = txtUsername.Text.Trim(),
                Password = txtPassword.Text
            };

            // Call the API
            var loginResponse = apiService.Post<LoginResponse>("users/login", loginRequest);

            if (loginResponse != null && !string.IsNullOrEmpty(loginResponse.Token))
            {
                // Store authentication token
                ApiService.SetAuthToken(loginResponse.Token);

                // Store user information in session
                Session["UserInfo"] = loginResponse.User;
                Session["IsAuthenticated"] = true;

                // Set authentication cookie if "Remember Me" is checked
                if (chkRememberMe.Checked)
                {
                    var authCookie = new HttpCookie("AuthToken", loginResponse.Token)
                    {
                        Expires = DateTime.Now.AddDays(30),
                        HttpOnly = true,
                        Secure = Request.IsSecureConnection
                    };
                    Response.Cookies.Add(authCookie);
                }

                // Redirect to return URL or default page
                string returnUrl = Request.QueryString["ReturnUrl"];
                if (!string.IsNullOrEmpty(returnUrl) && IsLocalUrl(returnUrl))
                {
                    Response.Redirect(returnUrl);
                }
                else
                {
                    // Redirect based on user role
                    if (loginResponse.User.IsAdmin)
                    {
                        Response.Redirect("~/Admin/Dashboard.aspx");
                    }
                    else
                    {
                        Response.Redirect("~/Default.aspx");
                    }
                }
            }
            else
            {
                ShowMessage("Invalid username or password. Please try again.", "danger");
            }
        }
        catch (HttpException httpEx)
        {
            if (httpEx.GetHttpCode() == 401)
            {
                ShowMessage("Invalid username or password. Please try again.", "danger");
            }
            else
            {
                ShowMessage("Login failed. Please try again later.", "danger");
            }
            System.Diagnostics.Debug.WriteLine("HTTP Error during login: " + httpEx.Message);
        }
        catch (TimeoutException)
        {
            ShowMessage("Login request timed out. Please check your connection and try again.", "warning");
        }
        catch (Exception ex)
        {
            ShowMessage("An error occurred during login. Please try again.", "danger");
            System.Diagnostics.Debug.WriteLine("Error during login: " + ex.Message);
        }
        finally
        {
            // Re-enable the login button
            btnLogin.Enabled = true;
            btnLogin.Text = "Sign In";
        }
    }

    private void ShowMessage(string message, string type)
    {
        litMessage.Text = message;
        pnlMessage.CssClass = "alert alert-" + type + " alert-dismissible fade show";
        pnlMessage.Visible = true;
    }

    private bool IsLocalUrl(string url)
    {
        if (string.IsNullOrEmpty(url))
            return false;

        // Check if the URL is relative
        if (url.StartsWith("/") && !url.StartsWith("//"))
            return true;

        // Check if the URL is relative with query string or fragment
        if (url.StartsWith("~/"))
            return true;

        return false;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Set focus to the first empty field
        if (string.IsNullOrEmpty(txtUsername.Text))
        {
            txtUsername.Focus();
        }
        else if (string.IsNullOrEmpty(txtPassword.Text))
        {
            txtPassword.Focus();
        }
    }
}
