package com.ecommerce.controller;

import com.ecommerce.model.Category;
import com.ecommerce.service.CategoryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.List;
import java.util.Optional;

/**
 * REST Controller for Category operations
 */
@Path("/categories")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CategoryController {
    private static final Logger logger = LoggerFactory.getLogger(CategoryController.class);
    private final CategoryService categoryService;

    public CategoryController() {
        this.categoryService = new CategoryService();
    }

    /**
     * Get all categories
     */
    @GET
    public Response getAllCategories() {
        try {
            List<Category> categories = categoryService.getAllCategories();
            return Response.ok(categories).build();
        } catch (Exception e) {
            logger.error("Error retrieving categories", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve categories\"}")
                    .build();
        }
    }

    /**
     * Get category by ID
     */
    @GET
    @Path("/{id}")
    public Response getCategoryById(@PathParam("id") Long id) {
        try {
            Optional<Category> category = categoryService.getCategoryById(id);
            if (category.isPresent()) {
                return Response.ok(category.get()).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Category not found\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error retrieving category by ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve category\"}")
                    .build();
        }
    }

    /**
     * Get category by name
     */
    @GET
    @Path("/name/{name}")
    public Response getCategoryByName(@PathParam("name") String name) {
        try {
            Optional<Category> category = categoryService.getCategoryByName(name);
            if (category.isPresent()) {
                return Response.ok(category.get()).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Category not found\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error retrieving category by name: {}", name, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve category\"}")
                    .build();
        }
    }

    /**
     * Create new category
     */
    @POST
    public Response createCategory(Category category) {
        try {
            if (category == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Category data is required\"}")
                        .build();
            }

            if (category.getName() == null || category.getName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Category name is required\"}")
                        .build();
            }

            Category createdCategory = categoryService.createCategory(category);
            return Response.status(Response.Status.CREATED)
                    .entity(createdCategory)
                    .build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error creating category", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to create category\"}")
                    .build();
        }
    }

    /**
     * Update category
     */
    @PUT
    @Path("/{id}")
    public Response updateCategory(@PathParam("id") Long id, Category category) {
        try {
            if (category == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Category data is required\"}")
                        .build();
            }

            if (category.getName() == null || category.getName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Category name is required\"}")
                        .build();
            }

            category.setId(id);
            Category updatedCategory = categoryService.updateCategory(category);
            return Response.ok(updatedCategory).build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error updating category: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to update category\"}")
                    .build();
        }
    }

    /**
     * Delete category
     */
    @DELETE
    @Path("/{id}")
    public Response deleteCategory(@PathParam("id") Long id) {
        try {
            categoryService.deleteCategory(id);
            return Response.ok("{\"message\":\"Category deleted successfully\"}").build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (IllegalStateException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error deleting category: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to delete category\"}")
                    .build();
        }
    }

    /**
     * Check if category exists by name
     */
    @GET
    @Path("/exists/{name}")
    public Response categoryExistsByName(@PathParam("name") String name) {
        try {
            boolean exists = categoryService.categoryExistsByName(name);
            return Response.ok("{\"exists\":" + exists + "}").build();
        } catch (Exception e) {
            logger.error("Error checking category existence by name: {}", name, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to check category existence\"}")
                    .build();
        }
    }

    /**
     * Get product count for category
     */
    @GET
    @Path("/{id}/products/count")
    public Response getProductCountForCategory(@PathParam("id") Long id) {
        try {
            int count = categoryService.getProductCountForCategory(id);
            return Response.ok("{\"productCount\":" + count + "}").build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error getting product count for category: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to get product count\"}")
                    .build();
        }
    }
}
