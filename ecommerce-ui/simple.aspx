<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>Simple Test Page</title>
</head>
<body>
    <h1>ASP.NET is Working!</h1>
    <p>Current time: <%= DateTime.Now.ToString() %></p>
    <p>API Base URL: <%= ConfigurationManager.AppSettings["ApiBaseUrl"] %></p>
    
    <h2>Test API Connection</h2>
    <div id="apiTest">
        <%
        try 
        {
            var apiUrl = ConfigurationManager.AppSettings["ApiBaseUrl"] + "/products";
            using (var client = new System.Net.WebClient())
            {
                client.Headers.Add("Accept", "application/json");
                var response = client.DownloadString(apiUrl);
                Response.Write("<p style='color: green;'>✅ API Connection Successful!</p>");
                Response.Write("<p>First 200 characters of response:</p>");
                Response.Write("<pre>" + Server.HtmlEncode(response.Substring(0, Math.Min(200, response.Length))) + "...</pre>");
            }
        }
        catch (Exception ex)
        {
            Response.Write("<p style='color: red;'>❌ API Connection Failed: " + Server.HtmlEncode(ex.Message) + "</p>");
        }
        %>
    </div>
    
    <p><a href="Default.aspx">Try Default.aspx</a></p>
</body>
</html>
