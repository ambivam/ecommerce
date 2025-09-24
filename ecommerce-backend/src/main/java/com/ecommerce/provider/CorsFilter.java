package com.ecommerce.provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;
import java.io.IOException;

/**
 * CORS filter to handle cross-origin requests from ASP.NET frontend
 */
@Provider
public class CorsFilter implements ContainerResponseFilter {
    private static final Logger logger = LoggerFactory.getLogger(CorsFilter.class);

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        // Allow requests from ASP.NET frontend (adjust URL as needed)
        responseContext.getHeaders().add("Access-Control-Allow-Origin", "*");
        responseContext.getHeaders().add("Access-Control-Allow-Credentials", "true");
        responseContext.getHeaders().add("Access-Control-Allow-Headers", 
            "origin, content-type, accept, authorization, x-requested-with");
        responseContext.getHeaders().add("Access-Control-Allow-Methods", 
            "GET, POST, PUT, DELETE, OPTIONS, HEAD");
        responseContext.getHeaders().add("Access-Control-Max-Age", "3600");
        
        logger.debug("CORS headers added to response for: {}", requestContext.getUriInfo().getPath());
    }
}
