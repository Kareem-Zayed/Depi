USE StoreDB;
GO

SELECT product_id, product_name, list_price
FROM production.products
WHERE list_price > 1000;


SELECT customer_id, first_name, last_name, state
FROM sales.customers
WHERE state IN ('CA', 'NY');


SELECT order_id, customer_id, order_date
FROM sales.orders
WHERE YEAR(order_date) = 2023;

SELECT customer_id, first_name, last_name, email
FROM sales.customers
WHERE email LIKE '%@gmail.com';

SELECT staff_id, first_name, last_name, active
FROM sales.staffs
WHERE active = 0;

SELECT TOP 5 product_id, product_name, list_price
FROM production.products
ORDER BY list_price DESC;

SELECT TOP 10 order_id, order_date, customer_id
FROM sales.orders
ORDER BY order_date DESC;

SELECT TOP 3 customer_id, first_name, last_name
FROM sales.customers
ORDER BY last_name ASC;

SELECT customer_id, first_name, last_name, phone
FROM sales.customers
WHERE phone IS NULL;

SELECT staff_id, first_name, last_name, manager_id
FROM sales.staffs
WHERE manager_id IS NOT NULL;

SELECT category_id, COUNT(*) AS product_count
FROM production.products
GROUP BY category_id;

SELECT state, COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state;

SELECT brand_id, AVG(list_price) AS avg_price
FROM production.products
GROUP BY brand_id;

SELECT staff_id, COUNT(*) AS order_count
FROM sales.orders
GROUP BY staff_id;

SELECT customer_id, COUNT(order_id) AS total_orders
FROM sales.orders
GROUP BY customer_id
HAVING COUNT(order_id) > 2;

SELECT product_id, product_name, list_price
FROM production.products
WHERE list_price BETWEEN 500 AND 1500;

SELECT customer_id, first_name, last_name, city
FROM sales.customers
WHERE city LIKE 'S%';

SELECT order_id, order_status, order_date
FROM sales.orders
WHERE order_status IN (2, 4);

SELECT product_id, product_name, category_id
FROM production.products
WHERE category_id IN (1, 2, 3);

SELECT staff_id, first_name, last_name, store_id, phone
FROM sales.staffs
WHERE store_id = 1 OR phone IS NULL;
