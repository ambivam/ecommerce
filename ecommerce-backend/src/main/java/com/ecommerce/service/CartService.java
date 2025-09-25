package com.ecommerce.service;

import com.ecommerce.dao.CartDAO;
import com.ecommerce.dao.ProductDAO;
import com.ecommerce.entity.Cart;
import com.ecommerce.model.Product;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Service layer for Cart operations
 */
public class CartService {
    private final CartDAO cartDAO;
    private final ProductDAO productDAO;
    
    public CartService() {
        this.cartDAO = new CartDAO();
        this.productDAO = new ProductDAO();
    }
    
    /**
     * Add product to cart with validation
     */
    public Cart addToCart(Long userId, Long productId, Integer quantity) throws SQLException {
        // Validate product exists and is available
        Optional<Product> productOpt = productDAO.findById(productId);
        if (!productOpt.isPresent()) {
            throw new IllegalArgumentException("Product not found");
        }
        Product product = productOpt.get();
        if (product == null) {
            throw new IllegalArgumentException("Product not found");
        }
        
        if (!product.isActive() || !product.isAvailable()) {
            throw new IllegalArgumentException("Product is not available");
        }
        
        // Check stock availability
        if (product.getStockQuantity() < quantity) {
            throw new IllegalArgumentException("Insufficient stock. Available: " + product.getStockQuantity());
        }
        
        // Check if adding this quantity would exceed stock
        List<Cart> existingCart = cartDAO.getCartByUserId(userId);
        int currentQuantityInCart = 0;
        for (Cart item : existingCart) {
            if (item.getProductId().equals(productId)) {
                currentQuantityInCart = item.getQuantity();
                break;
            }
        }
        
        if (currentQuantityInCart + quantity > product.getStockQuantity()) {
            throw new IllegalArgumentException("Cannot add " + quantity + " items. Current in cart: " + 
                currentQuantityInCart + ", Available: " + product.getStockQuantity());
        }
        
        // Add to cart with current product price
        return cartDAO.addToCart(userId, productId, quantity, product.getPrice());
    }
    
    /**
     * Get user's cart items
     */
    public List<Cart> getUserCart(Long userId) throws SQLException {
        return cartDAO.getCartByUserId(userId);
    }
    
    /**
     * Update cart item quantity with validation
     */
    public boolean updateCartItemQuantity(Long cartId, Long userId, Integer quantity) throws SQLException {
        if (quantity <= 0) {
            // If quantity is 0 or negative, remove the item
            return cartDAO.removeFromCart(cartId, userId);
        }
        
        // Get current cart item to validate against product stock
        List<Cart> cartItems = cartDAO.getCartByUserId(userId);
        Cart targetItem = null;
        for (Cart item : cartItems) {
            if (item.getId().equals(cartId)) {
                targetItem = item;
                break;
            }
        }
        
        if (targetItem == null) {
            throw new IllegalArgumentException("Cart item not found");
        }
        
        // Validate stock availability
        Optional<Product> productOpt = productDAO.findById(targetItem.getProductId());
        if (!productOpt.isPresent()) {
            throw new IllegalArgumentException("Product not found");
        }
        Product product = productOpt.get();
        if (product == null || quantity > product.getStockQuantity()) {
            throw new IllegalArgumentException("Insufficient stock. Available: " + 
                (product != null ? product.getStockQuantity() : 0));
        }
        
        return cartDAO.updateCartItemQuantity(cartId, userId, quantity);
    }
    
    /**
     * Remove item from cart
     */
    public boolean removeFromCart(Long cartId, Long userId) throws SQLException {
        return cartDAO.removeFromCart(cartId, userId);
    }
    
    /**
     * Clear user's entire cart
     */
    public boolean clearCart(Long userId) throws SQLException {
        return cartDAO.clearCart(userId);
    }
    
    /**
     * Get cart summary
     */
    public CartSummary getCartSummary(Long userId) throws SQLException {
        List<Cart> cartItems = cartDAO.getCartByUserId(userId);
        int totalItems = cartDAO.getCartItemCount(userId);
        BigDecimal totalAmount = cartDAO.getCartTotal(userId);
        
        return new CartSummary(cartItems, totalItems, totalAmount);
    }
    
    /**
     * Validate cart items against current product availability
     */
    public CartValidationResult validateCart(Long userId) throws SQLException {
        List<Cart> cartItems = cartDAO.getCartByUserId(userId);
        CartValidationResult result = new CartValidationResult();
        
        for (Cart item : cartItems) {
            Optional<Product> productOpt = productDAO.findById(item.getProductId());
            if (!productOpt.isPresent()) {
                result.addUnavailableItem(item);
                continue;
            }
            Product product = productOpt.get();
            
            if (product == null || !product.isActive() || !product.isAvailable()) {
                result.addUnavailableItem(item);
            } else if (item.getQuantity() > product.getStockQuantity()) {
                result.addOutOfStockItem(item, product.getStockQuantity());
            } else {
                result.addValidItem(item);
            }
        }
        
        return result;
    }
    
    /**
     * Cart Summary inner class
     */
    public static class CartSummary {
        private final List<Cart> items;
        private final int totalItems;
        private final BigDecimal totalAmount;
        
        public CartSummary(List<Cart> items, int totalItems, BigDecimal totalAmount) {
            this.items = items;
            this.totalItems = totalItems;
            this.totalAmount = totalAmount;
        }
        
        public List<Cart> getItems() { return items; }
        public int getTotalItems() { return totalItems; }
        public BigDecimal getTotalAmount() { return totalAmount; }
        public boolean isEmpty() { return items.isEmpty(); }
    }
    
    /**
     * Cart Validation Result inner class
     */
    public static class CartValidationResult {
        private final List<Cart> validItems = new java.util.ArrayList<>();
        private final List<Cart> unavailableItems = new java.util.ArrayList<>();
        private final List<CartItemIssue> outOfStockItems = new java.util.ArrayList<>();
        
        public void addValidItem(Cart item) { validItems.add(item); }
        public void addUnavailableItem(Cart item) { unavailableItems.add(item); }
        public void addOutOfStockItem(Cart item, int availableStock) { 
            outOfStockItems.add(new CartItemIssue(item, availableStock)); 
        }
        
        public List<Cart> getValidItems() { return validItems; }
        public List<Cart> getUnavailableItems() { return unavailableItems; }
        public List<CartItemIssue> getOutOfStockItems() { return outOfStockItems; }
        public boolean hasIssues() { return !unavailableItems.isEmpty() || !outOfStockItems.isEmpty(); }
        public boolean isValid() { return !hasIssues(); }
    }
    
    /**
     * Cart Item Issue inner class
     */
    public static class CartItemIssue {
        private final Cart item;
        private final int availableStock;
        
        public CartItemIssue(Cart item, int availableStock) {
            this.item = item;
            this.availableStock = availableStock;
        }
        
        public Cart getItem() { return item; }
        public int getAvailableStock() { return availableStock; }
    }
}
