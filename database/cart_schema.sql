-- Shopping Cart Tables for TechMart E-Commerce Application

-- Cart table to store user shopping carts
CREATE TABLE IF NOT EXISTS cart (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicate cart items for same user
    CONSTRAINT uk_cart_user_product UNIQUE (user_id, product_id),
    
    -- Check constraints
    CONSTRAINT chk_cart_quantity CHECK (quantity > 0),
    CONSTRAINT chk_cart_price CHECK (price >= 0)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_cart_user_id ON cart(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_product_id ON cart(product_id);

-- Update trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_cart_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cart_updated_at
    BEFORE UPDATE ON cart
    FOR EACH ROW
    EXECUTE FUNCTION update_cart_updated_at();

-- Insert some sample cart data (optional)
-- INSERT INTO cart (user_id, product_id, quantity, price) VALUES
-- (1, 1, 2, 999.99),  -- User 1 has 2 laptops
-- (1, 2, 1, 699.99),  -- User 1 has 1 smartphone
-- (2, 3, 3, 19.99);   -- User 2 has 3 t-shirts

COMMENT ON TABLE cart IS 'Shopping cart items for users';
COMMENT ON COLUMN cart.user_id IS 'Reference to the user who owns this cart item';
COMMENT ON COLUMN cart.product_id IS 'Reference to the product in the cart';
COMMENT ON COLUMN cart.quantity IS 'Number of items of this product in cart';
COMMENT ON COLUMN cart.price IS 'Price per item when added to cart (for price history)';
