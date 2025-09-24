package com.ecommerce.provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

/**
 * Global exception mapper for handling uncaught exceptions
 */
@Provider
public class ExceptionMapper implements javax.ws.rs.ext.ExceptionMapper<Exception> {
    private static final Logger logger = LoggerFactory.getLogger(ExceptionMapper.class);

    @Override
    public Response toResponse(Exception exception) {
        logger.error("Unhandled exception occurred", exception);
        
        // Handle different types of exceptions
        if (exception instanceof IllegalArgumentException) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + exception.getMessage() + "\"}")
                    .type(MediaType.APPLICATION_JSON)
                    .build();
        }
        
        if (exception instanceof SecurityException) {
            return Response.status(Response.Status.FORBIDDEN)
                    .entity("{\"error\":\"Access denied\"}")
                    .type(MediaType.APPLICATION_JSON)
                    .build();
        }
        
        // Default to internal server error
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity("{\"error\":\"An internal server error occurred\"}")
                .type(MediaType.APPLICATION_JSON)
                .build();
    }
}
