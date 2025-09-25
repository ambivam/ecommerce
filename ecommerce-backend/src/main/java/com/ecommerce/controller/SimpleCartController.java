package com.ecommerce.controller;

import com.ecommerce.entity.Cart;
import com.ecommerce.service.CartService;
import com.ecommerce.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;

/**
 * Simplified Cart Controller with CORS headers
 */
@Path("/simplecart")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class SimpleCartController {
    
    private final CartService cartService;
    private final ObjectMapper objectMapper;
    private final JwtUtil jwtUtil;
    
    public SimpleCartController() {
        this.cartService = new CartService();
        this.objectMapper = new ObjectMapper();
        this.jwtUtil = new JwtUtil();
    }
    
    /**
     * Add item to cart - Simplified version
     */
    @POST
    @Path("/add")
    public Response addToCart(@HeaderParam("Authorization") String authHeader, String requestBody) {
        // Add CORS headers to response
        Response.ResponseBuilder responseBuilder;
        
        try {
            // Validate JWT token and get user ID
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("error", "Invalid or missing authentication token");
                
                responseBuilder = Response.status(Response.Status.UNAUTHORIZED).entity(error);
            } else {
                // Parse request body
                Map<String, Object> request = objectMapper.readValue(requestBody, Map.class);
                Long productId = Long.valueOf(request.get("productId").toString());
                Integer quantity = Integer.valueOf(request.get("quantity").toString());
                
                // Add to cart
                Cart cartItem = cartService.addToCart(userId, productId, quantity);
                
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Item added to cart successfully");
                response.put("cartItem", cartItem);
                response.put("cartItemCount", cartService.getCartSummary(userId).getTotalItems());
                
                responseBuilder = Response.ok(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error: " + e.getMessage());
            
            responseBuilder = Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error);
        }
        
        // Add CORS headers
        return responseBuilder
            .header("Access-Control-Allow-Origin", "*")
            .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
            .header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
            .build();
    }
    
    /**
     * Get cart count
     */
    @GET
    @Path("/count")
    public Response getCartCount(@HeaderParam("Authorization") String authHeader) {
        Response.ResponseBuilder responseBuilder;
        
        try {
            Long userId = validateTokenAndGetUserId(authHeader);
            if (userId == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("success", false);
                error.put("error", "Invalid authentication");
                responseBuilder = Response.status(Response.Status.UNAUTHORIZED).entity(error);
            } else {
                CartService.CartSummary cartSummary = cartService.getCartSummary(userId);
                
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("count", cartSummary.getTotalItems());
                response.put("totalAmount", cartSummary.getTotalAmount());
                
                responseBuilder = Response.ok(response);
            }
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("error", "Error: " + e.getMessage());
            responseBuilder = Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(error);
        }
        
        return responseBuilder
            .header("Access-Control-Allow-Origin", "*")
            .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
            .header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
            .build();
    }
    
    /**
     * Handle OPTIONS requests for CORS
     */
    @OPTIONS
    @Path("/{path:.*}")
    public Response handleCorsOptions() {
        return Response.ok()
            .header("Access-Control-Allow-Origin", "*")
            .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
            .header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
            .build();
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
}
