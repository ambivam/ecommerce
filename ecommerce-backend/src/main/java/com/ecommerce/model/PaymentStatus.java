package com.ecommerce.model;

/**
 * Enumeration for payment status values
 */
public enum PaymentStatus {
    PENDING("Pending"),
    COMPLETED("Completed"),
    FAILED("Failed"),
    REFUNDED("Refunded");

    private final String displayName;

    PaymentStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }

    public static PaymentStatus fromString(String status) {
        if (status == null) {
            return PENDING;
        }
        
        for (PaymentStatus paymentStatus : PaymentStatus.values()) {
            if (paymentStatus.name().equalsIgnoreCase(status) || 
                paymentStatus.displayName.equalsIgnoreCase(status)) {
                return paymentStatus;
            }
        }
        
        throw new IllegalArgumentException("Invalid payment status: " + status);
    }
}
