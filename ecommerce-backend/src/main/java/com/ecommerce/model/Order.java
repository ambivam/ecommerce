package com.ecommerce.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Order entity representing a customer order
 */
public class Order {
    private Long id;
    private Long userId;
    private String orderNumber;
    private OrderStatus status;
    private BigDecimal totalAmount;
    private String shippingAddress;
    private String billingAddress;
    private LocalDateTime orderDate;
    private LocalDateTime shippedDate;
    private LocalDateTime deliveredDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Related entities
    private User user;
    private List<OrderItem> orderItems;
    private Payment payment;

    // Default constructor
    public Order() {
        this.status = OrderStatus.PENDING;
        this.orderDate = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor with essential fields
    public Order(Long userId, String orderNumber, BigDecimal totalAmount, String shippingAddress, String billingAddress) {
        this();
        this.userId = userId;
        this.orderNumber = orderNumber;
        this.totalAmount = totalAmount;
        this.shippingAddress = shippingAddress;
        this.billingAddress = billingAddress;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getOrderNumber() {
        return orderNumber;
    }

    public void setOrderNumber(String orderNumber) {
        this.orderNumber = orderNumber;
    }

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getBillingAddress() {
        return billingAddress;
    }

    public void setBillingAddress(String billingAddress) {
        this.billingAddress = billingAddress;
    }

    public LocalDateTime getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(LocalDateTime orderDate) {
        this.orderDate = orderDate;
    }

    public LocalDateTime getShippedDate() {
        return shippedDate;
    }

    public void setShippedDate(LocalDateTime shippedDate) {
        this.shippedDate = shippedDate;
    }

    public LocalDateTime getDeliveredDate() {
        return deliveredDate;
    }

    public void setDeliveredDate(LocalDateTime deliveredDate) {
        this.deliveredDate = deliveredDate;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public List<OrderItem> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<OrderItem> orderItems) {
        this.orderItems = orderItems;
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    // Business methods
    public boolean canBeCancelled() {
        return status == OrderStatus.PENDING || status == OrderStatus.CONFIRMED;
    }

    public boolean canBeShipped() {
        return status == OrderStatus.CONFIRMED || status == OrderStatus.PROCESSING;
    }

    public boolean isCompleted() {
        return status == OrderStatus.DELIVERED;
    }

    public void markAsShipped() {
        if (canBeShipped()) {
            this.status = OrderStatus.SHIPPED;
            this.shippedDate = LocalDateTime.now();
            this.updatedAt = LocalDateTime.now();
        } else {
            throw new IllegalStateException("Order cannot be shipped in current status: " + status);
        }
    }

    public void markAsDelivered() {
        if (status == OrderStatus.SHIPPED) {
            this.status = OrderStatus.DELIVERED;
            this.deliveredDate = LocalDateTime.now();
            this.updatedAt = LocalDateTime.now();
        } else {
            throw new IllegalStateException("Order cannot be delivered in current status: " + status);
        }
    }

    public void cancel() {
        if (canBeCancelled()) {
            this.status = OrderStatus.CANCELLED;
            this.updatedAt = LocalDateTime.now();
        } else {
            throw new IllegalStateException("Order cannot be cancelled in current status: " + status);
        }
    }

    @Override
    public String toString() {
        return "Order{" +
                "id=" + id +
                ", userId=" + userId +
                ", orderNumber='" + orderNumber + '\'' +
                ", status=" + status +
                ", totalAmount=" + totalAmount +
                ", orderDate=" + orderDate +
                '}';
    }
}
