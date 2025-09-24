package com.ecommerce.service;

import com.ecommerce.dao.UserDAO;
import com.ecommerce.dto.LoginResponse;
import com.ecommerce.dto.RegisterRequest;
import com.ecommerce.model.User;
import com.ecommerce.util.JwtUtil;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;

/**
 * Service layer for User operations
 */
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private final UserDAO userDAO;
    private final JwtUtil jwtUtil;
    
    // Email validation pattern
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$"
    );

    public UserService() {
        this.userDAO = new UserDAO();
        this.jwtUtil = new JwtUtil();
    }

    /**
     * Register a new user
     */
    public User registerUser(RegisterRequest request) {
        logger.info("Registering new user: {}", request.getUsername());
        
        // Validate input
        validateRegistrationRequest(request);
        
        // Check if username already exists
        if (userDAO.existsByUsername(request.getUsername())) {
            throw new IllegalArgumentException("Username already exists: " + request.getUsername());
        }
        
        // Check if email already exists
        if (userDAO.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already exists: " + request.getEmail());
        }
        
        // Hash password
        String hashedPassword = BCrypt.hashpw(request.getPassword(), BCrypt.gensalt());
        
        // Create user object
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(hashedPassword);
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPhone(request.getPhone());
        user.setAddress(request.getAddress());
        user.setCity(request.getCity());
        user.setState(request.getState());
        user.setZipCode(request.getZipCode());
        user.setCountry(request.getCountry() != null ? request.getCountry() : "USA");
        
        return userDAO.create(user);
    }

    /**
     * Authenticate user and return JWT token
     */
    public Optional<LoginResponse> authenticateUser(String username, String password) {
        logger.info("Authenticating user: {}", username);
        
        Optional<User> userOpt = userDAO.findByUsername(username);
        if (!userOpt.isPresent()) {
            logger.warn("User not found: {}", username);
            return Optional.empty();
        }
        
        User user = userOpt.get();
        
        // Check if user is active
        if (!user.isActive()) {
            logger.warn("User account is inactive: {}", username);
            return Optional.empty();
        }
        
        // Verify password
        if (!BCrypt.checkpw(password, user.getPasswordHash())) {
            logger.warn("Invalid password for user: {}", username);
            return Optional.empty();
        }
        
        // Generate JWT token
        String token = jwtUtil.generateToken(user);
        Long expiresIn = jwtUtil.getExpirationTime();
        
        LoginResponse response = new LoginResponse(token, expiresIn, user);
        logger.info("User authenticated successfully: {}", username);
        
        return Optional.of(response);
    }

    /**
     * Get user by ID
     */
    public Optional<User> getUserById(Long id) {
        logger.debug("Retrieving user by ID: {}", id);
        return userDAO.findById(id);
    }

    /**
     * Get user by username
     */
    public Optional<User> getUserByUsername(String username) {
        logger.debug("Retrieving user by username: {}", username);
        return userDAO.findByUsername(username);
    }

    /**
     * Get user by email
     */
    public Optional<User> getUserByEmail(String email) {
        logger.debug("Retrieving user by email: {}", email);
        return userDAO.findByEmail(email);
    }

    /**
     * Get all users
     */
    public List<User> getAllUsers() {
        logger.debug("Retrieving all users");
        return userDAO.findAll();
    }

    /**
     * Update user profile
     */
    public User updateUser(User user) {
        logger.info("Updating user: {}", user.getId());
        
        // Validate input
        validateUserUpdate(user);
        
        // Check if user exists
        Optional<User> existingUser = userDAO.findById(user.getId());
        if (!existingUser.isPresent()) {
            throw new IllegalArgumentException("User not found with ID: " + user.getId());
        }
        
        User existing = existingUser.get();
        
        // Check if username is being changed and if it's already taken
        if (!existing.getUsername().equals(user.getUsername()) && 
            userDAO.existsByUsername(user.getUsername())) {
            throw new IllegalArgumentException("Username already exists: " + user.getUsername());
        }
        
        // Check if email is being changed and if it's already taken
        if (!existing.getEmail().equals(user.getEmail()) && 
            userDAO.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already exists: " + user.getEmail());
        }
        
        // Preserve password hash and admin status from existing user
        user.setPasswordHash(existing.getPasswordHash());
        user.setAdmin(existing.isAdmin());
        
        return userDAO.update(user);
    }

    /**
     * Delete user
     */
    public boolean deleteUser(Long id) {
        logger.info("Deleting user: {}", id);
        
        // Check if user exists
        Optional<User> existingUser = userDAO.findById(id);
        if (!existingUser.isPresent()) {
            throw new IllegalArgumentException("User not found with ID: " + id);
        }
        
        // TODO: Check if user has any orders before deleting
        // For now, we'll just delete the user
        
        return userDAO.delete(id);
    }

    /**
     * Change user password
     */
    public boolean changePassword(Long userId, String currentPassword, String newPassword) {
        logger.info("Changing password for user: {}", userId);
        
        Optional<User> userOpt = userDAO.findById(userId);
        if (!userOpt.isPresent()) {
            throw new IllegalArgumentException("User not found with ID: " + userId);
        }
        
        User user = userOpt.get();
        
        // Verify current password
        if (!BCrypt.checkpw(currentPassword, user.getPasswordHash())) {
            logger.warn("Invalid current password for user: {}", userId);
            return false;
        }
        
        // Validate new password
        if (newPassword.length() < 6) {
            throw new IllegalArgumentException("New password must be at least 6 characters");
        }
        
        // Hash new password
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        user.setPasswordHash(hashedPassword);
        
        // Update user
        userDAO.update(user);
        logger.info("Password changed successfully for user: {}", userId);
        
        return true;
    }

    /**
     * Get user count
     */
    public long getUserCount() {
        return userDAO.count();
    }

    /**
     * Validate registration request
     */
    private void validateRegistrationRequest(RegisterRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty()) {
            throw new IllegalArgumentException("Username is required");
        }
        
        if (request.getUsername().length() < 3 || request.getUsername().length() > 50) {
            throw new IllegalArgumentException("Username must be between 3 and 50 characters");
        }
        
        if (!request.getUsername().matches("^[a-zA-Z0-9_]+$")) {
            throw new IllegalArgumentException("Username can only contain letters, numbers, and underscores");
        }
        
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        
        if (!EMAIL_PATTERN.matcher(request.getEmail()).matches()) {
            throw new IllegalArgumentException("Invalid email format");
        }
        
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters");
        }
        
        if (request.getFirstName() == null || request.getFirstName().trim().isEmpty()) {
            throw new IllegalArgumentException("First name is required");
        }
        
        if (request.getLastName() == null || request.getLastName().trim().isEmpty()) {
            throw new IllegalArgumentException("Last name is required");
        }
    }

    /**
     * Validate user update
     */
    private void validateUserUpdate(User user) {
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            throw new IllegalArgumentException("Username is required");
        }
        
        if (user.getUsername().length() < 3 || user.getUsername().length() > 50) {
            throw new IllegalArgumentException("Username must be between 3 and 50 characters");
        }
        
        if (!user.getUsername().matches("^[a-zA-Z0-9_]+$")) {
            throw new IllegalArgumentException("Username can only contain letters, numbers, and underscores");
        }
        
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        
        if (!EMAIL_PATTERN.matcher(user.getEmail()).matches()) {
            throw new IllegalArgumentException("Invalid email format");
        }
        
        if (user.getFirstName() == null || user.getFirstName().trim().isEmpty()) {
            throw new IllegalArgumentException("First name is required");
        }
        
        if (user.getLastName() == null || user.getLastName().trim().isEmpty()) {
            throw new IllegalArgumentException("Last name is required");
        }
    }
}
