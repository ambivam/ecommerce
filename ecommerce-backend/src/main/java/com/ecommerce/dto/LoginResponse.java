package com.ecommerce.dto;

import com.ecommerce.model.User;

/**
 * Data Transfer Object for login responses
 */
public class LoginResponse {
    private String token;
    private String tokenType;
    private Long expiresIn;
    private User user;

    // Default constructor
    public LoginResponse() {
        this.tokenType = "Bearer";
    }

    // Constructor
    public LoginResponse(String token, Long expiresIn, User user) {
        this();
        this.token = token;
        this.expiresIn = expiresIn;
        this.user = user;
    }

    // Getters and Setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public Long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(Long expiresIn) {
        this.expiresIn = expiresIn;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @Override
    public String toString() {
        return "LoginResponse{" +
                "tokenType='" + tokenType + '\'' +
                ", expiresIn=" + expiresIn +
                ", user=" + (user != null ? user.getUsername() : "null") +
                '}';
    }
}
