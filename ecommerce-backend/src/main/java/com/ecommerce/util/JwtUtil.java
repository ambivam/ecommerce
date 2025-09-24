package com.ecommerce.util;

import com.ecommerce.model.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.Properties;

/**
 * JWT utility for token generation and validation
 */
public class JwtUtil {
    private static final Logger logger = LoggerFactory.getLogger(JwtUtil.class);
    
    private final String secretKey;
    private final long expirationTime;
    private final String issuer;

    public JwtUtil() {
        Properties props = loadProperties();
        this.secretKey = props.getProperty("jwt.secret", "mySecretKey123456789012345678901234567890");
        this.expirationTime = Long.parseLong(props.getProperty("jwt.expiration", "86400000")); // 24 hours
        this.issuer = props.getProperty("jwt.issuer", "ecommerce-app");
    }

    private Properties loadProperties() {
        Properties props = new Properties();
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("application.properties")) {
            if (is != null) {
                props.load(is);
            }
        } catch (IOException e) {
            logger.warn("Could not load application.properties, using default JWT settings", e);
        }
        return props;
    }

    /**
     * Generate JWT token for user
     */
    public String generateToken(User user) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expirationTime);

        return Jwts.builder()
                .setSubject(user.getUsername())
                .setIssuer(issuer)
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .claim("userId", user.getId())
                .claim("email", user.getEmail())
                .claim("firstName", user.getFirstName())
                .claim("lastName", user.getLastName())
                .claim("isAdmin", user.isAdmin())
                .signWith(SignatureAlgorithm.HS512, secretKey)
                .compact();
    }

    /**
     * Extract username from token
     */
    public String getUsernameFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims != null ? claims.getSubject() : null;
    }

    /**
     * Extract user ID from token
     */
    public Long getUserIdFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims != null ? claims.get("userId", Long.class) : null;
    }

    /**
     * Extract email from token
     */
    public String getEmailFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims != null ? claims.get("email", String.class) : null;
    }

    /**
     * Check if user is admin from token
     */
    public Boolean isAdminFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims != null ? claims.get("isAdmin", Boolean.class) : false;
    }

    /**
     * Get expiration date from token
     */
    public Date getExpirationDateFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims != null ? claims.getExpiration() : null;
    }

    /**
     * Check if token is expired
     */
    public Boolean isTokenExpired(String token) {
        Date expiration = getExpirationDateFromToken(token);
        return expiration != null && expiration.before(new Date());
    }

    /**
     * Validate token
     */
    public Boolean validateToken(String token, String username) {
        String tokenUsername = getUsernameFromToken(token);
        return (tokenUsername != null && tokenUsername.equals(username) && !isTokenExpired(token));
    }

    /**
     * Validate token without username check
     */
    public Boolean validateToken(String token) {
        try {
            Claims claims = getClaimsFromToken(token);
            return claims != null && !isTokenExpired(token);
        } catch (Exception e) {
            logger.debug("Token validation failed", e);
            return false;
        }
    }

    /**
     * Get expiration time in milliseconds
     */
    public Long getExpirationTime() {
        return expirationTime;
    }

    /**
     * Extract claims from token
     */
    private Claims getClaimsFromToken(String token) {
        try {
            return Jwts.parser()
                    .setSigningKey(secretKey)
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            logger.debug("Failed to parse JWT token", e);
            return null;
        }
    }

    /**
     * Extract token from Authorization header
     */
    public String extractTokenFromHeader(String authorizationHeader) {
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            return authorizationHeader.substring(7);
        }
        return null;
    }
}
