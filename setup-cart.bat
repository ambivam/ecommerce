@echo off
echo === Setting up Shopping Cart Database ===

echo.
echo 1. Creating cart table in PostgreSQL...
psql -U postgres -h localhost -d ecommerce -f "database/cart_schema.sql"

if %errorlevel%==0 (
    echo ✅ Cart table created successfully!
) else (
    echo ❌ Failed to create cart table. Please check PostgreSQL connection.
    pause
    exit /b 1
)

echo.
echo 2. Verifying cart table...
psql -U postgres -h localhost -d ecommerce -c "\dt cart"

echo.
echo === Cart Setup Complete! ===
echo.
echo Next steps:
echo 1. Restart your Java backend: mvn tomcat7:run
echo 2. Test the cart functionality at: http://localhost/ecommerce-ui/ProductsWorking.aspx
echo.
pause
