package com.ecommerce.service;

import com.ecommerce.dao.OrderDAO;
import com.ecommerce.model.Order;
import com.ecommerce.model.OrderStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Service layer for Order operations
 */
public class OrderService {
    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);
    private final OrderDAO orderDAO;

    public OrderService() {
        this.orderDAO = new OrderDAO();
    }

    /**
     * Create a new order
     */
    public Order createOrder(Order order) {
        logger.debug("Creating new order for user: {}", order.getUserId());
        
        // Generate order number if not provided
        if (order.getOrderNumber() == null || order.getOrderNumber().isEmpty()) {
            order.setOrderNumber(generateOrderNumber());
        }
        
        // Set initial status if not provided
        if (order.getStatus() == null) {
            order.setStatus(OrderStatus.PENDING);
        }
        
        return orderDAO.save(order);
    }

    /**
     * Get all orders
     */
    public List<Order> getAllOrders() {
        logger.debug("Retrieving all orders");
        return orderDAO.findAll();
    }

    /**
     * Get order by ID
     */
    public Optional<Order> getOrderById(Long id) {
        logger.debug("Retrieving order by ID: {}", id);
        return orderDAO.findById(id);
    }

    /**
     * Get orders by user ID
     */
    public List<Order> getOrdersByUserId(Long userId) {
        logger.debug("Retrieving orders by user ID: {}", userId);
        return orderDAO.findByUserId(userId);
    }

    /**
     * Get orders by status
     */
    public List<Order> getOrdersByStatus(OrderStatus status) {
        logger.debug("Retrieving orders by status: {}", status);
        return orderDAO.findByStatus(status);
    }

    /**
     * Update order
     */
    public Order updateOrder(Order order) {
        logger.debug("Updating order: {}", order.getId());
        
        // Validate order exists
        Optional<Order> existingOrder = orderDAO.findById(order.getId());
        if (!existingOrder.isPresent()) {
            throw new IllegalArgumentException("Order not found with ID: " + order.getId());
        }
        
        return orderDAO.update(order);
    }

    /**
     * Update order status
     */
    public void updateOrderStatus(Long orderId, OrderStatus status) {
        logger.debug("Updating order status: {} to {}", orderId, status);
        
        // Validate order exists
        Optional<Order> existingOrder = orderDAO.findById(orderId);
        if (!existingOrder.isPresent()) {
            throw new IllegalArgumentException("Order not found with ID: " + orderId);
        }
        
        orderDAO.updateStatus(orderId, status);
    }

    /**
     * Cancel order
     */
    public void cancelOrder(Long orderId) {
        logger.debug("Cancelling order: {}", orderId);
        
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (!orderOpt.isPresent()) {
            throw new IllegalArgumentException("Order not found with ID: " + orderId);
        }
        
        Order order = orderOpt.get();
        if (!order.canBeCancelled()) {
            throw new IllegalStateException("Order cannot be cancelled in current status: " + order.getStatus());
        }
        
        orderDAO.updateStatus(orderId, OrderStatus.CANCELLED);
    }

    /**
     * Ship order
     */
    public void shipOrder(Long orderId) {
        logger.debug("Shipping order: {}", orderId);
        
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (!orderOpt.isPresent()) {
            throw new IllegalArgumentException("Order not found with ID: " + orderId);
        }
        
        Order order = orderOpt.get();
        if (!order.canBeShipped()) {
            throw new IllegalStateException("Order cannot be shipped in current status: " + order.getStatus());
        }
        
        order.markAsShipped();
        orderDAO.update(order);
    }

    /**
     * Mark order as delivered
     */
    public void deliverOrder(Long orderId) {
        logger.debug("Delivering order: {}", orderId);
        
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (!orderOpt.isPresent()) {
            throw new IllegalArgumentException("Order not found with ID: " + orderId);
        }
        
        Order order = orderOpt.get();
        if (order.getStatus() != OrderStatus.SHIPPED) {
            throw new IllegalStateException("Order cannot be delivered in current status: " + order.getStatus());
        }
        
        order.markAsDelivered();
        orderDAO.update(order);
    }

    /**
     * Delete order
     */
    public void deleteOrder(Long orderId) {
        logger.debug("Deleting order: {}", orderId);
        
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (!orderOpt.isPresent()) {
            throw new IllegalArgumentException("Order not found with ID: " + orderId);
        }
        
        Order order = orderOpt.get();
        if (order.getStatus() != OrderStatus.PENDING && order.getStatus() != OrderStatus.CANCELLED) {
            throw new IllegalStateException("Only pending or cancelled orders can be deleted");
        }
        
        orderDAO.delete(orderId);
    }

    /**
     * Generate unique order number
     */
    private String generateOrderNumber() {
        return "ORD-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
