package com.ecommerce.dao;

import com.ecommerce.model.Order;
import com.ecommerce.model.OrderStatus;
import com.ecommerce.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for Order entity
 */
public class OrderDAO {
    private static final Logger logger = LoggerFactory.getLogger(OrderDAO.class);

    private static final String INSERT_ORDER = 
        "INSERT INTO orders (user_id, order_number, status, total_amount, shipping_address, billing_address, order_date) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SELECT_ORDER_BY_ID = 
        "SELECT o.*, u.email as user_email FROM orders o " +
        "LEFT JOIN users u ON o.user_id = u.id WHERE o.id = ?";

    private static final String SELECT_ALL_ORDERS = 
        "SELECT o.*, u.email as user_email FROM orders o " +
        "LEFT JOIN users u ON o.user_id = u.id ORDER BY o.order_date DESC";

    private static final String SELECT_ORDERS_BY_USER = 
        "SELECT o.*, u.email as user_email FROM orders o " +
        "LEFT JOIN users u ON o.user_id = u.id WHERE o.user_id = ? ORDER BY o.order_date DESC";

    private static final String SELECT_ORDERS_BY_STATUS = 
        "SELECT o.*, u.email as user_email FROM orders o " +
        "LEFT JOIN users u ON o.user_id = u.id WHERE o.status = ? ORDER BY o.order_date DESC";

    private static final String UPDATE_ORDER = 
        "UPDATE orders SET status = ?, shipping_address = ?, billing_address = ?, shipped_date = ?, delivered_date = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

    private static final String UPDATE_ORDER_STATUS = 
        "UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

    private static final String DELETE_ORDER = 
        "DELETE FROM orders WHERE id = ?";

    /**
     * Create a new order
     */
    public Order save(Order order) {
        logger.debug("Creating new order: {}", order.getOrderNumber());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(INSERT_ORDER, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, order.getUserId());
            stmt.setString(2, order.getOrderNumber());
            stmt.setString(3, order.getStatus().name());
            stmt.setBigDecimal(4, order.getTotalAmount());
            stmt.setString(5, order.getShippingAddress());
            stmt.setString(6, order.getBillingAddress());
            stmt.setTimestamp(7, Timestamp.valueOf(order.getOrderDate()));
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating order failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    order.setId(generatedKeys.getLong(1));
                    logger.debug("Order created with ID: {}", order.getId());
                    return order;
                } else {
                    throw new SQLException("Creating order failed, no ID obtained.");
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating order", e);
            throw new RuntimeException("Failed to create order", e);
        }
    }

    /**
     * Find order by ID
     */
    public Optional<Order> findById(Long id) {
        logger.debug("Finding order by ID: {}", id);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ORDER_BY_ID)) {
            
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToOrder(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding order by ID: {}", id, e);
            throw new RuntimeException("Failed to find order", e);
        }
        
        return Optional.empty();
    }

    /**
     * Find all orders
     */
    public List<Order> findAll() {
        logger.debug("Finding all orders");
        List<Order> orders = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ALL_ORDERS);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                orders.add(mapResultSetToOrder(rs));
            }
        } catch (SQLException e) {
            logger.error("Error finding all orders", e);
            throw new RuntimeException("Failed to find orders", e);
        }
        
        return orders;
    }

    /**
     * Find orders by user ID
     */
    public List<Order> findByUserId(Long userId) {
        logger.debug("Finding orders by user ID: {}", userId);
        List<Order> orders = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ORDERS_BY_USER)) {
            
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapResultSetToOrder(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding orders by user ID: {}", userId, e);
            throw new RuntimeException("Failed to find orders", e);
        }
        
        return orders;
    }

    /**
     * Find orders by status
     */
    public List<Order> findByStatus(OrderStatus status) {
        logger.debug("Finding orders by status: {}", status);
        List<Order> orders = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_ORDERS_BY_STATUS)) {
            
            stmt.setString(1, status.name());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapResultSetToOrder(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding orders by status: {}", status, e);
            throw new RuntimeException("Failed to find orders", e);
        }
        
        return orders;
    }

    /**
     * Update order
     */
    public Order update(Order order) {
        logger.debug("Updating order: {}", order.getId());
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_ORDER)) {
            
            stmt.setString(1, order.getStatus().name());
            stmt.setString(2, order.getShippingAddress());
            stmt.setString(3, order.getBillingAddress());
            stmt.setTimestamp(4, order.getShippedDate() != null ? Timestamp.valueOf(order.getShippedDate()) : null);
            stmt.setTimestamp(5, order.getDeliveredDate() != null ? Timestamp.valueOf(order.getDeliveredDate()) : null);
            stmt.setLong(6, order.getId());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Updating order failed, no rows affected.");
            }
            
            logger.debug("Order updated: {}", order.getId());
            return order;
        } catch (SQLException e) {
            logger.error("Error updating order: {}", order.getId(), e);
            throw new RuntimeException("Failed to update order", e);
        }
    }

    /**
     * Update order status
     */
    public void updateStatus(Long orderId, OrderStatus status) {
        logger.debug("Updating order status: {} to {}", orderId, status);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(UPDATE_ORDER_STATUS)) {
            
            stmt.setString(1, status.name());
            stmt.setLong(2, orderId);
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Updating order status failed, no rows affected.");
            }
            
            logger.debug("Order status updated: {}", orderId);
        } catch (SQLException e) {
            logger.error("Error updating order status: {}", orderId, e);
            throw new RuntimeException("Failed to update order status", e);
        }
    }

    /**
     * Delete order
     */
    public void delete(Long id) {
        logger.debug("Deleting order: {}", id);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(DELETE_ORDER)) {
            
            stmt.setLong(1, id);
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Deleting order failed, no rows affected.");
            }
            
            logger.debug("Order deleted: {}", id);
        } catch (SQLException e) {
            logger.error("Error deleting order: {}", id, e);
            throw new RuntimeException("Failed to delete order", e);
        }
    }

    /**
     * Map ResultSet to Order object
     */
    private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getLong("id"));
        order.setUserId(rs.getLong("user_id"));
        order.setOrderNumber(rs.getString("order_number"));
        order.setStatus(OrderStatus.valueOf(rs.getString("status")));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setBillingAddress(rs.getString("billing_address"));
        order.setOrderDate(rs.getTimestamp("order_date").toLocalDateTime());
        
        Timestamp shippedDate = rs.getTimestamp("shipped_date");
        if (shippedDate != null) {
            order.setShippedDate(shippedDate.toLocalDateTime());
        }
        
        Timestamp deliveredDate = rs.getTimestamp("delivered_date");
        if (deliveredDate != null) {
            order.setDeliveredDate(deliveredDate.toLocalDateTime());
        }
        
        order.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        order.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        
        return order;
    }
}
