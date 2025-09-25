<%@ Page Language="C#" %>

<%
// Test setting session data
Session["AuthToken"] = "test-token-123";
Session["UserInfo"] = "{\"id\":1,\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"test@example.com\"}";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Test Session - TechMart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <div class="container mt-5">
        <div class="alert alert-success">
            <h4>Session Data Set Successfully!</h4>
            <p>Test session data has been created.</p>
        </div>
        
        <div class="mt-4">
            <a href="SessionDebug.aspx" class="btn btn-info">Check Session Debug</a>
            <a href="UserDashboardSimple.aspx" class="btn btn-primary">Go to Dashboard</a>
        </div>
    </div>
</body>
</html>
