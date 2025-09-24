using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.IO;

/// <summary>
/// Service class for making HTTP requests to the Java backend API
/// </summary>
public class ApiService
{
    private readonly string baseUrl;
    private readonly int timeout;

    public ApiService()
    {
        baseUrl = ConfigurationManager.AppSettings["ApiBaseUrl"] ?? "http://localhost:8080/ecommerce-backend/api";
        timeout = int.Parse(ConfigurationManager.AppSettings["ApiTimeout"] ?? "30000");
    }

    /// <summary>
    /// Make GET request to API
    /// </summary>
    public T Get<T>(string endpoint)
    {
        try
        {
            var url = baseUrl + "/" + endpoint.TrimStart('/');
            using (var client = new WebClient())
            {
                client.Headers.Add("User-Agent", "ECommerce-ASP.NET/1.0");
                client.Headers.Add("Accept", "application/json");
                
                var content = client.DownloadString(url);
                var serializer = new JavaScriptSerializer();
                return serializer.Deserialize<T>(content);
            }
        }
        catch (WebException ex)
        {
            var response = ex.Response as HttpWebResponse;
            if (response != null)
            {
                throw new HttpException((int)response.StatusCode, "API request failed: " + response.StatusDescription);
            }
            throw new HttpException(500, "Network error: " + ex.Message);
        }
    }

    /// <summary>
    /// Make POST request to API
    /// </summary>
    public T Post<T>(string endpoint, object data)
    {
        try
        {
            var url = baseUrl + "/" + endpoint.TrimStart('/');
            var serializer = new JavaScriptSerializer();
            var json = serializer.Serialize(data);
            
            using (var client = new WebClient())
            {
                client.Headers.Add("User-Agent", "ECommerce-ASP.NET/1.0");
                client.Headers.Add("Content-Type", "application/json");
                
                var responseContent = client.UploadString(url, json);
                var deserializer = new JavaScriptSerializer();
                return deserializer.Deserialize<T>(responseContent);
            }
        }
        catch (WebException ex)
        {
            var response = ex.Response as HttpWebResponse;
            if (response != null)
            {
                using (var reader = new StreamReader(response.GetResponseStream()))
                {
                    var errorContent = reader.ReadToEnd();
                    throw new HttpException((int)response.StatusCode, "API request failed: " + errorContent);
                }
            }
            throw new HttpException(500, "Network error: " + ex.Message);
        }
    }

    /// <summary>
    /// Make authenticated GET request
    /// </summary>
    public T GetAuthenticated<T>(string endpoint, string token)
    {
        try
        {
            var url = baseUrl + "/" + endpoint.TrimStart('/');
            using (var client = new WebClient())
            {
                client.Headers.Add("User-Agent", "ECommerce-ASP.NET/1.0");
                client.Headers.Add("Accept", "application/json");
                client.Headers.Add("Authorization", "Bearer " + token);
                
                var content = client.DownloadString(url);
                var serializer = new JavaScriptSerializer();
                return serializer.Deserialize<T>(content);
            }
        }
        catch (WebException ex)
        {
            var response = ex.Response as HttpWebResponse;
            if (response != null)
            {
                throw new HttpException((int)response.StatusCode, "API request failed: " + response.StatusDescription);
            }
            throw new HttpException(500, "Network error: " + ex.Message);
        }
    }

    /// <summary>
    /// Make authenticated POST request
    /// </summary>
    public T PostAuthenticated<T>(string endpoint, object data, string token)
    {
        try
        {
            var url = baseUrl + "/" + endpoint.TrimStart('/');
            var serializer = new JavaScriptSerializer();
            var json = serializer.Serialize(data);
            
            using (var client = new WebClient())
            {
                client.Headers.Add("User-Agent", "ECommerce-ASP.NET/1.0");
                client.Headers.Add("Content-Type", "application/json");
                client.Headers.Add("Authorization", "Bearer " + token);
                
                var responseContent = client.UploadString(url, json);
                var deserializer = new JavaScriptSerializer();
                return deserializer.Deserialize<T>(responseContent);
            }
        }
        catch (WebException ex)
        {
            var response = ex.Response as HttpWebResponse;
            if (response != null)
            {
                using (var reader = new StreamReader(response.GetResponseStream()))
                {
                    var errorContent = reader.ReadToEnd();
                    throw new HttpException((int)response.StatusCode, "API request failed: " + errorContent);
                }
            }
            throw new HttpException(500, "Network error: " + ex.Message);
        }
    }

    /// <summary>
    /// Get JWT token from session or cookie
    /// </summary>
    public static string GetAuthToken()
    {
        var tokenKey = ConfigurationManager.AppSettings["JwtTokenKey"] ?? "ecommerce_jwt_token";
        
        // Try to get from session first
        if (HttpContext.Current.Session[tokenKey] != null)
        {
            return HttpContext.Current.Session[tokenKey].ToString();
        }
        
        // Try to get from cookie
        var cookie = HttpContext.Current.Request.Cookies[tokenKey];
        if (cookie != null)
        {
            return cookie.Value;
        }
        
        return null;
    }

    /// <summary>
    /// Store JWT token in session and cookie
    /// </summary>
    public static void SetAuthToken(string token)
    {
        var tokenKey = ConfigurationManager.AppSettings["JwtTokenKey"] ?? "ecommerce_jwt_token";
        
        // Store in session
        HttpContext.Current.Session[tokenKey] = token;
        
        // Store in cookie (expires in 24 hours)
        var cookie = new HttpCookie(tokenKey, token)
        {
            Expires = DateTime.Now.AddHours(24),
            HttpOnly = true,
            Secure = HttpContext.Current.Request.IsSecureConnection
        };
        HttpContext.Current.Response.Cookies.Add(cookie);
    }

    /// <summary>
    /// Clear authentication token
    /// </summary>
    public static void ClearAuthToken()
    {
        var tokenKey = ConfigurationManager.AppSettings["JwtTokenKey"] ?? "ecommerce_jwt_token";
        
        // Clear from session
        HttpContext.Current.Session.Remove(tokenKey);
        
        // Clear cookie
        var cookie = new HttpCookie(tokenKey, "")
        {
            Expires = DateTime.Now.AddDays(-1)
        };
        HttpContext.Current.Response.Cookies.Add(cookie);
    }
}
