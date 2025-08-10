USE StoreDB;
GO

SELECT COUNT(*) AS total_products
FROM production.products;

SELECT 
    AVG(list_price) AS avg_price,
    MIN(list_price) AS min_price,
    MAX(list_price) AS max_price
FROM production.products;

SELECT category_id, COUNT(*) AS product_count
FROM production.products
GROUP BY category_id;

SELECT store_id, COUNT(*) AS order_count
FROM sales.orders
GROUP BY store_id;

SELECT TOP 10 
    UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower
FROM sales.customers;

SELECT TOP 10 
    product_name,
    LEN(product_name) AS name_length
FROM production.products;

SELECT customer_id, first_name, last_name,
       LEFT(phone, 3) AS area_code
FROM sales.customers
WHERE customer_id BETWEEN 1 AND 15;

SELECT TOP 10 
    order_id,
    order_date,
    YEAR(order_date)  [order_year],
    MONTH(order_date)  [order_month],
    GETDATE()  [current_date]
FROM sales.orders;

SELECT TOP 10 
    p.product_name,
    c.category_name
FROM production.products p
JOIN production.categories c 
    ON p.category_id = c.category_id;

SELECT TOP 10 
    c.first_name + ' ' + c.last_name AS customer_name,
    o.order_date
FROM sales.customers c
JOIN sales.orders o 
    ON c.customer_id = o.customer_id;

SELECT 
    p.product_name,
    ISNULL(b.brand_name, 'No Brand') AS brand_name
FROM production.products p
LEFT JOIN production.brands b 
    ON p.brand_id = b.brand_id;

SELECT product_name, list_price
FROM production.products
WHERE list_price > (
    SELECT AVG(list_price) FROM production.products
);

SELECT customer_id, first_name + ' ' + last_name AS customer_name
FROM sales.customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM sales.orders
);

SELECT 
    c.first_name + ' ' + c.last_name AS customer_name,
    (SELECT COUNT(*) 
     FROM sales.orders o 
     WHERE o.customer_id = c.customer_id) AS total_orders
FROM sales.customers c;

go
CREATE VIEW easy_product_list AS
SELECT 
    p.product_name,
    c.category_name,
    p.list_price
FROM production.products p
JOIN production.categories c 
    ON p.category_id = c.category_id;
GO

SELECT * 
FROM easy_product_list
WHERE list_price > 100;

go
CREATE VIEW customer_info AS
SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    email,
    city + ', ' + state AS city_state
FROM sales.customers;
GO

SELECT * 
FROM customer_info
WHERE city_state LIKE '%, CA';

SELECT product_name, list_price
FROM production.products
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price ASC;

SELECT state, COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state
ORDER BY customer_count DESC;

SELECT 
    c.category_name,
    p.product_name,
    p.list_price
FROM production.products p
JOIN production.categories c 
    ON p.category_id = c.category_id
WHERE p.list_price = (
    SELECT MAX(list_price)
    FROM production.products
    WHERE category_id = p.category_id
);

SELECT 
    s.store_name,
    s.city,
    COUNT(o.order_id) AS order_count
FROM sales.stores s
LEFT JOIN sales.orders o 
    ON s.store_id = o.store_id
GROUP BY s.store_name, s.city;
