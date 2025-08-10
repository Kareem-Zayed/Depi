SELECT 
    product_id,
    product_name,
    list_price,
    CASE 
        WHEN list_price < 300 THEN 'Economy'
        WHEN list_price BETWEEN 300 AND 999 THEN 'Standard'
        WHEN list_price BETWEEN 1000 AND 2499 THEN 'Premium'
        WHEN list_price >= 2500 THEN 'Luxury'
    END AS price_category
FROM production.products;

SELECT 
    order_id,
    order_date,
    customer_id,
    CASE order_status
        WHEN 1 THEN 'Order Received'
        WHEN 2 THEN 'In Preparation'
        WHEN 3 THEN 'Order Cancelled'
        WHEN 4 THEN 'Order Delivered'
    END AS status_description,
    CASE 
        WHEN order_status = 1 AND DATEDIFF(day, order_date, GETDATE()) > 5 THEN 'URGENT'
        WHEN order_status = 2 AND DATEDIFF(day, order_date, GETDATE()) > 3 THEN 'HIGH'
        ELSE 'NORMAL'
    END AS priority_level
FROM sales.orders;

SELECT 
    
    first_name,
    last_name,
    COUNT(order_id) as order_count,
    CASE 
        WHEN COUNT(order_id) = 0 THEN 'New Staff'
        WHEN COUNT(order_id) BETWEEN 1 AND 10 THEN 'Junior Staff'
        WHEN COUNT(order_id) BETWEEN 11 AND 25 THEN 'Senior Staff'
        WHEN COUNT(order_id) >= 26 THEN 'Expert Staff'
    END AS staff_category
FROM sales.staffs s
LEFT JOIN sales.orders o ON s.staff_id = o.staff_id
GROUP BY  first_name, last_name;

SELECT 
    customer_id,
    first_name,
    last_name,
    ISNULL(phone, 'Phone Not Available') AS phone,
    COALESCE(phone, email, 'No Contact Method') AS preferred_contact,
    email,
    street,
    city,
    state,
    zip_code
FROM sales.customers;

SELECT 
    p.product_id,
    p.product_name,
    s.quantity,
    CASE 
        WHEN s.quantity > 0 THEN CAST(NULLIF(s.quantity, 0) AS FLOAT) / NULLIF(s.quantity, 0)
        ELSE ISNULL(NULLIF(s.quantity, 0), 0)
    END AS price_per_unit,
    CASE 
        WHEN s.quantity > 0 THEN 'In Stock'
        WHEN s.quantity = 0 THEN 'Out of Stock'
        ELSE 'No Stock Data'
    END AS stock_status
FROM production.products p
LEFT JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.store_id = 1;

SELECT 
    store_id,
    COALESCE(store_name, 'Unknown Store') AS store_name,
    COALESCE(email, 'No Email') AS email,
    COALESCE(street, 'No Street') AS street,
    COALESCE(city, 'No City') AS city,
    COALESCE(state, 'No State') AS state,
    COALESCE(zip_code, '') AS zip_code,
    COALESCE(store_name + ', ' + email + ', ' + street + ', ' + city + ', ' + state + ' ' + zip_code, 
             'Incomplete Address') AS formatted_address
FROM sales.stores;

WITH CustomerSpending AS (
    SELECT 
        customer_id,
        SUM(oi.list_price * oi.quantity) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY customer_id
    HAVING SUM(oi.list_price * oi.quantity) > 1500
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    cs.total_spent
FROM sales.customers c
JOIN CustomerSpending cs ON c.customer_id = cs.customer_id
ORDER BY cs.total_spent DESC;

WITH CategoryRevenue AS (
    SELECT 
        c.category_id,
        c.category_name,
        SUM(oi.list_price * oi.quantity) AS total_revenue
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
),
CategoryAvgOrder AS (
    SELECT 
        c.category_id,
        c.category_name,
        AVG(oi.list_price * oi.quantity) AS avg_order_value
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
)
SELECT 
    cr.category_name,
    cr.total_revenue,
    ca.avg_order_value,
    CASE 
        WHEN cr.total_revenue > 50000 THEN 'Excellent'
        WHEN cr.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_rating
FROM CategoryRevenue cr
JOIN CategoryAvgOrder ca ON cr.category_id = ca.category_id;

WITH MonthlySales AS (
    SELECT 
        YEAR(order_date) AS sale_year,
        MONTH(order_date) AS sale_month,
        SUM(oi.list_price * oi.quantity) AS monthly_total
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY YEAR(order_date), MONTH(order_date)
),
MonthlyComparison AS (
    SELECT 
        ms.sale_year,
        ms.sale_month,
        ms.monthly_total,
        LAG(ms.monthly_total) OVER (ORDER BY ms.sale_year, ms.sale_month) AS prev_month_total
    FROM MonthlySales ms
)
SELECT 
    sale_year,
    sale_month,
    monthly_total,
    prev_month_total,
    CASE 
        WHEN prev_month_total IS NOT NULL AND prev_month_total != 0 
        THEN ROUND((monthly_total - prev_month_total) * 100.0 / prev_month_total, 2)
        ELSE 0
    END AS growth_percentage
FROM MonthlyComparison;

WITH RankedProducts AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category_id,
        p.list_price,
        ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS row_num,
        RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS rank_num,
        DENSE_RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS dense_rank
    FROM production.products p
)
SELECT 
    product_id,
    product_name,
    category_id,
    list_price,
    row_num,
    rank_num,
    dense_rank
FROM RankedProducts
WHERE row_num <= 3;

WITH CustomerSpending AS (
    SELECT 
        customer_id,
        SUM(oi.list_price * oi.quantity) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY customer_id
),
RankedCustomers AS (
    SELECT 
        customer_id,
        total_spent,
        RANK() OVER (ORDER BY total_spent DESC) AS customer_rank,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS spending_group
    FROM CustomerSpending
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    rc.total_spent,
    rc.customer_rank,
    rc.spending_group,
    CASE rc.spending_group
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
        ELSE 'Standard'
    END AS spending_tier
FROM sales.customers c
JOIN RankedCustomers rc ON c.customer_id = rc.customer_id;

WITH StoreRevenue AS (
    SELECT 
        s.store_id,
        s.store_name,
        SUM(oi.list_price * oi.quantity) AS total_revenue,
        COUNT(o.order_id) AS order_count
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
),
RankedStores AS (
    SELECT 
        store_id,
        store_name,
        total_revenue,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        order_count,
        RANK() OVER (ORDER BY order_count DESC) AS order_rank,
        PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_percentile
    FROM StoreRevenue
)
SELECT 
    store_id,
    store_name,
    total_revenue,
    revenue_rank,
    order_count,
    order_rank,
    revenue_percentile
FROM RankedStores;

SELECT *
FROM (
    SELECT c.category_name, b.brand_name, p.product_id
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN production.brands b ON p.brand_id = b.brand_id
) AS SourceTable
PIVOT (
    COUNT(product_id)
    FOR brand_name IN (Electra, Haro, Trek, Surly)
) AS PivotTable;

SELECT *
FROM (
    SELECT 
        s.store_name,
        MONTH(o.order_date) AS sale_month,
        SUM(oi.list_price * oi.quantity) AS total_revenue
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_name, MONTH(o.order_date)
) AS SourceTable
PIVOT (
    SUM(total_revenue)
    FOR sale_month IN (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)
) AS PivotTable;

SELECT *
FROM (
    SELECT 
        s.store_name,
        CASE o.order_status
            WHEN 1 THEN 'Pending'
            WHEN 2 THEN 'Processing'
            WHEN 3 THEN 'Completed'
            WHEN 4 THEN 'Rejected'
        END AS order_status,
        COUNT(o.order_id) AS order_count
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    GROUP BY s.store_name, o.order_status
) AS SourceTable
PIVOT (
    SUM(order_count)
    FOR order_status IN (Pending, Processing, Completed, Rejected)
) AS PivotTable;

SELECT *
FROM (
    SELECT 
        b.brand_name,
        YEAR(o.order_date) AS sale_year,
        SUM(oi.list_price * oi.quantity) AS total_revenue
    FROM production.brands b
    JOIN production.products p ON b.brand_id = p.brand_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    JOIN sales.orders o ON oi.order_id = o.order_id
    GROUP BY b.brand_name, YEAR(o.order_date)
) AS SourceTable
PIVOT (
    SUM(total_revenue)
    FOR sale_year IN ([2016], [2017], [2018])
) AS PivotTable;

SELECT 'In-Stock' AS status,  product_name, quantity
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0
UNION
SELECT 'Out-of-Stock' AS status,  product_name, quantity
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL
UNION
SELECT 'Discontinued' AS status, product_id, product_name, NULL AS quantity
FROM production.products p
WHERE p.product_id NOT IN (SELECT product_id FROM production.stocks);

SELECT customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2017
INTERSECT
SELECT customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2018;

(SELECT 'Available in All Stores' AS label, p.product_id, p.product_name
FROM production.products p
JOIN production.stocks s1 ON p.product_id = s1.product_id AND s1.store_id = 1
JOIN production.stocks s2 ON p.product_id = s2.product_id AND s2.store_id = 2
JOIN production.stocks s3 ON p.product_id = s3.product_id AND s3.store_id = 3)
INTERSECT
(SELECT 'Store 1 Exclusive' AS label, p.product_id, p.product_name
FROM production.products p
JOIN production.stocks s1 ON p.product_id = s1.product_id AND s1.store_id = 1
EXCEPT
SELECT 'Store 1 Exclusive' AS label, p.product_id, p.product_name
FROM production.products p
JOIN production.stocks s2 ON p.product_id = s2.product_id AND s2.store_id = 2)
UNION
SELECT 'Combined Results' AS label, product_id, product_name
FROM production.products;

SELECT 'Lost Customers' AS customer_type, customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2016
EXCEPT
SELECT 'Lost Customers' AS customer_type, customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2017
UNION ALL
SELECT 'New Customers' AS customer_type, customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2017
EXCEPT
SELECT 'New Customers' AS customer_type, customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2016
UNION ALL
SELECT 'Retained Customers' AS customer_type, customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2016
INTERSECT
SELECT 'Retained Customers' AS customer_type, customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2017;