package com.ecommerce.dao;

import com.ecommerce.entity.Cart;
import com.ecommerce.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Cart operations
 */
public class CartDAO {
    
    /**
     * Add item to cart or update quantity if already exists
     */
    public Cart addToCart(Long userId, Long productId, Integer quantity, BigDecimal price) throws SQLException {
        String checkSql = "SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ?";
        String insertSql = "INSERT INTO cart (user_id, product_id, quantity, price) VALUES (?, ?, ?, ?) RETURNING id";
        String updateSql = "UPDATE cart SET quantity = quantity + ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ? AND product_id = ? RETURNING id";
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if item already exists in cart
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setLong(1, userId);
                checkStmt.setLong(2, productId);
                
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        // Item exists, update quantity
                        try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                            updateStmt.setInt(1, quantity);
                            updateStmt.setLong(2, userId);
                            updateStmt.setLong(3, productId);
                            
                            try (ResultSet updateRs = updateStmt.executeQuery()) {
                                if (updateRs.next()) {
                                    return getCartItemById(updateRs.getLong("id"));
                                }
                            }
                        }
                    } else {
                        // Item doesn't exist, insert new
                        try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                            insertStmt.setLong(1, userId);
                            insertStmt.setLong(2, productId);
                            insertStmt.setInt(3, quantity);
                            insertStmt.setBigDecimal(4, price);
                            
                            try (ResultSet insertRs = insertStmt.executeQuery()) {
                                if (insertRs.next()) {
                                    return getCartItemById(insertRs.getLong("id"));
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
    
    /**
     * Get all cart items for a user with product details
     */
    public List<Cart> getCartByUserId(Long userId) throws SQLException {
        String sql = "SELECT c.id, c.user_id, c.product_id, c.quantity, c.price, c.created_at, c.updated_at, " +
                     "p.name as product_name, p.description as product_description, " +
                     "p.image_url as product_image_url, p.stock_quantity, " +
                     "cat.name as category_name " +
                     "FROM cart c " +
                     "JOIN products p ON c.product_id = p.id " +
                     "LEFT JOIN categories cat ON p.category_id = cat.id " +
                     "WHERE c.user_id = ? " +
                     "ORDER BY c.created_at DESC";
        
        List<Cart> cartItems = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Cart cart = mapResultSetToCart(rs);
                    cartItems.add(cart);
                }
            }
        }
        
        return cartItems;
    }
    
    /**
     * Update cart item quantity
     */
    public boolean updateCartItemQuantity(Long cartId, Long userId, Integer quantity) throws SQLException {
        String sql = "UPDATE cart SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, quantity);
            stmt.setLong(2, cartId);
            stmt.setLong(3, userId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Remove item from cart
     */
    public boolean removeFromCart(Long cartId, Long userId) throws SQLException {
        String sql = "DELETE FROM cart WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, cartId);
            stmt.setLong(2, userId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Clear all items from user's cart
     */
    public boolean clearCart(Long userId) throws SQLException {
        String sql = "DELETE FROM cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Get cart item count for user
     */
    public int getCartItemCount(Long userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(quantity), 0) as total_items FROM cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_items");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Get cart total amount for user
     */
    public BigDecimal getCartTotal(Long userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(quantity * price), 0) as total_amount FROM cart WHERE user_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total_amount");
                }
            }
        }
        
        return BigDecimal.ZERO;
    }
    
    /**
     * Get cart item by ID
     */
    private Cart getCartItemById(Long cartId) throws SQLException {
        String sql = "SELECT c.id, c.user_id, c.product_id, c.quantity, c.price, c.created_at, c.updated_at, " +
                     "p.name as product_name, p.description as product_description, " +
                     "p.image_url as product_image_url, p.stock_quantity, " +
                     "cat.name as category_name " +
                     "FROM cart c " +
                     "JOIN products p ON c.product_id = p.id " +
                     "LEFT JOIN categories cat ON p.category_id = cat.id " +
                     "WHERE c.id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, cartId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCart(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Map ResultSet to Cart object
     */
    private Cart mapResultSetToCart(ResultSet rs) throws SQLException {
        Cart cart = new Cart();
        cart.setId(rs.getLong("id"));
        cart.setUserId(rs.getLong("user_id"));
        cart.setProductId(rs.getLong("product_id"));
        cart.setQuantity(rs.getInt("quantity"));
        cart.setPrice(rs.getBigDecimal("price"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            cart.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            cart.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        // Product details
        cart.setProductName(rs.getString("product_name"));
        cart.setProductDescription(rs.getString("product_description"));
        cart.setProductImageUrl(rs.getString("product_image_url"));
        cart.setStockQuantity(rs.getInt("stock_quantity"));
        cart.setCategoryName(rs.getString("category_name"));
        
        return cart;
    }
}
