package com.ecommerce.service;

import com.ecommerce.dao.ProductDAO;
import com.ecommerce.model.Product;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Optional;

/**
 * Service layer for Product operations
 */
public class ProductService {
    private static final Logger logger = LoggerFactory.getLogger(ProductService.class);
    private final ProductDAO productDAO;

    public ProductService() {
        this.productDAO = new ProductDAO();
    }

    /**
     * Get all active products
     */
    public List<Product> getAllActiveProducts() {
        logger.debug("Retrieving all active products");
        return productDAO.findAllActive();
    }

    /**
     * Get all products (including inactive)
     */
    public List<Product> getAllProducts() {
        logger.debug("Retrieving all products");
        return productDAO.findAll();
    }

    /**
     * Get product by ID
     */
    public Optional<Product> getProductById(Long id) {
        logger.debug("Retrieving product by ID: {}", id);
        return productDAO.findById(id);
    }

    /**
     * Get products by category
     */
    public List<Product> getProductsByCategory(Long categoryId) {
        logger.debug("Retrieving products by category: {}", categoryId);
        return productDAO.findByCategory(categoryId);
    }

    /**
     * Search products by name or description
     */
    public List<Product> searchProducts(String searchTerm) {
        logger.debug("Searching products with term: {}", searchTerm);
        return productDAO.searchProducts(searchTerm);
    }

    /**
     * Create new product
     */
    public Product createProduct(Product product) {
        logger.info("Creating new product: {}", product.getName());
        
        // Validate business rules
        validateProduct(product);
        
        // Set default values
        if (product.getStockQuantity() == null) {
            product.setStockQuantity(0);
        }
        
        if (product.getImageUrl() == null || product.getImageUrl().trim().isEmpty()) {
            product.setImageUrl("/images/default-product.jpg");
        }
        
        return productDAO.create(product);
    }

    /**
     * Update existing product
     */
    public Product updateProduct(Product product) {
        logger.info("Updating product: {}", product.getId());
        
        // Validate business rules
        validateProduct(product);
        
        // Check if product exists
        Optional<Product> existingProduct = productDAO.findById(product.getId());
        if (!existingProduct.isPresent()) {
            throw new IllegalArgumentException("Product not found with ID: " + product.getId());
        }
        
        return productDAO.update(product);
    }

    /**
     * Delete product
     */
    public boolean deleteProduct(Long id) {
        logger.info("Deleting product: {}", id);
        
        // Check if product exists
        Optional<Product> existingProduct = productDAO.findById(id);
        if (!existingProduct.isPresent()) {
            throw new IllegalArgumentException("Product not found with ID: " + id);
        }
        
        // TODO: Check if product is referenced in any orders before deleting
        // For now, we'll just delete it
        
        return productDAO.delete(id);
    }

    /**
     * Update product stock
     */
    public boolean updateStock(Long productId, Integer newStock) {
        logger.info("Updating stock for product {}: {}", productId, newStock);
        
        if (newStock < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative");
        }
        
        return productDAO.updateStock(productId, newStock);
    }

    /**
     * Reduce product stock (for order processing)
     */
    public boolean reduceStock(Long productId, Integer quantity) {
        logger.info("Reducing stock for product {}: {}", productId, quantity);
        
        Optional<Product> productOpt = productDAO.findById(productId);
        if (!productOpt.isPresent()) {
            throw new IllegalArgumentException("Product not found with ID: " + productId);
        }
        
        Product product = productOpt.get();
        if (product.getStockQuantity() < quantity) {
            throw new IllegalArgumentException("Insufficient stock. Available: " + product.getStockQuantity() + ", Requested: " + quantity);
        }
        
        int newStock = product.getStockQuantity() - quantity;
        return productDAO.updateStock(productId, newStock);
    }

    /**
     * Check if product is available for purchase
     */
    public boolean isProductAvailable(Long productId, Integer quantity) {
        Optional<Product> productOpt = productDAO.findById(productId);
        if (!productOpt.isPresent()) {
            return false;
        }
        
        Product product = productOpt.get();
        return product.isActive() && product.getStockQuantity() >= quantity;
    }

    /**
     * Get product count
     */
    public long getProductCount() {
        return productDAO.count();
    }

    /**
     * Get active product count
     */
    public long getActiveProductCount() {
        return productDAO.countActive();
    }

    /**
     * Validate product data
     */
    private void validateProduct(Product product) {
        if (product.getName() == null || product.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Product name is required");
        }
        
        if (product.getName().length() > 255) {
            throw new IllegalArgumentException("Product name cannot exceed 255 characters");
        }
        
        if (product.getPrice() == null) {
            throw new IllegalArgumentException("Product price is required");
        }
        
        if (product.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Product price cannot be negative");
        }
        
        if (product.getStockQuantity() != null && product.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative");
        }
        
        if (product.getDescription() != null && product.getDescription().length() > 1000) {
            throw new IllegalArgumentException("Product description cannot exceed 1000 characters");
        }
    }
}
