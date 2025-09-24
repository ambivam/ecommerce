<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Products.aspx.cs" Inherits="Products" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Products - E-Commerce Store</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="~/Content/bootstrap.min.css" rel="stylesheet" />
    <link href="~/Content/site.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true" />
        
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <div class="container">
                <a class="navbar-brand" href="Default.aspx">
                    <i class="fas fa-shopping-cart"></i> E-Commerce Store
                </a>
                
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="Default.aspx">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="Products.aspx">Products</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Categories.aspx">Categories</a>
                        </li>
                    </ul>
                    
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="Cart.aspx">
                                <i class="fas fa-shopping-cart"></i> Cart 
                                <span class="badge bg-warning text-dark" id="cartCount">0</span>
                            </a>
                        </li>
                        <li class="nav-item dropdown" id="userMenu" runat="server" visible="false">
                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user"></i> <asp:Literal ID="litUserName" runat="server" />
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="Account/Profile.aspx">Profile</a></li>
                                <li><a class="dropdown-item" href="Account/Orders.aspx">My Orders</a></li>
                                <li><hr class="dropdown-divider" /></li>
                                <li><asp:LinkButton ID="btnLogout" runat="server" CssClass="dropdown-item" OnClick="btnLogout_Click">Logout</asp:LinkButton></li>
                            </ul>
                        </li>
                        <li class="nav-item" id="loginMenu" runat="server">
                            <a class="nav-link" href="Account/Login.aspx">
                                <i class="fas fa-sign-in-alt"></i> Login
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Page Header -->
        <section class="bg-light py-4">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h1 class="h3 mb-0">Products</h1>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb mb-0">
                                <li class="breadcrumb-item"><a href="Default.aspx">Home</a></li>
                                <li class="breadcrumb-item active">Products</li>
                            </ol>
                        </nav>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <asp:Label ID="lblResultCount" runat="server" CssClass="text-muted" />
                    </div>
                </div>
            </div>
        </section>

        <!-- Main Content -->
        <div class="container py-4">
            <div class="row">
                <!-- Filters Sidebar -->
                <div class="col-lg-3 mb-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">Filters</h5>
                        </div>
                        <div class="card-body">
                            <!-- Search -->
                            <div class="mb-3">
                                <label class="form-label">Search Products</label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search..." />
                                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-outline-secondary" 
                                               Text="Search" OnClick="btnSearch_Click" />
                                </div>
                            </div>

                            <!-- Category Filter -->
                            <div class="mb-3">
                                <label class="form-label">Category</label>
                                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" 
                                                 AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="All Categories" />
                                </asp:DropDownList>
                            </div>

                            <!-- Price Range -->
                            <div class="mb-3">
                                <label class="form-label">Price Range</label>
                                <div class="row">
                                    <div class="col-6">
                                        <asp:TextBox ID="txtMinPrice" runat="server" CssClass="form-control form-control-sm" 
                                                    placeholder="Min" TextMode="Number" />
                                    </div>
                                    <div class="col-6">
                                        <asp:TextBox ID="txtMaxPrice" runat="server" CssClass="form-control form-control-sm" 
                                                    placeholder="Max" TextMode="Number" />
                                    </div>
                                </div>
                            </div>

                            <!-- Sort By -->
                            <div class="mb-3">
                                <label class="form-label">Sort By</label>
                                <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="form-select" 
                                                 AutoPostBack="true" OnSelectedIndexChanged="ddlSortBy_SelectedIndexChanged">
                                    <asp:ListItem Value="name" Text="Name A-Z" />
                                    <asp:ListItem Value="name_desc" Text="Name Z-A" />
                                    <asp:ListItem Value="price" Text="Price Low to High" />
                                    <asp:ListItem Value="price_desc" Text="Price High to Low" />
                                    <asp:ListItem Value="newest" Text="Newest First" />
                                </asp:DropDownList>
                            </div>

                            <!-- Apply Filters Button -->
                            <asp:Button ID="btnApplyFilters" runat="server" CssClass="btn btn-primary w-100" 
                                       Text="Apply Filters" OnClick="btnApplyFilters_Click" />
                            
                            <asp:Button ID="btnClearFilters" runat="server" CssClass="btn btn-outline-secondary w-100 mt-2" 
                                       Text="Clear Filters" OnClick="btnClearFilters_Click" />
                        </div>
                    </div>
                </div>

                <!-- Products Grid -->
                <div class="col-lg-9">
                    <asp:UpdatePanel ID="upProducts" runat="server">
                        <ContentTemplate>
                            <!-- View Toggle -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="btn-group" role="group">
                                    <input type="radio" class="btn-check" name="viewMode" id="gridView" checked />
                                    <label class="btn btn-outline-secondary" for="gridView">
                                        <i class="fas fa-th"></i> Grid
                                    </label>
                                    <input type="radio" class="btn-check" name="viewMode" id="listView" />
                                    <label class="btn btn-outline-secondary" for="listView">
                                        <i class="fas fa-list"></i> List
                                    </label>
                                </div>
                                
                                <div class="d-flex align-items-center">
                                    <label class="me-2">Show:</label>
                                    <asp:DropDownList ID="ddlPageSize" runat="server" CssClass="form-select form-select-sm" 
                                                     AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged">
                                        <asp:ListItem Value="12" Text="12" />
                                        <asp:ListItem Value="24" Text="24" />
                                        <asp:ListItem Value="48" Text="48" />
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <!-- Products Display -->
                            <div class="row" id="productsGrid">
                                <asp:Repeater ID="rptProducts" runat="server">
                                    <ItemTemplate>
                                        <div class="col-lg-4 col-md-6 mb-4">
                                            <div class="card h-100 product-card">
                                                <div class="position-relative">
                                                    <img src='<%# ResolveUrl(Eval("ImageUrl", "~/Images/products/{0}").ToString()) %>' 
                                                         class="card-img-top" alt='<%# Eval("Name") %>' style="height: 250px; object-fit: cover;" />
                                                    <%# (bool)Eval("IsAvailable") ? "" : "<div class=\"position-absolute top-0 start-0 bg-danger text-white px-2 py-1 m-2 rounded\">Out of Stock</div>" %>
                                                </div>
                                                <div class="card-body d-flex flex-column">
                                                    <h5 class="card-title"><%# Eval("Name") %></h5>
                                                    <p class="card-text flex-grow-1"><%# Eval("Description") %></p>
                                                    <div class="mt-auto">
                                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                                            <span class="h5 text-primary mb-0"><%# Eval("Price", "{0:C}") %></span>
                                                            <small class="text-muted">Stock: <%# Eval("StockQuantity") %></small>
                                                        </div>
                                                        <div class="btn-group w-100">
                                                            <a href='ProductDetails.aspx?id=<%# Eval("Id") %>' class="btn btn-outline-primary">View Details</a>
                                                            <button type="button" class="btn btn-primary" onclick="addToCart(<%# Eval("Id") %>)" 
                                                                    <%# (bool)Eval("IsAvailable") ? "" : "disabled" %>>
                                                                <i class="fas fa-cart-plus"></i>
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <!-- No Products Message -->
                            <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="text-center py-5">
                                <i class="fas fa-search fa-3x text-muted mb-3"></i>
                                <h4>No Products Found</h4>
                                <p class="text-muted">Try adjusting your search criteria or browse all products.</p>
                                <asp:Button ID="btnShowAll" runat="server" CssClass="btn btn-primary" 
                                           Text="Show All Products" OnClick="btnShowAll_Click" />
                            </asp:Panel>

                            <!-- Pagination -->
                            <nav aria-label="Products pagination" class="mt-4">
                                <ul class="pagination justify-content-center">
                                    <asp:Repeater ID="rptPagination" runat="server">
                                        <ItemTemplate>
                                            <li class="page-item <%# (bool)Eval("IsActive") ? "active" : "" %> <%# (bool)Eval("IsDisabled") ? "disabled" : "" %>">
                                                <asp:LinkButton ID="lnkPage" runat="server" CssClass="page-link" 
                                                               CommandArgument='<%# Eval("PageNumber") %>' 
                                                               OnClick="lnkPage_Click" Text='<%# Eval("Text") %>' />
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ul>
                            </nav>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="ddlCategory" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlSortBy" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="ddlPageSize" EventName="SelectedIndexChanged" />
                            <asp:AsyncPostBackTrigger ControlID="btnApplyFilters" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnClearFilters" EventName="Click" />
                            <asp:AsyncPostBackTrigger ControlID="btnShowAll" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-light py-4 mt-5">
            <div class="container">
                <div class="row">
                    <div class="col-md-6">
                        <h5>E-Commerce Store</h5>
                        <p>Your trusted online shopping destination.</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <p>&copy; 2024 E-Commerce Store. All rights reserved.</p>
                    </div>
                </div>
            </div>
        </footer>
    </form>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="~/Scripts/site.js"></script>
    
    <script type="text/javascript">
        function addToCart(productId) {
            PageMethods.AddToCart(productId, 1, onAddToCartSuccess, onAddToCartError);
        }
        
        function onAddToCartSuccess(result) {
            if (result.success) {
                updateCartCount();
                showNotification('Product added to cart!', 'success');
            } else {
                showNotification(result.message || 'Failed to add product to cart', 'error');
            }
        }
        
        function onAddToCartError(error) {
            showNotification('Error adding product to cart', 'error');
        }
        
        function updateCartCount() {
            PageMethods.GetCartCount(function(result) {
                if (result.success) {
                    document.getElementById('cartCount').textContent = result.count;
                }
            });
        }
        
        function showNotification(message, type) {
            var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
            var notification = '<div class="alert ' + alertClass + ' alert-dismissible fade show position-fixed" style="top: 20px; right: 20px; z-index: 9999;">' +
                              '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                              message + '</div>';
            document.body.insertAdjacentHTML('beforeend', notification);
            
            setTimeout(function() {
                var alerts = document.querySelectorAll('.alert');
                if (alerts.length > 0) {
                    alerts[alerts.length - 1].remove();
                }
            }, 3000);
        }
        
        document.addEventListener('DOMContentLoaded', function() {
            updateCartCount();
        });
    </script>
</body>
</html>
