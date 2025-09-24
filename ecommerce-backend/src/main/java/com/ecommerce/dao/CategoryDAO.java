package com.ecommerce.dao;

import com.ecommerce.model.Category;
import com.ecommerce.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for Category entity
 */
public class CategoryDAO {
    private static final Logger logger = LoggerFactory.getLogger(CategoryDAO.class);

    private static final String INSERT_CATEGORY = 
        "INSERT INTO categories (name, description) VALUES (?, ?)";

    private static final String SELECT_CATEGORY_BY_ID = 
        "SELECT * FROM categories WHERE id = ?";

    private static final String SELECT_ALL_CATEGORIES = 
        "SELECT * FROM categories ORDER BY name";

    private static final String SELECT_CATEGORY_BY_NAME = 
        "SELECT * FROM categories WHERE LOWER(name) = LOWER(?)";

    private static final String UPDATE_CATEGORY = 
        "UPDATE categories SET name = ?, description = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

    private static final String DELETE_CATEGORY = 
        "DELETE FROM categories WHERE id = ?";

    private static final String COUNT_PRODUCTS_BY_CATEGORY = 
        "SELECT COUNT(*) FROM products WHERE category_id = ?";

    /**
     * Create a new category
     */
    public Category save(Category category) {
        logger.debug("Creating new category: {}", category.getName());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_CATEGORY, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, category.getName());
            stmt.setString(2, category.getDescription());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating category failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    category.setId(generatedKeys.getLong(1));
                    logger.debug("Category created with ID: {}", category.getId());
                    return category;
                } else {
                    throw new SQLException("Creating category failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating category", e);
            throw new RuntimeException("Failed to create category", e);
        }
    }

    /**
     * Find category by ID
     */
    public Optional<Category> findById(Long id) {
        logger.debug("Finding category by ID: {}", id);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_CATEGORY_BY_ID)) {
            
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToCategory(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding category by ID: {}", id, e);
            throw new RuntimeException("Failed to find category", e);
        }
        
        return Optional.empty();
    }

    /**
     * Find all categories
     */
    public List<Category> findAll() {
        logger.debug("Finding all categories");
        List<Category> categories = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ALL_CATEGORIES);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                categories.add(mapResultSetToCategory(rs));
            }
        } catch (SQLException e) {
            logger.error("Error finding all categories", e);
            throw new RuntimeException("Failed to find categories", e);
        }
        
        return categories;
    }

    /**
     * Find category by name
     */
    public Optional<Category> findByName(String name) {
        logger.debug("Finding category by name: {}", name);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_CATEGORY_BY_NAME)) {
            
            stmt.setString(1, name);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToCategory(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding category by name: {}", name, e);
            throw new RuntimeException("Failed to find category", e);
        }
        
        return Optional.empty();
    }

    /**
     * Update category
     */
    public Category update(Category category) {
        logger.debug("Updating category: {}", category.getId());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_CATEGORY)) {
            
            stmt.setString(1, category.getName());
            stmt.setString(2, category.getDescription());
            stmt.setLong(3, category.getId());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Updating category failed, no rows affected.");
            }
            
            logger.debug("Category updated: {}", category.getId());
            return category;
        } catch (SQLException e) {
            logger.error("Error updating category: {}", category.getId(), e);
            throw new RuntimeException("Failed to update category", e);
        }
    }

    /**
     * Delete category
     */
    public void delete(Long id) {
        logger.debug("Deleting category: {}", id);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE_CATEGORY)) {
            
            stmt.setLong(1, id);
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Deleting category failed, no rows affected.");
            }
            
            logger.debug("Category deleted: {}", id);
        } catch (SQLException e) {
            logger.error("Error deleting category: {}", id, e);
            throw new RuntimeException("Failed to delete category", e);
        }
    }

    /**
     * Check if category exists by name (for validation)
     */
    public boolean existsByName(String name) {
        logger.debug("Checking if category exists by name: {}", name);
        return findByName(name).isPresent();
    }

    /**
     * Count products in category
     */
    public int countProductsInCategory(Long categoryId) {
        logger.debug("Counting products in category: {}", categoryId);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(COUNT_PRODUCTS_BY_CATEGORY)) {
            
            stmt.setLong(1, categoryId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error counting products in category: {}", categoryId, e);
            throw new RuntimeException("Failed to count products", e);
        }
        
        return 0;
    }

    /**
     * Map ResultSet to Category object
     */
    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        Category category = new Category();
        category.setId(rs.getLong("id"));
        category.setName(rs.getString("name"));
        category.setDescription(rs.getString("description"));
        category.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        category.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        return category;
    }
}
