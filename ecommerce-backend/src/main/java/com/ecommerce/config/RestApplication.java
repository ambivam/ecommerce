package com.ecommerce.config;

import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;
import java.util.HashSet;
import java.util.Set;

/**
 * JAX-RS Application configuration
 */
@ApplicationPath("/api")
public class RestApplication extends Application {

    @Override
    public Set<Class<?>> getClasses() {
        Set<Class<?>> classes = new HashSet<>();
        
        // Register REST controllers
        classes.add(com.ecommerce.controller.ProductController.class);
        classes.add(com.ecommerce.controller.UserController.class);
        classes.add(com.ecommerce.controller.OrderController.class);
        classes.add(com.ecommerce.controller.CategoryController.class);
        
        // Register providers
        classes.add(com.ecommerce.provider.JacksonProvider.class);
        classes.add(com.ecommerce.provider.CorsFilter.class);
        classes.add(com.ecommerce.provider.ExceptionMapper.class);
        
        return classes;
    }
}
