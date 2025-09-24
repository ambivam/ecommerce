package com.ecommerce.model;

/**
 * Enumeration for order status values
 */
public enum OrderStatus {
    PENDING("Pending"),
    CONFIRMED("Confirmed"),
    PROCESSING("Processing"),
    SHIPPED("Shipped"),
    DELIVERED("Delivered"),
    CANCELLED("Cancelled");

    private final String displayName;

    OrderStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }

    public static OrderStatus fromString(String status) {
        if (status == null) {
            return PENDING;
        }
        
        for (OrderStatus orderStatus : OrderStatus.values()) {
            if (orderStatus.name().equalsIgnoreCase(status) || 
                orderStatus.displayName.equalsIgnoreCase(status)) {
                return orderStatus;
            }
        }
        
        throw new IllegalArgumentException("Invalid order status: " + status);
    }
}
