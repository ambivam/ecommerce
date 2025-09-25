package com.ecommerce.controller;

import com.ecommerce.entity.Cart;
import com.ecommerce.service.CartService;
import com.ecommerce.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST Controller for Cart operations
 */
@Path("/cart")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CartController {
    
    private final CartService cartService;
    private final ObjectMapper objectMapper;
    private final JwtUtil jwtUtil;
    
    public CartController() {
        this.cartService = new CartService();
        this.objectMapper = new ObjectMapper();
        this.jwtUtil = new JwtUtil();
    }
    
    /**
     * Add item to cart
     * POST /api/cart/add
     */
    @POST
    @Path("/add")
    public Response addToCart(@HeaderParam("Authorization") String authHeader, String requestBody) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Parse request body
            Map<String, Object> request = objectMapper.readValue(requestBody, Map.class);
            Long productId = Long.valueOf(request.get("productId").toString());
            Integer quantity = Integer.valueOf(request.get("quantity").toString());
            
            // Validate input
            if (productId == null || quantity == null || quantity <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(createErrorResponse("Invalid product ID or quantity"))
                    .build();
            }
            
            // Add to cart
            Cart cartItem = cartService.addToCart(userId, productId, quantity);
            
            if (cartItem != null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Item added to cart successfully");
                response.put("cartItem", cartItem);
                response.put("cartItemCount", cartService.getCartSummary(userId).getTotalItems());
                
                return Response.ok(response).build();
            } else {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(createErrorResponse("Failed to add item to cart"))
                    .build();
            }
            
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(createErrorResponse(e.getMessage()))
                .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * Get user's cart
     * GET /api/cart
     */
    @GET
    public Response getCart(@HeaderParam("Authorization") String authHeader) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Get cart summary
            CartService.CartSummary cartSummary = cartService.getCartSummary(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("items", cartSummary.getItems());
            response.put("totalItems", cartSummary.getTotalItems());
            response.put("totalAmount", cartSummary.getTotalAmount());
            response.put("isEmpty", cartSummary.isEmpty());
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * Update cart item quantity
     * PUT /api/cart/{cartId}
     */
    @PUT
    @Path("/{cartId}")
    public Response updateCartItem(@HeaderParam("Authorization") String authHeader, 
                                 @PathParam("cartId") Long cartId, 
                                 String requestBody) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Parse request body
            Map<String, Object> request = objectMapper.readValue(requestBody, Map.class);
            Integer quantity = Integer.valueOf(request.get("quantity").toString());
            
            // Update cart item
            boolean updated = cartService.updateCartItemQuantity(cartId, userId, quantity);
            
            if (updated) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", quantity > 0 ? "Cart item updated successfully" : "Item removed from cart");
                response.put("cartItemCount", cartService.getCartSummary(userId).getTotalItems());
                
                return Response.ok(response).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                    .entity(createErrorResponse("Cart item not found"))
                    .build();
            }
            
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(createErrorResponse(e.getMessage()))
                .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * Remove item from cart
     * DELETE /api/cart/{cartId}
     */
    @DELETE
    @Path("/{cartId}")
    public Response removeFromCart(@HeaderParam("Authorization") String authHeader, 
                                 @PathParam("cartId") Long cartId) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Remove from cart
            boolean removed = cartService.removeFromCart(cartId, userId);
            
            if (removed) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Item removed from cart successfully");
                response.put("cartItemCount", cartService.getCartSummary(userId).getTotalItems());
                
                return Response.ok(response).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                    .entity(createErrorResponse("Cart item not found"))
                    .build();
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * Clear entire cart
     * DELETE /api/cart/clear
     */
    @DELETE
    @Path("/clear")
    public Response clearCart(@HeaderParam("Authorization") String authHeader) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Clear cart
            boolean cleared = cartService.clearCart(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", cleared ? "Cart cleared successfully" : "Cart was already empty");
            response.put("cartItemCount", 0);
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * Get cart item count
     * GET /api/cart/count
     */
    @GET
    @Path("/count")
    public Response getCartCount(@HeaderParam("Authorization") String authHeader) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Get cart count
            CartService.CartSummary cartSummary = cartService.getCartSummary(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("count", cartSummary.getTotalItems());
            response.put("totalAmount", cartSummary.getTotalAmount());
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * Validate cart items
     * GET /api/cart/validate
     */
    @GET
    @Path("/validate")
    public Response validateCart(@HeaderParam("Authorization") String authHeader) {
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                return Response.status(Response.Status.UNAUTHORIZED)
                    .entity(createErrorResponse("Invalid or missing authentication token"))
                    .build();
            }
            
            // Validate cart
            CartService.CartValidationResult validation = cartService.validateCart(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("isValid", validation.isValid());
            response.put("hasIssues", validation.hasIssues());
            response.put("validItems", validation.getValidItems());
            response.put("unavailableItems", validation.getUnavailableItems());
            response.put("outOfStockItems", validation.getOutOfStockItems());
            
            return Response.ok(response).build();
            
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(createErrorResponse("Internal server error: " + e.getMessage()))
                .build();
        }
    }
    
    /**
     * OPTIONS handler for CORS
     */
    @OPTIONS
    @Path("/{path:.*}")
    public Response handleCorsOptions() {
        return Response.ok().build();
    }
    
    /**
     * Validate JWT token and extract user ID
     */
    private Long validateTokenAndGetUserId(String authHeader) {
        try {
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return null;
            }
            
            String token = authHeader.substring(7);
            return jwtUtil.getUserIdFromToken(token);
            
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Create error response
     */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        return error;
    }
}
