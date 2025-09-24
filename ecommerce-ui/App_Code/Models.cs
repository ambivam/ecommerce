using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

/// <summary>
/// Data models for the E-Commerce application
/// These models mirror the Java backend entities
/// </summary>

public class User
{
    public long Id { get; set; }
    
    [Required]
    [StringLength(50)]
    public string Username { get; set; }
    
    [Required]
    [EmailAddress]
    public string Email { get; set; }
    
    [Required]
    public string FirstName { get; set; }
    
    [Required]
    public string LastName { get; set; }
    
    public string Phone { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    public string ZipCode { get; set; }
    public string Country { get; set; }
    public bool IsActive { get; set; }
    public bool IsAdmin { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public string FullName 
    { 
        get { return FirstName + " " + LastName; } 
    }
    
    public string FullAddress 
    { 
        get { return Address + ", " + City + ", " + State + " " + ZipCode + ", " + Country; } 
    }
}

public class Product
{
    public long Id { get; set; }
    
    [Required]
    public string Name { get; set; }
    
    public string Description { get; set; }
    
    [Required]
    [Range(0, double.MaxValue)]
    public decimal Price { get; set; }
    
    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }
    
    public long? CategoryId { get; set; }
    public string CategoryName { get; set; }
    public string ImageUrl { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public bool IsInStock 
    { 
        get { return StockQuantity > 0; } 
    }
    
    public bool IsAvailable 
    { 
        get { return IsActive && IsInStock; } 
    }
    
    public string FormattedPrice 
    { 
        get { return Price.ToString("C"); } 
    }
}

public class Category
{
    public long Id { get; set; }
    
    [Required]
    public string Name { get; set; }
    
    public string Description { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class Order
{
    public long Id { get; set; }
    public long UserId { get; set; }
    public string OrderNumber { get; set; }
    public string Status { get; set; }
    public decimal TotalAmount { get; set; }
    public string ShippingAddress { get; set; }
    public string BillingAddress { get; set; }
    public DateTime OrderDate { get; set; }
    public DateTime? ShippedDate { get; set; }
    public DateTime? DeliveredDate { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public User User { get; set; }
    public List<OrderItem> OrderItems { get; set; }
    public Payment Payment { get; set; }

    public string FormattedTotal 
    { 
        get { return TotalAmount.ToString("C"); } 
    }
    
    public bool CanBeCancelled 
    { 
        get { return Status == "PENDING" || Status == "CONFIRMED"; } 
    }
}

public class OrderItem
{
    public long Id { get; set; }
    public long OrderId { get; set; }
    public long ProductId { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; set; }
    public DateTime CreatedAt { get; set; }

    public Product Product { get; set; }

    public string FormattedUnitPrice 
    { 
        get { return UnitPrice.ToString("C"); } 
    }
    
    public string FormattedTotalPrice 
    { 
        get { return TotalPrice.ToString("C"); } 
    }
}

public class Payment
{
    public long Id { get; set; }
    public long OrderId { get; set; }
    public string PaymentMethod { get; set; }
    public string PaymentStatus { get; set; }
    public decimal Amount { get; set; }
    public string TransactionId { get; set; }
    public DateTime PaymentDate { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public string FormattedAmount 
    { 
        get { return Amount.ToString("C"); } 
    }
    
    public bool IsCompleted 
    { 
        get { return PaymentStatus == "COMPLETED"; } 
    }
}

// DTOs for API communication
public class LoginRequest
{
    [Required]
    public string Username { get; set; }
    
    [Required]
    public string Password { get; set; }
}

public class LoginResponse
{
    public string Token { get; set; }
    public string TokenType { get; set; }
    public long ExpiresIn { get; set; }
    public User User { get; set; }
}

public class RegisterRequest
{
    [Required]
    [StringLength(50, MinimumLength = 3)]
    public string Username { get; set; }
    
    [Required]
    [EmailAddress]
    public string Email { get; set; }
    
    [Required]
    [StringLength(100, MinimumLength = 6)]
    public string Password { get; set; }
    
    [Required]
    public string FirstName { get; set; }
    
    [Required]
    public string LastName { get; set; }
    
    public string Phone { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    public string ZipCode { get; set; }
    public string Country { get; set; }
}

// Shopping Cart Models
public class CartItem
{
    public long ProductId { get; set; }
    public string ProductName { get; set; }
    public decimal Price { get; set; }
    public int Quantity { get; set; }
    public string ImageUrl { get; set; }

    public decimal TotalPrice 
    { 
        get { return Price * Quantity; } 
    }
    
    public string FormattedPrice 
    { 
        get { return Price.ToString("C"); } 
    }
    
    public string FormattedTotalPrice 
    { 
        get { return TotalPrice.ToString("C"); } 
    }
}

public class ShoppingCart
{
    public List<CartItem> Items { get; set; }
    
    public ShoppingCart()
    {
        Items = new List<CartItem>();
    }

    public int TotalItems 
    { 
        get { return Items.Sum(i => i.Quantity); } 
    }
    
    public decimal TotalAmount 
    { 
        get { return Items.Sum(i => i.TotalPrice); } 
    }
    
    public string FormattedTotal 
    { 
        get { return TotalAmount.ToString("C"); } 
    }

    public void AddItem(Product product, int quantity = 1)
    {
        var existingItem = Items.FirstOrDefault(i => i.ProductId == product.Id);
        if (existingItem != null)
        {
            existingItem.Quantity += quantity;
        }
        else
        {
            Items.Add(new CartItem
            {
                ProductId = product.Id,
                ProductName = product.Name,
                Price = product.Price,
                Quantity = quantity,
                ImageUrl = product.ImageUrl
            });
        }
    }

    public void RemoveItem(long productId)
    {
        Items.RemoveAll(i => i.ProductId == productId);
    }

    public void UpdateQuantity(long productId, int quantity)
    {
        var item = Items.FirstOrDefault(i => i.ProductId == productId);
        if (item != null)
        {
            if (quantity <= 0)
            {
                RemoveItem(productId);
            }
            else
            {
                item.Quantity = quantity;
            }
        }
    }

    public void Clear()
    {
        Items.Clear();
    }
}

// API Response Models
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public string Message { get; set; }
    public T Data { get; set; }
    public string Error { get; set; }
}

public class PagedResult<T>
{
    public List<T> Items { get; set; }
    public int TotalCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages 
    { 
        get { return (int)Math.Ceiling((double)TotalCount / PageSize); } 
    }
    
    public bool HasPreviousPage 
    { 
        get { return PageNumber > 1; } 
    }
    
    public bool HasNextPage 
    { 
        get { return PageNumber < TotalPages; } 
    }
}
