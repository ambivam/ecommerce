package com.ecommerce.dao;

import com.ecommerce.model.User;
import com.ecommerce.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for User entity
 */
public class UserDAO {
    private static final Logger logger = LoggerFactory.getLogger(UserDAO.class);

    private static final String INSERT_USER = 
        "INSERT INTO users (username, email, password_hash, first_name, last_name, phone, address, city, state, zip_code, country, is_active, is_admin) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_USER_BY_ID = 
        "SELECT * FROM users WHERE id = ?";

    private static final String SELECT_USER_BY_USERNAME = 
        "SELECT * FROM users WHERE username = ?";

    private static final String SELECT_USER_BY_EMAIL = 
        "SELECT * FROM users WHERE email = ?";

    private static final String SELECT_ALL_USERS = 
        "SELECT * FROM users ORDER BY created_at DESC";

    private static final String UPDATE_USER = 
        "UPDATE users SET username = ?, email = ?, first_name = ?, last_name = ?, phone = ?, address = ?, city = ?, state = ?, zip_code = ?, country = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

    private static final String DELETE_USER = 
        "DELETE FROM users WHERE id = ?";

    private static final String COUNT_USERS = 
        "SELECT COUNT(*) FROM users";

    /**
     * Create a new user
     */
    public User create(User user) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_USER, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getFirstName());
            stmt.setString(5, user.getLastName());
            stmt.setString(6, user.getPhone());
            stmt.setString(7, user.getAddress());
            stmt.setString(8, user.getCity());
            stmt.setString(9, user.getState());
            stmt.setString(10, user.getZipCode());
            stmt.setString(11, user.getCountry());
            stmt.setBoolean(12, user.isActive());
            stmt.setBoolean(13, user.isAdmin());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating user failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    user.setId(generatedKeys.getLong(1));
                } else {
                    throw new SQLException("Creating user failed, no ID obtained.");
                }
            }

            logger.info("User created successfully with ID: {}", user.getId());
            return user;

        } catch (SQLException e) {
            logger.error("Error creating user: {}", user.getUsername(), e);
            throw new RuntimeException("Failed to create user", e);
        }
    }

    /**
     * Find user by ID
     */
    public Optional<User> findById(Long id) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_USER_BY_ID)) {

            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }

        } catch (SQLException e) {
            logger.error("Error finding user by ID: {}", id, e);
        }
        return Optional.empty();
    }

    /**
     * Find user by username
     */
    public Optional<User> findByUsername(String username) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_USER_BY_USERNAME)) {

            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }

        } catch (SQLException e) {
            logger.error("Error finding user by username: {}", username, e);
        }
        return Optional.empty();
    }

    /**
     * Find user by email
     */
    public Optional<User> findByEmail(String email) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_USER_BY_EMAIL)) {

            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }

        } catch (SQLException e) {
            logger.error("Error finding user by email: {}", email, e);
        }
        return Optional.empty();
    }

    /**
     * Get all users
     */
    public List<User> findAll() {
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ALL_USERS);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }

        } catch (SQLException e) {
            logger.error("Error retrieving all users", e);
        }
        
        return users;
    }

    /**
     * Update user
     */
    public User update(User user) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_USER)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getFirstName());
            stmt.setString(4, user.getLastName());
            stmt.setString(5, user.getPhone());
            stmt.setString(6, user.getAddress());
            stmt.setString(7, user.getCity());
            stmt.setString(8, user.getState());
            stmt.setString(9, user.getZipCode());
            stmt.setString(10, user.getCountry());
            stmt.setBoolean(11, user.isActive());
            stmt.setLong(12, user.getId());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Updating user failed, no rows affected.");
            }

            user.setUpdatedAt(LocalDateTime.now());
            logger.info("User updated successfully: {}", user.getId());
            return user;

        } catch (SQLException e) {
            logger.error("Error updating user: {}", user.getId(), e);
            throw new RuntimeException("Failed to update user", e);
        }
    }

    /**
     * Delete user
     */
    public boolean delete(Long id) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE_USER)) {

            stmt.setLong(1, id);
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                logger.info("User deleted successfully: {}", id);
                return true;
            }

        } catch (SQLException e) {
            logger.error("Error deleting user: {}", id, e);
        }
        return false;
    }

    /**
     * Count total users
     */
    public long count() {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(COUNT_USERS);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                return rs.getLong(1);
            }

        } catch (SQLException e) {
            logger.error("Error counting users", e);
        }
        return 0;
    }

    /**
     * Check if username exists
     */
    public boolean existsByUsername(String username) {
        return findByUsername(username).isPresent();
    }

    /**
     * Check if email exists
     */
    public boolean existsByEmail(String email) {
        return findByEmail(email).isPresent();
    }

    /**
     * Map ResultSet to User object
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setCity(rs.getString("city"));
        user.setState(rs.getString("state"));
        user.setZipCode(rs.getString("zip_code"));
        user.setCountry(rs.getString("country"));
        user.setActive(rs.getBoolean("is_active"));
        user.setAdmin(rs.getBoolean("is_admin"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            user.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return user;
    }
}
