package com.ecommerce.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Payment entity representing payment information for orders
 */
public class Payment {
    private Long id;
    private Long orderId;
    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private BigDecimal amount;
    private String transactionId;
    private LocalDateTime paymentDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Default constructor
    public Payment() {
        this.paymentStatus = PaymentStatus.PENDING;
        this.paymentDate = LocalDateTime.now();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // Constructor with essential fields
    public Payment(Long orderId, PaymentMethod paymentMethod, BigDecimal amount) {
        this();
        this.orderId = orderId;
        this.paymentMethod = paymentMethod;
        this.amount = amount;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public PaymentMethod getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(PaymentMethod paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public PaymentStatus getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(PaymentStatus paymentStatus) {
        this.paymentStatus = paymentStatus;
        this.updatedAt = LocalDateTime.now();
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
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

    // Business methods
    public boolean isCompleted() {
        return paymentStatus == PaymentStatus.COMPLETED;
    }

    public boolean isPending() {
        return paymentStatus == PaymentStatus.PENDING;
    }

    public boolean isFailed() {
        return paymentStatus == PaymentStatus.FAILED;
    }

    public boolean isRefunded() {
        return paymentStatus == PaymentStatus.REFUNDED;
    }

    public void markAsCompleted(String transactionId) {
        this.paymentStatus = PaymentStatus.COMPLETED;
        this.transactionId = transactionId;
        this.paymentDate = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void markAsFailed() {
        this.paymentStatus = PaymentStatus.FAILED;
        this.updatedAt = LocalDateTime.now();
    }

    public void markAsRefunded() {
        if (isCompleted()) {
            this.paymentStatus = PaymentStatus.REFUNDED;
            this.updatedAt = LocalDateTime.now();
        } else {
            throw new IllegalStateException("Cannot refund a payment that is not completed");
        }
    }

    @Override
    public String toString() {
        return "Payment{" +
                "id=" + id +
                ", orderId=" + orderId +
                ", paymentMethod=" + paymentMethod +
                ", paymentStatus=" + paymentStatus +
                ", amount=" + amount +
                ", transactionId='" + transactionId + '\'' +
                ", paymentDate=" + paymentDate +
                '}';
    }
}
