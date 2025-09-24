<%@ Application Language="C#" %>

<script runat="server">

    void Application_Start(object sender, EventArgs e) 
    {
        // Code that runs on application startup
        System.Diagnostics.Debug.WriteLine("E-Commerce Application Started");
        
        // Initialize application-level variables
        Application["AppName"] = "E-Commerce Application";
        Application["StartTime"] = DateTime.Now;
        Application["Version"] = "1.0.0";
        
        // Register routes if using routing
        RegisterRoutes();
    }
    
    void Application_End(object sender, EventArgs e) 
    {
        // Code that runs on application shutdown
        System.Diagnostics.Debug.WriteLine("E-Commerce Application Ended");
    }
        
    void Application_Error(object sender, EventArgs e) 
    {
        // Code that runs when an unhandled error occurs
        Exception ex = Server.GetLastError();
        
        // Log the error
        System.Diagnostics.Debug.WriteLine("Application Error: " + ex.Message);
        
        // Clear the error
        Server.ClearError();
        
        // Redirect to error page
        Response.Redirect("~/Error/Default.aspx");
    }

    void Session_Start(object sender, EventArgs e) 
    {
        // Code that runs when a new session is started
        Session["SessionStartTime"] = DateTime.Now;
        Session["CartItems"] = new List<object>(); // Initialize empty cart
    }

    void Session_End(object sender, EventArgs e) 
    {
        // Code that runs when a session ends
        // Note: The Session_End event is raised only when the sessionstate mode
        // is set to InProc in the Web.config file. If session mode is set to StateServer 
        // or SQLServer, the event is not raised.
    }
    
    private void RegisterRoutes()
    {
        // Register custom routes here if needed
        // Example:
        // RouteTable.Routes.MapPageRoute("ProductDetails", "product/{id}", "~/ProductDetails.aspx");
    }
       
</script>
