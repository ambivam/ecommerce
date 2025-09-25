<%@ Page Language="C#" %>

<!DOCTYPE html>
<html>
<head>
    <title>Session Debug - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <div class="container mt-5">
        <h2>Session Debug Information</h2>
        
        <div class="card">
            <div class="card-body">
                <h5>Session Status</h5>
                <p><strong>Session ID:</strong> <%= Session.SessionID %></p>
                <p><strong>Session Timeout:</strong> <%= Session.Timeout %> minutes</p>
                <p><strong>Is New Session:</strong> <%= Session.IsNewSession %></p>
                
                <h5 class="mt-4">Session Contents</h5>
                <%
                if (Session.Count > 0)
                {
                    Response.Write("<ul>");
                    foreach (string key in Session.Keys)
                    {
                        Response.Write(string.Format("<li><strong>{0}:</strong> {1}</li>", key, Session[key]));
                    }
                    Response.Write("</ul>");
                }
                else
                {
                    Response.Write("<p class='text-warning'>No session data found</p>");
                }
                %>
                
                <h5 class="mt-4">Specific Session Values</h5>
                <p><strong>AuthToken:</strong> <%= Session["AuthToken"] != null ? "Present" : "Not Found" %></p>
                <p><strong>UserInfo:</strong> <%= Session["UserInfo"] != null ? "Present" : "Not Found" %></p>
                
                <% if (Session["UserInfo"] != null) { %>
                    <p><strong>UserInfo Content:</strong> <%= Session["UserInfo"].ToString() %></p>
                <% } %>
                
                <div class="mt-4">
                    <a href="LoginWorking.aspx" class="btn btn-primary">Go to Login</a>
                    <a href="UserDashboardSimple.aspx" class="btn btn-secondary">Go to Dashboard</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
