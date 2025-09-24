using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Products : System.Web.UI.Page
{
    private ApiService apiService;
    private int currentPage = 1;
    private int pageSize = 12;
    private string searchTerm = "";
    private long? categoryId = null;
    private decimal? minPrice = null;
    private decimal? maxPrice = null;
    private string sortBy = "name";

    protected void Page_Load(object sender, EventArgs e)
    {
        apiService = new ApiService();
        
        if (!IsPostBack)
        {
            LoadUserInfo();
            LoadCategories();
            LoadQueryParameters();
            LoadProducts();
        }
    }

    private void LoadUserInfo()
    {
        try
        {
            var token = ApiService.GetAuthToken();
            if (!string.IsNullOrEmpty(token))
            {
                var userInfo = Session["UserInfo"] as User;
                if (userInfo != null)
                {
                    litUserName.Text = userInfo.FirstName;
                    userMenu.Visible = true;
                    loginMenu.Visible = false;
                }
                else
                {
                    ApiService.ClearAuthToken();
                    userMenu.Visible = false;
                    loginMenu.Visible = true;
                }
            }
            else
            {
                userMenu.Visible = false;
                loginMenu.Visible = true;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading user info: " + ex.Message);
            userMenu.Visible = false;
            loginMenu.Visible = true;
        }
    }

    private void LoadCategories()
    {
        try
        {
            var categories = apiService.Get<List<Category>>("categories");
            
            if (categories != null && categories.Any())
            {
                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new ListItem("All Categories", ""));
                
                foreach (var category in categories)
                {
                    ddlCategory.Items.Add(new ListItem(category.Name, category.Id.ToString()));
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading categories: " + ex.Message);
        }
    }

    private void LoadQueryParameters()
    {
        // Get parameters from query string
        if (Request.QueryString["search"] != null)
        {
            searchTerm = Request.QueryString["search"];
            txtSearch.Text = searchTerm;
        }

        if (Request.QueryString["category"] != null && long.TryParse(Request.QueryString["category"], out long catId))
        {
            categoryId = catId;
            ddlCategory.SelectedValue = catId.ToString();
        }

        if (Request.QueryString["page"] != null && int.TryParse(Request.QueryString["page"], out int page))
        {
            currentPage = Math.Max(1, page);
        }

        if (Request.QueryString["pageSize"] != null && int.TryParse(Request.QueryString["pageSize"], out int size))
        {
            pageSize = size;
            ddlPageSize.SelectedValue = size.ToString();
        }

        if (Request.QueryString["sort"] != null)
        {
            sortBy = Request.QueryString["sort"];
            ddlSortBy.SelectedValue = sortBy;
        }

        if (Request.QueryString["minPrice"] != null && decimal.TryParse(Request.QueryString["minPrice"], out decimal min))
        {
            minPrice = min;
            txtMinPrice.Text = min.ToString();
        }

        if (Request.QueryString["maxPrice"] != null && decimal.TryParse(Request.QueryString["maxPrice"], out decimal max))
        {
            maxPrice = max;
            txtMaxPrice.Text = max.ToString();
        }
    }

    private void LoadProducts()
    {
        try
        {
            string endpoint = "products";
            var queryParams = new List<string>();

            // Add search parameter
            if (!string.IsNullOrEmpty(searchTerm))
            {
                queryParams.Add("q=" + HttpUtility.UrlEncode(searchTerm));
                endpoint = "products/search";
            }

            // Add category filter
            if (categoryId.HasValue)
            {
                if (endpoint == "products")
                {
                    endpoint = "products/category/" + categoryId.Value;
                }
            }

            // Build query string
            if (queryParams.Any())
            {
                endpoint += "?" + string.Join("&", queryParams);
            }

            var products = apiService.Get<List<Product>>(endpoint);

            if (products != null)
            {
                // Apply client-side filtering for price range
                if (minPrice.HasValue || maxPrice.HasValue)
                {
                    products = products.Where(p => 
                        (!minPrice.HasValue || p.Price >= minPrice.Value) &&
                        (!maxPrice.HasValue || p.Price <= maxPrice.Value)
                    ).ToList();
                }

                // Apply sorting
                products = ApplySorting(products);

                // Update result count
                lblResultCount.Text = "Showing " + products.Count + " products";

                // Apply pagination
                var pagedProducts = ApplyPagination(products);

                // Bind to repeater
                rptProducts.DataSource = pagedProducts;
                rptProducts.DataBind();

                // Show/hide no products panel
                pnlNoProducts.Visible = !products.Any();

                // Generate pagination
                GeneratePagination(products.Count);
            }
            else
            {
                rptProducts.DataSource = null;
                rptProducts.DataBind();
                pnlNoProducts.Visible = true;
                lblResultCount.Text = "No products found";
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading products: " + ex.Message);
            pnlNoProducts.Visible = true;
            lblResultCount.Text = "Error loading products";
        }
    }

    private List<Product> ApplySorting(List<Product> products)
    {
        switch (sortBy.ToLower())
        {
            case "name":
                return products.OrderBy(p => p.Name).ToList();
            case "name_desc":
                return products.OrderByDescending(p => p.Name).ToList();
            case "price":
                return products.OrderBy(p => p.Price).ToList();
            case "price_desc":
                return products.OrderByDescending(p => p.Price).ToList();
            case "newest":
                return products.OrderByDescending(p => p.CreatedAt).ToList();
            default:
                return products.OrderBy(p => p.Name).ToList();
        }
    }

    private List<Product> ApplyPagination(List<Product> products)
    {
        int skip = (currentPage - 1) * pageSize;
        return products.Skip(skip).Take(pageSize).ToList();
    }

    private void GeneratePagination(int totalCount)
    {
        int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
        var paginationItems = new List<object>();

        // Previous button
        paginationItems.Add(new
        {
            Text = "Previous",
            PageNumber = Math.Max(1, currentPage - 1),
            IsActive = false,
            IsDisabled = currentPage <= 1
        });

        // Page numbers
        int startPage = Math.Max(1, currentPage - 2);
        int endPage = Math.Min(totalPages, currentPage + 2);

        for (int i = startPage; i <= endPage; i++)
        {
            paginationItems.Add(new
            {
                Text = i.ToString(),
                PageNumber = i,
                IsActive = i == currentPage,
                IsDisabled = false
            });
        }

        // Next button
        paginationItems.Add(new
        {
            Text = "Next",
            PageNumber = Math.Min(totalPages, currentPage + 1),
            IsActive = false,
            IsDisabled = currentPage >= totalPages
        });

        rptPagination.DataSource = paginationItems;
        rptPagination.DataBind();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        searchTerm = txtSearch.Text.Trim();
        currentPage = 1;
        LoadProducts();
    }

    protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (long.TryParse(ddlCategory.SelectedValue, out long catId))
        {
            categoryId = catId;
        }
        else
        {
            categoryId = null;
        }
        currentPage = 1;
        LoadProducts();
    }

    protected void ddlSortBy_SelectedIndexChanged(object sender, EventArgs e)
    {
        sortBy = ddlSortBy.SelectedValue;
        LoadProducts();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        pageSize = int.Parse(ddlPageSize.SelectedValue);
        currentPage = 1;
        LoadProducts();
    }

    protected void btnApplyFilters_Click(object sender, EventArgs e)
    {
        // Parse price filters
        if (decimal.TryParse(txtMinPrice.Text, out decimal min))
        {
            minPrice = min;
        }
        else
        {
            minPrice = null;
        }

        if (decimal.TryParse(txtMaxPrice.Text, out decimal max))
        {
            maxPrice = max;
        }
        else
        {
            maxPrice = null;
        }

        currentPage = 1;
        LoadProducts();
    }

    protected void btnClearFilters_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlCategory.SelectedIndex = 0;
        txtMinPrice.Text = "";
        txtMaxPrice.Text = "";
        ddlSortBy.SelectedValue = "name";
        
        searchTerm = "";
        categoryId = null;
        minPrice = null;
        maxPrice = null;
        sortBy = "name";
        currentPage = 1;
        
        LoadProducts();
    }

    protected void btnShowAll_Click(object sender, EventArgs e)
    {
        btnClearFilters_Click(sender, e);
    }

    protected void lnkPage_Click(object sender, EventArgs e)
    {
        var linkButton = (LinkButton)sender;
        if (int.TryParse(linkButton.CommandArgument, out int pageNumber))
        {
            currentPage = pageNumber;
            LoadProducts();
        }
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        try
        {
            ApiService.ClearAuthToken();
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error during logout: " + ex.Message);
            Response.Redirect("Default.aspx");
        }
    }

    [WebMethod]
    public static object AddToCart(long productId, int quantity)
    {
        try
        {
            var cart = HttpContext.Current.Session["ShoppingCart"] as ShoppingCart;
            if (cart == null)
            {
                cart = new ShoppingCart();
                HttpContext.Current.Session["ShoppingCart"] = cart;
            }

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
