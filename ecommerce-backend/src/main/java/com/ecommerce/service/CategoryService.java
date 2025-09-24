package com.ecommerce.service;

import com.ecommerce.dao.CategoryDAO;
import com.ecommerce.model.Category;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Optional;

/**
 * Service layer for Category operations
 */
public class CategoryService {
    private static final Logger logger = LoggerFactory.getLogger(CategoryService.class);
    private final CategoryDAO categoryDAO;

    public CategoryService() {
        this.categoryDAO = new CategoryDAO();
    }

    /**
     * Create a new category
     */
    public Category createCategory(Category category) {
        logger.debug("Creating new category: {}", category.getName());
        
        // Validate category name is unique
        if (categoryDAO.existsByName(category.getName())) {
            throw new IllegalArgumentException("Category with name '" + category.getName() + "' already exists");
        }
        
        // Validate required fields
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Category name is required");
        }
        
        return categoryDAO.save(category);
    }

    /**
     * Get all categories
     */
    public List<Category> getAllCategories() {
        logger.debug("Retrieving all categories");
        return categoryDAO.findAll();
    }

    /**
     * Get category by ID
     */
    public Optional<Category> getCategoryById(Long id) {
        logger.debug("Retrieving category by ID: {}", id);
        return categoryDAO.findById(id);
    }

    /**
     * Get category by name
     */
    public Optional<Category> getCategoryByName(String name) {
        logger.debug("Retrieving category by name: {}", name);
        return categoryDAO.findByName(name);
    }

    /**
     * Update category
     */
    public Category updateCategory(Category category) {
        logger.debug("Updating category: {}", category.getId());
        
        // Validate category exists
        Optional<Category> existingCategory = categoryDAO.findById(category.getId());
        if (!existingCategory.isPresent()) {
            throw new IllegalArgumentException("Category not found with ID: " + category.getId());
        }
        
        // Validate required fields
        if (category.getName() == null || category.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Category name is required");
        }
        
        // Check if name is unique (excluding current category)
        Optional<Category> categoryWithSameName = categoryDAO.findByName(category.getName());
        if (categoryWithSameName.isPresent() && !categoryWithSameName.get().getId().equals(category.getId())) {
            throw new IllegalArgumentException("Category with name '" + category.getName() + "' already exists");
        }
        
        return categoryDAO.update(category);
    }

    /**
     * Delete category
     */
    public void deleteCategory(Long categoryId) {
        logger.debug("Deleting category: {}", categoryId);
        
        // Validate category exists
        Optional<Category> existingCategory = categoryDAO.findById(categoryId);
        if (!existingCategory.isPresent()) {
            throw new IllegalArgumentException("Category not found with ID: " + categoryId);
        }
        
        // Check if category has products
        int productCount = categoryDAO.countProductsInCategory(categoryId);
        if (productCount > 0) {
            throw new IllegalStateException("Cannot delete category with " + productCount + " products. Please move or delete products first.");
        }
        
        categoryDAO.delete(categoryId);
    }

    /**
     * Check if category exists by name
     */
    public boolean categoryExistsByName(String name) {
        logger.debug("Checking if category exists by name: {}", name);
        return categoryDAO.existsByName(name);
    }

    /**
     * Get product count for category
     */
    public int getProductCountForCategory(Long categoryId) {
        logger.debug("Getting product count for category: {}", categoryId);
        
        // Validate category exists
        Optional<Category> existingCategory = categoryDAO.findById(categoryId);
        if (!existingCategory.isPresent()) {
            throw new IllegalArgumentException("Category not found with ID: " + categoryId);
        }
        
        return categoryDAO.countProductsInCategory(categoryId);
    }
}
