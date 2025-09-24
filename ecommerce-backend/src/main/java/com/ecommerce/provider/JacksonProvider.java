package com.ecommerce.provider;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import javax.ws.rs.ext.ContextResolver;
import javax.ws.rs.ext.Provider;

/**
 * Jackson JSON provider configuration
 */
@Provider
public class JacksonProvider implements ContextResolver<ObjectMapper> {

    private final ObjectMapper objectMapper;

    public JacksonProvider() {
        objectMapper = new ObjectMapper();
        
        // Register Java 8 time module for LocalDateTime support
        objectMapper.registerModule(new JavaTimeModule());
        
        // Disable writing dates as timestamps
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        
        // Configure other settings
        objectMapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false);
    }

    @Override
    public ObjectMapper getContext(Class<?> type) {
        return objectMapper;
    }
}
