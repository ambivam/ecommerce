package com.ecommerce.model;

/**
 * Enumeration for payment method values
 */
public enum PaymentMethod {
    CREDIT_CARD("Credit Card"),
    DEBIT_CARD("Debit Card"),
    PAYPAL("PayPal"),
    BANK_TRANSFER("Bank Transfer");

    private final String displayName;

    PaymentMethod(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }

    public static PaymentMethod fromString(String method) {
        if (method == null) {
            return CREDIT_CARD;
        }
        
        for (PaymentMethod paymentMethod : PaymentMethod.values()) {
            if (paymentMethod.name().equalsIgnoreCase(method) || 
                paymentMethod.displayName.equalsIgnoreCase(method)) {
                return paymentMethod;
            }
        }
        
        throw new IllegalArgumentException("Invalid payment method: " + method);
    }
}
