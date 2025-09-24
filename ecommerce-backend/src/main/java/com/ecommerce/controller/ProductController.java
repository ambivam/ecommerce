package com.ecommerce.controller;

import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Product;
import com.ecommerce.service.ProductService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.List;
import java.util.Optional;

/**
 * REST Controller for Product operations
 */
@Path("/products")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ProductController {
    private static final Logger logger = LoggerFactory.getLogger(ProductController.class);
    private final ProductService productService;

    public ProductController() {
        this.productService = new ProductService();
    }

    /**
     * Get all active products
     */
    @GET
    public Response getAllProducts() {
        try {
            List<Product> products = productService.getAllActiveProducts();
            return Response.ok(products).build();
        } catch (Exception e) {
            logger.error("Error retrieving products", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve products\"}")
                    .build();
        }
    }

    /**
     * Get product by ID
     */
    @GET
    @Path("/{id}")
    public Response getProductById(@PathParam("id") Long id) {
        try {
            Optional<Product> product = productService.getProductById(id);
            if (product.isPresent()) {
                return Response.ok(product.get()).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Product not found\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error retrieving product with ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve product\"}")
                    .build();
        }
    }

    /**
     * Search products
     */
    @GET
    @Path("/search")
    public Response searchProducts(@QueryParam("q") String searchTerm) {
        try {
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Search term is required\"}")
                        .build();
            }

            List<Product> products = productService.searchProducts(searchTerm);
            return Response.ok(products).build();
        } catch (Exception e) {
            logger.error("Error searching products with term: {}", searchTerm, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to search products\"}")
                    .build();
        }
    }

    /**
     * Get products by category
     */
    @GET
    @Path("/category/{categoryId}")
    public Response getProductsByCategory(@PathParam("categoryId") Long categoryId) {
        try {
            List<Product> products = productService.getProductsByCategory(categoryId);
            return Response.ok(products).build();
        } catch (Exception e) {
            logger.error("Error retrieving products by category: {}", categoryId, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve products by category\"}")
                    .build();
        }
    }

    /**
     * Create new product (Admin only)
     */
    @POST
    public Response createProduct(Product product) {
        try {
            // Validate required fields
            if (product.getName() == null || product.getName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Product name is required\"}")
                        .build();
            }

            if (product.getPrice() == null || product.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Valid price is required\"}")
                        .build();
            }

            Product createdProduct = productService.createProduct(product);
            return Response.status(Response.Status.CREATED).entity(createdProduct).build();
        } catch (Exception e) {
            logger.error("Error creating product", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to create product\"}")
                    .build();
        }
    }

    /**
     * Update product (Admin only)
     */
    @PUT
    @Path("/{id}")
    public Response updateProduct(@PathParam("id") Long id, Product product) {
        try {
            product.setId(id);
            
            // Validate required fields
            if (product.getName() == null || product.getName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Product name is required\"}")
                        .build();
            }

            if (product.getPrice() == null || product.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Valid price is required\"}")
                        .build();
            }

            Optional<Product> existingProduct = productService.getProductById(id);
            if (!existingProduct.isPresent()) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Product not found\"}")
                        .build();
            }

            Product updatedProduct = productService.updateProduct(product);
            return Response.ok(updatedProduct).build();
        } catch (Exception e) {
            logger.error("Error updating product with ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to update product\"}")
                    .build();
        }
    }

    /**
     * Delete product (Admin only)
     */
    @DELETE
    @Path("/{id}")
    public Response deleteProduct(@PathParam("id") Long id) {
        try {
            Optional<Product> existingProduct = productService.getProductById(id);
            if (!existingProduct.isPresent()) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Product not found\"}")
                        .build();
            }

            boolean deleted = productService.deleteProduct(id);
            if (deleted) {
                return Response.ok("{\"message\":\"Product deleted successfully\"}").build();
            } else {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity("{\"error\":\"Failed to delete product\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error deleting product with ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to delete product\"}")
                    .build();
        }
    }

    /**
     * Update product stock
     */
    @PUT
    @Path("/{id}/stock")
    public Response updateStock(@PathParam("id") Long id, @QueryParam("quantity") Integer quantity) {
        try {
            if (quantity == null || quantity < 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Valid quantity is required\"}")
                        .build();
            }

            Optional<Product> existingProduct = productService.getProductById(id);
            if (!existingProduct.isPresent()) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Product not found\"}")
                        .build();
            }

            boolean updated = productService.updateStock(id, quantity);
            if (updated) {
                return Response.ok("{\"message\":\"Stock updated successfully\"}").build();
            } else {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity("{\"error\":\"Failed to update stock\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error updating stock for product ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to update stock\"}")
                    .build();
        }
    }
}
