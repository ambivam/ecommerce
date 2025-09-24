using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Default : System.Web.UI.Page
{
    private ApiService apiService;

    protected void Page_Load(object sender, EventArgs e)
    {
        apiService = new ApiService();
        
        if (!IsPostBack)
        {
            try
            {
                LoadUserInfo();
                LoadFeaturedProducts();
                LoadCategories();
            }
            catch (Exception ex)
            {
                // Log error but don't crash the page
                System.Diagnostics.Debug.WriteLine("Page load error: " + ex.Message);
                // Show page without API data
                ShowOfflineMode();
            }
        }
    }
    
    private void ShowOfflineMode()
    {
        // Show page in offline mode
        userMenu.Visible = false;
        loginMenu.Visible = true;
        lblNoProducts.Text = "Welcome to our E-Commerce Store! The backend service is currently unavailable.";
        lblNoProducts.Visible = true;
        rptFeaturedProducts.DataSource = null;
        rptFeaturedProducts.DataBind();
        rptCategories.DataSource = null;
        rptCategories.DataBind();
    }

    private void LoadUserInfo()
    {
        try
        {
            // For now, just show login menu to avoid session issues
            userMenu.Visible = false;
            loginMenu.Visible = true;
            
            // Commented out token logic to prevent redirect issues
            /*
            var token = ApiService.GetAuthToken();
            if (!string.IsNullOrEmpty(token))
            {
                // User is logged in
                var userInfo = Session["UserInfo"] as User;
                if (userInfo != null)
                {
                    litUserName.Text = userInfo.FirstName;
                    userMenu.Visible = true;
                    loginMenu.Visible = false;
                }
                else
                {
                    // Token exists but no user info in session
                    ApiService.ClearAuthToken();
                    userMenu.Visible = false;
                    loginMenu.Visible = true;
                }
            }
            else
            {
                // User is not logged in
                userMenu.Visible = false;
                loginMenu.Visible = true;
            }
            */
        }
        catch (Exception ex)
        {
            // Log error and show guest mode
            System.Diagnostics.Debug.WriteLine("Error loading user info: " + ex.Message);
            userMenu.Visible = false;
            loginMenu.Visible = true;
        }
    }

    private void LoadFeaturedProducts()
    {
        try
        {
            var products = apiService.Get<List<Product>>("products");
            
            if (products != null && products.Any())
            {
                // Take first 8 products as featured
                var featuredProducts = products.Take(8).ToList();
                rptFeaturedProducts.DataSource = featuredProducts;
                rptFeaturedProducts.DataBind();
                lblNoProducts.Visible = false;
            }
            else
            {
                rptFeaturedProducts.DataSource = null;
                rptFeaturedProducts.DataBind();
                lblNoProducts.Visible = true;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading featured products: " + ex.Message);
            // Don't show error to user, just show empty state
            rptFeaturedProducts.DataSource = null;
            rptFeaturedProducts.DataBind();
            lblNoProducts.Text = "Products will appear here once the backend service is running.";
            lblNoProducts.Visible = true;
        }
    }

    private void LoadCategories()
    {
        try
        {
            var categories = apiService.Get<List<Category>>("categories");
            
            if (categories != null && categories.Any())
            {
                rptCategories.DataSource = categories;
                rptCategories.DataBind();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading categories: " + ex.Message);
            // Categories are optional for home page, so we don't show error to user
        }
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        try
        {
            // Clear authentication token
            ApiService.ClearAuthToken();
            
            // Clear session
            Session.Clear();
            Session.Abandon();
            
            // Redirect to home page
            Response.Redirect("Default.aspx");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error during logout: " + ex.Message);
            // Still redirect even if there's an error
            Response.Redirect("Default.aspx");
        }
    }

    [WebMethod]
    public static object AddToCart(long productId, int quantity)
    {
        try
        {
            // Get current cart from session
            var cart = HttpContext.Current.Session["ShoppingCart"] as ShoppingCart;
            if (cart == null)
            {
                cart = new ShoppingCart();
                HttpContext.Current.Session["ShoppingCart"] = cart;
            }

            // Get product details from API
            var apiService = new ApiService();
            var product = apiService.Get<Product>("products/" + productId);

            if (product == null)
            {
                return new { success = false, message = "Product not found" };
            }

            if (!product.IsAvailable)
            {
                return new { success = false, message = "Product is not available" };
            }

            if (product.StockQuantity < quantity)
            {
                return new { success = false, message = "Only " + product.StockQuantity + " items available in stock" };
            }

            // Add to cart
            cart.AddItem(product, quantity);

            return new { success = true, message = "Product added to cart successfully" };
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error adding to cart: " + ex.Message);
            return new { success = false, message = "Failed to add product to cart" };
        }
    }

    [WebMethod]
    public static object GetCartCount()
    {
        try
        {
            var cart = HttpContext.Current.Session["ShoppingCart"] as ShoppingCart;
            var count = cart?.TotalItems ?? 0;
            return new { success = true, count = count };
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error getting cart count: " + ex.Message);
            return new { success = false, count = 0 };
        }
    }
}
