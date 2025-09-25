<%@ Page Language="C#" %>

<%
// Clear session
Session.Clear();
Session.Abandon();

// Redirect to homepage
Response.Redirect("/ecommerce-ui/");
%>
