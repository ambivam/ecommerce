package com.ecommerce.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database connection utility using HikariCP connection pooling
 */
public class DatabaseConnection {
    private static final Logger logger = LoggerFactory.getLogger(DatabaseConnection.class);
    private static HikariDataSource dataSource;
    private static final Object lock = new Object();

    static {
        initializeDataSource();
    }

    private static void initializeDataSource() {
        try {
            Properties props = loadDatabaseProperties();
            
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("db.url", "jdbc:postgresql://localhost:5432/ecommerce"));
            config.setUsername(props.getProperty("db.username", "postgres"));
            config.setPassword(props.getProperty("db.password", "password"));
            config.setDriverClassName("org.postgresql.Driver");
            
            // Connection pool settings
            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("db.pool.maxSize", "20")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("db.pool.minIdle", "5")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("db.pool.connectionTimeout", "30000")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("db.pool.idleTimeout", "600000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("db.pool.maxLifetime", "1800000")));
            
            // Connection validation
            config.setConnectionTestQuery("SELECT 1");
            config.setValidationTimeout(5000);
            
            // Pool name for monitoring
            config.setPoolName("ECommercePool");
            
            dataSource = new HikariDataSource(config);
            
            logger.info("Database connection pool initialized successfully");
            
        } catch (Exception e) {
            logger.error("Failed to initialize database connection pool", e);
            throw new RuntimeException("Database initialization failed", e);
        }
    }

    private static Properties loadDatabaseProperties() {
        Properties props = new Properties();
        
        // Try to load from application.properties
        try (InputStream is = DatabaseConnection.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (is != null) {
                props.load(is);
                logger.info("Loaded database properties from application.properties");
            } else {
                logger.warn("application.properties not found, using default values");
            }
        } catch (IOException e) {
            logger.warn("Could not load application.properties, using default values", e);
        }
        
        return props;
    }

    /**
     * Get a connection from the pool
     * @return Database connection
     * @throws SQLException if connection cannot be obtained
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            synchronized (lock) {
                if (dataSource == null) {
                    initializeDataSource();
                }
            }
        }
        
        return dataSource.getConnection();
    }

    /**
     * Get the data source
     * @return HikariDataSource instance
     */
    public static DataSource getDataSource() {
        if (dataSource == null) {
            synchronized (lock) {
                if (dataSource == null) {
                    initializeDataSource();
                }
            }
        }
        return dataSource;
    }

    /**
     * Close the data source and all connections
     */
    public static void closeDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            logger.info("Database connection pool closed");
        }
    }

    /**
     * Test database connectivity
     * @return true if connection is successful
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            logger.error("Database connection test failed", e);
            return false;
        }
    }

    /**
     * Get connection pool statistics
     * @return Pool statistics as string
     */
    public static String getPoolStats() {
        if (dataSource != null) {
            return String.format(
                "Pool Stats - Active: %d, Idle: %d, Total: %d, Waiting: %d",
                dataSource.getHikariPoolMXBean().getActiveConnections(),
                dataSource.getHikariPoolMXBean().getIdleConnections(),
                dataSource.getHikariPoolMXBean().getTotalConnections(),
                dataSource.getHikariPoolMXBean().getThreadsAwaitingConnection()
            );
        }
        return "Pool not initialized";
    }
}
