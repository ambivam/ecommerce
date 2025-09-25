<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login Test - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <div class="container mt-5">
        <h2>Simple Login Test</h2>
        
        <%
        string message = "";
        if (Request.HttpMethod == "POST")
        {
            // Simulate successful login
            Session["AuthToken"] = "test-token-" + DateTime.Now.Ticks;
            Session["UserInfo"] = "{\"id\":1,\"firstName\":\"" + Request.Form["username"] + "\",\"lastName\":\"User\",\"email\":\"test@example.com\"}";
            
            message = "Login successful! Session data set. <a href='UserDashboardSimple.aspx'>Go to Dashboard</a>";
        }
        %>
        
        <% if (!string.IsNullOrEmpty(message)) { %>
            <div class="alert alert-success"><%= message %></div>
        <% } %>
        
        <form method="post">
            <div class="mb-3">
                <label>Username:</label>
                <input type="text" name="username" class="form-control" value="testuser" required />
            </div>
            <div class="mb-3">
                <label>Password:</label>
                <input type="password" name="password" class="form-control" value="password" required />
            </div>
            <button type="submit" class="btn btn-primary">Test Login</button>
        </form>
        
        <div class="mt-4">
            <a href="SessionDebug.aspx" class="btn btn-info">Check Session</a>
        </div>
    </div>
</body>
</html>
