-- Cafe SQL Examples
-- Practice queries using an Orders table

-- Show everything
SELECT * FROM Orders;

-- Show only chosen columns
SELECT drink, price FROM Orders;

-- Filter rows
SELECT * FROM Orders WHERE drink = 'Coffee';

-- Sort lowest to highest price
SELECT * FROM Orders ORDER BY price;

-- Sort highest to lowest price
SELECT * FROM Orders ORDER BY price DESC;

-- Filter and sort together
SELECT * FROM Orders WHERE drink = 'Coffee' ORDER BY price DESC;

-- Count total orders
SELECT COUNT(*) AS total_orders FROM Orders;

-- Get unique drinks
SELECT DISTINCT drink FROM Orders;

-- Get average price
SELECT AVG(price) AS average_price FROM Orders;

-- Get most expensive item
SELECT MAX(price) AS most_expensive FROM Orders;

-- Get cheapest item
SELECT MIN(price) AS cheapest FROM Orders;
