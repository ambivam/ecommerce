package com.ecommerce.dao;

import com.ecommerce.model.Product;
import com.ecommerce.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for Product entity
 */
public class ProductDAO {
    private static final Logger logger = LoggerFactory.getLogger(ProductDAO.class);

    private static final String INSERT_PRODUCT = 
        "INSERT INTO products (name, description, price, stock_quantity, category_id, image_url, is_active) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_PRODUCT_BY_ID = 
        "SELECT p.*, c.name as category_name FROM products p " +
        "LEFT JOIN categories c ON p.category_id = c.id WHERE p.id = ?";

    private static final String SELECT_ALL_PRODUCTS = 
        "SELECT p.*, c.name as category_name FROM products p " +
        "LEFT JOIN categories c ON p.category_id = c.id ORDER BY p.created_at DESC";

    private static final String SELECT_ACTIVE_PRODUCTS = 
        "SELECT p.*, c.name as category_name FROM products p " +
        "LEFT JOIN categories c ON p.category_id = c.id WHERE p.is_active = true ORDER BY p.created_at DESC";

    private static final String SELECT_PRODUCTS_BY_CATEGORY = 
        "SELECT p.*, c.name as category_name FROM products p " +
        "LEFT JOIN categories c ON p.category_id = c.id WHERE p.category_id = ? AND p.is_active = true ORDER BY p.name";

    private static final String SEARCH_PRODUCTS = 
        "SELECT p.*, c.name as category_name FROM products p " +
        "LEFT JOIN categories c ON p.category_id = c.id " +
        "WHERE p.is_active = true AND (LOWER(p.name) LIKE LOWER(?) OR LOWER(p.description) LIKE LOWER(?)) " +
        "ORDER BY p.name";

    private static final String UPDATE_PRODUCT = 
        "UPDATE products SET name = ?, description = ?, price = ?, stock_quantity = ?, category_id = ?, image_url = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

    private static final String UPDATE_STOCK = 
        "UPDATE products SET stock_quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

    private static final String DELETE_PRODUCT = 
        "DELETE FROM products WHERE id = ?";

    private static final String COUNT_PRODUCTS = 
        "SELECT COUNT(*) FROM products";

    private static final String COUNT_ACTIVE_PRODUCTS = 
        "SELECT COUNT(*) FROM products WHERE is_active = true";

    /**
     * Create a new product
     */
    public Product create(Product product) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_PRODUCT, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setBigDecimal(3, product.getPrice());
            stmt.setInt(4, product.getStockQuantity());
            if (product.getCategoryId() != null) {
                stmt.setLong(5, product.getCategoryId());
            } else {
                stmt.setNull(5, Types.BIGINT);
            }
            stmt.setString(6, product.getImageUrl());
            stmt.setBoolean(7, product.isActive());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating product failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    product.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating product failed, no ID obtained.");
                }
            }

            logger.info("Product created successfully with ID: {}", product.getId());
            return product;

        } catch (SQLException e) {
            logger.error("Error creating product: {}", product.getName(), e);
            throw new RuntimeException("Failed to create product", e);
        }
    }

    /**
     * Find product by ID
     */
    public Optional<Product> findById(Long id) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_PRODUCT_BY_ID)) {

            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToProduct(rs));
                }
            }

        } catch (SQLException e) {
            logger.error("Error finding product by ID: {}", id, e);
        }
        return Optional.empty();
    }

    /**
     * Get all products
     */
    public List<Product> findAll() {
        List<Product> products = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ALL_PRODUCTS);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                products.add(mapResultSetToProduct(rs));
            }

        } catch (SQLException e) {
            logger.error("Error retrieving all products", e);
        }
        
        return products;
    }

    /**
     * Get all active products
     */
    public List<Product> findAllActive() {
        List<Product> products = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ACTIVE_PRODUCTS);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                products.add(mapResultSetToProduct(rs));
            }

        } catch (SQLException e) {
            logger.error("Error retrieving active products", e);
        }
        
        return products;
    }

    /**
     * Get products by category
     */
    public List<Product> findByCategory(Long categoryId) {
        List<Product> products = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_PRODUCTS_BY_CATEGORY)) {

            stmt.setLong(1, categoryId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }

        } catch (SQLException e) {
            logger.error("Error retrieving products by category: {}", categoryId, e);
        }
        
        return products;
    }

    /**
     * Search products by name or description
     */
    public List<Product> searchProducts(String searchTerm) {
        List<Product> products = new ArrayList<>();
        String searchPattern = "%" + searchTerm + "%";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SEARCH_PRODUCTS)) {

            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }

        } catch (SQLException e) {
            logger.error("Error searching products with term: {}", searchTerm, e);
        }
        
        return products;
    }

    /**
     * Update product
     */
    public Product update(Product product) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_PRODUCT)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setBigDecimal(3, product.getPrice());
            stmt.setInt(4, product.getStockQuantity());
            if (product.getCategoryId() != null) {
                stmt.setLong(5, product.getCategoryId());
            } else {
                stmt.setNull(5, Types.BIGINT);
            }
            stmt.setString(6, product.getImageUrl());
            stmt.setBoolean(7, product.isActive());
            stmt.setLong(8, product.getId());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Updating product failed, no rows affected.");
            }

            product.setUpdatedAt(LocalDateTime.now());
            logger.info("Product updated successfully: {}", product.getId());
            return product;

        } catch (SQLException e) {
            logger.error("Error updating product: {}", product.getId(), e);
            throw new RuntimeException("Failed to update product", e);
        }
    }

    /**
     * Update product stock quantity
     */
    public boolean updateStock(Long productId, Integer newStock) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_STOCK)) {

            stmt.setInt(1, newStock);
            stmt.setLong(2, productId);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                logger.info("Product stock updated successfully: {} -> {}", productId, newStock);
                return true;
            }

        } catch (SQLException e) {
            logger.error("Error updating product stock: {}", productId, e);
        }
        return false;
    }

    /**
     * Delete product
     */
    public boolean delete(Long id) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE_PRODUCT)) {

            stmt.setLong(1, id);
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                logger.info("Product deleted successfully: {}", id);
                return true;
            }

        } catch (SQLException e) {
            logger.error("Error deleting product: {}", id, e);
        }
        return false;
    }

    /**
     * Count total products
     */
    public long count() {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(COUNT_PRODUCTS);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                return rs.getLong(1);
            }

        } catch (SQLException e) {
            logger.error("Error counting products", e);
        }
        return 0;
    }

    /**
     * Count active products
     */
    public long countActive() {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(COUNT_ACTIVE_PRODUCTS);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                return rs.getLong(1);
            }

        } catch (SQLException e) {
            logger.error("Error counting active products", e);
        }
        return 0;
    }

    /**
     * Map ResultSet to Product object
     */
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getLong("id"));
        product.setName(rs.getString("name"));
        product.setDescription(rs.getString("description"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setStockQuantity(rs.getInt("stock_quantity"));
        
        Long categoryId = rs.getLong("category_id");
        if (!rs.wasNull()) {
            product.setCategoryId(categoryId);
        }
        
        product.setCategoryName(rs.getString("category_name"));
        product.setImageUrl(rs.getString("image_url"));
        product.setActive(rs.getBoolean("is_active"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            product.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            product.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return product;
    }
}
