package com.ecommerce.controller;

import com.ecommerce.model.User;
import com.ecommerce.service.UserService;
import com.ecommerce.dto.LoginRequest;
import com.ecommerce.dto.LoginResponse;
import com.ecommerce.dto.RegisterRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.List;
import java.util.Optional;

/**
 * REST Controller for User operations
 */
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);
    private final UserService userService;

    public UserController() {
        this.userService = new UserService();
    }

    /**
     * User registration
     */
    @POST
    @Path("/register")
    public Response register(RegisterRequest request) {
        try {
            // Validate required fields
            if (request.getUsername() == null || request.getUsername().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Username is required\"}")
                        .build();
            }

            if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Email is required\"}")
                        .build();
            }

            if (request.getPassword() == null || request.getPassword().length() < 6) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Password must be at least 6 characters\"}")
                        .build();
            }

            if (request.getFirstName() == null || request.getFirstName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"First name is required\"}")
                        .build();
            }

            if (request.getLastName() == null || request.getLastName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Last name is required\"}")
                        .build();
            }

            User user = userService.registerUser(request);
            return Response.status(Response.Status.CREATED).entity(user).build();
        } catch (IllegalArgumentException e) {
            logger.warn("Registration failed: {}", e.getMessage());
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error during user registration", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Registration failed\"}")
                    .build();
        }
    }

    /**
     * User login
     */
    @POST
    @Path("/login")
    public Response login(LoginRequest request) {
        try {
            if (request.getUsername() == null || request.getUsername().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Username is required\"}")
                        .build();
            }

            if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Password is required\"}")
                        .build();
            }

            Optional<LoginResponse> loginResponse = userService.authenticateUser(request.getUsername(), request.getPassword());
            if (loginResponse.isPresent()) {
                return Response.ok(loginResponse.get()).build();
            } else {
                return Response.status(Response.Status.UNAUTHORIZED)
                        .entity("{\"error\":\"Invalid username or password\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error during user login", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Login failed\"}")
                    .build();
        }
    }

    /**
     * Get user profile by ID
     */
    @GET
    @Path("/{id}")
    public Response getUserById(@PathParam("id") Long id) {
        try {
            Optional<User> user = userService.getUserById(id);
            if (user.isPresent()) {
                return Response.ok(user.get()).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"User not found\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error retrieving user with ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve user\"}")
                    .build();
        }
    }

    /**
     * Get all users (Admin only)
     */
    @GET
    public Response getAllUsers() {
        try {
            List<User> users = userService.getAllUsers();
            return Response.ok(users).build();
        } catch (Exception e) {
            logger.error("Error retrieving users", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve users\"}")
                    .build();
        }
    }

    /**
     * Update user profile
     */
    @PUT
    @Path("/{id}")
    public Response updateUser(@PathParam("id") Long id, User user) {
        try {
            user.setId(id);
            
            // Validate required fields
            if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Username is required\"}")
                        .build();
            }

            if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Email is required\"}")
                        .build();
            }

            Optional<User> existingUser = userService.getUserById(id);
            if (!existingUser.isPresent()) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"User not found\"}")
                        .build();
            }

            User updatedUser = userService.updateUser(user);
            return Response.ok(updatedUser).build();
        } catch (IllegalArgumentException e) {
            logger.warn("User update failed: {}", e.getMessage());
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error updating user with ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to update user\"}")
                    .build();
        }
    }

    /**
     * Delete user (Admin only)
     */
    @DELETE
    @Path("/{id}")
    public Response deleteUser(@PathParam("id") Long id) {
        try {
            Optional<User> existingUser = userService.getUserById(id);
            if (!existingUser.isPresent()) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"User not found\"}")
                        .build();
            }

            boolean deleted = userService.deleteUser(id);
            if (deleted) {
                return Response.ok("{\"message\":\"User deleted successfully\"}").build();
            } else {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity("{\"error\":\"Failed to delete user\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error deleting user with ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to delete user\"}")
                    .build();
        }
    }

    /**
     * Change user password
     */
    @PUT
    @Path("/{id}/password")
    public Response changePassword(@PathParam("id") Long id, 
                                 @QueryParam("currentPassword") String currentPassword,
                                 @QueryParam("newPassword") String newPassword) {
        try {
            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Current password is required\"}")
                        .build();
            }

            if (newPassword == null || newPassword.length() < 6) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"New password must be at least 6 characters\"}")
                        .build();
            }

            boolean changed = userService.changePassword(id, currentPassword, newPassword);
            if (changed) {
                return Response.ok("{\"message\":\"Password changed successfully\"}").build();
            } else {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Invalid current password\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error changing password for user ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to change password\"}")
                    .build();
        }
    }
}
