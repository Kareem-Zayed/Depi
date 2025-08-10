
use StoreDB

DECLARE @CustomerID INT = 1;
DECLARE @TotalSpent DECIMAL(10,2);
DECLARE @Message NVARCHAR(100);

SELECT @TotalSpent = SUM(sales.order_items.list_price * sales.order_items.quantity)
FROM sales.orders
JOIN sales.order_items ON sales.orders.order_id = sales.order_items.order_id
WHERE sales.orders.customer_id = @CustomerID;

SET @Message = CASE 
    WHEN @TotalSpent > 5000 THEN 'VIP Customer - Total Spent: $' + CAST(@TotalSpent AS NVARCHAR(10))
    ELSE 'Regular Customer - Total Spent: $' + CAST(@TotalSpent AS NVARCHAR(10))
END;
PRINT @Message;

DECLARE @ThresholdPrice DECIMAL(10,2) = 1500;
DECLARE @ProductCount INT;

SELECT @ProductCount = COUNT(*)
FROM production.products
WHERE list_price > @ThresholdPrice;

PRINT 'Threshold Price: $' + CAST(@ThresholdPrice AS NVARCHAR(10)) + ', Products Above: ' + CAST(@ProductCount AS NVARCHAR(10));

DECLARE @StaffID INT = 2;
DECLARE @Year INT = 2017;
DECLARE @TotalSales DECIMAL(10,2);

SELECT @TotalSales = SUM(sales.order_items.list_price * sales.order_items.quantity)
FROM sales.staffs
JOIN sales.orders ON sales.staffs.staff_id = sales.orders.staff_id
JOIN sales.order_items ON sales.orders.order_id = sales.order_items.order_id
WHERE sales.staffs.staff_id = @StaffID 
AND YEAR(sales.orders.order_date) = @Year;

PRINT 'Staff ID: ' + CAST(@StaffID AS NVARCHAR(10)) + ', Year: ' + CAST(@Year AS NVARCHAR(10)) + ', Total Sales: $' + CAST(@TotalSales AS NVARCHAR(10));

SELECT 
    @@SERVERNAME AS ServerName,
    @@VERSION AS SqlServerVersion,
    @@ROWCOUNT AS RowsAffected;

DECLARE @ProductID INT = 1;
DECLARE @StoreID INT = 1;
DECLARE @Quantity INT;

SELECT @Quantity = quantity
FROM production.stocks
WHERE product_id = @ProductID AND store_id = @StoreID;

IF @Quantity > 20
    PRINT 'Well stocked';
ELSE IF @Quantity BETWEEN 10 AND 20
    PRINT 'Moderate stock';
ELSE IF @Quantity < 10
    PRINT 'Low stock - reorder needed';

DECLARE @BatchCount INT = 0;
DECLARE @MaxBatch INT = 3;

WHILE EXISTS (SELECT 1 FROM production.stocks WHERE quantity < 5)
BEGIN
    UPDATE TOP (3) production.stocks
    SET quantity = quantity + 10
    WHERE quantity < 5;

    SET @BatchCount = @BatchCount + 1;
    PRINT 'Batch ' + CAST(@BatchCount AS NVARCHAR(10)) + ' completed, added 10 units to 3 products';
    
    IF @BatchCount >= @MaxBatch BREAK;
END;

SELECT 
    product_id,
    product_name,
    list_price,
    CASE 
        WHEN list_price < 300 THEN 'Budget'
        WHEN list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
        WHEN list_price BETWEEN 801 AND 2000 THEN 'Premium'
        WHEN list_price > 2000 THEN 'Luxury'
    END AS price_category
FROM production.products;

DECLARE @CustomersiD INT = 5;
DECLARE @OrderCount INT;

SELECT @OrderCount = COUNT(*)
FROM sales.orders
WHERE customer_id = @CustomerID;

IF @OrderCount > 0
    PRINT 'Customer ID ' + CAST(@CustomerID AS NVARCHAR(10)) + ' exists with ' + CAST(@OrderCount AS NVARCHAR(10)) + ' orders';
ELSE
    PRINT 'Customer ID ' + CAST(@CustomerID AS NVARCHAR(10)) + ' does not exist';

go
CREATE FUNCTION sales.CalculateShipping (@OrderTotal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @ShippingCost DECIMAL(10,2);
    IF @OrderTotal > 100
        SET @ShippingCost = 0.00;
    ELSE IF @OrderTotal BETWEEN 50 AND 99
        SET @ShippingCost = 5.99;
    ELSE
        SET @ShippingCost = 12.99;
    RETURN @ShippingCost;
END;

go
go
CREATE FUNCTION sales.GetProductsByPriceRange (@MinPrice DECIMAL(10,2), @MaxPrice DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
    SELECT 
        p.product_id,
        p.product_name,
        p.list_price,
        b.brand_name,
        c.category_name
    FROM production.products p
    JOIN production.brands b ON p.brand_id = b.brand_id
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE p.list_price BETWEEN @MinPrice AND @MaxPrice;
go
go
CREATE FUNCTION sales.GetCustomerYearlySummary (@CustomerID INT)
RETURNS @Result TABLE (
    Year INT,
    TotalOrders INT,
    TotalSpent DECIMAL(10,2),
    AvgOrderValue DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT 
        YEAR(o.order_date) AS Year,
        COUNT(o.order_id) AS TotalOrders,
        SUM(oi.list_price * oi.quantity) AS TotalSpent,
        AVG(oi.list_price * oi.quantity) AS AvgOrderValue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    GROUP BY YEAR(o.order_date);
    RETURN;
END;
go

go
CREATE FUNCTION sales.CalculateBulkDiscount (@Quantity INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Discount DECIMAL(5,2);
    SET @Discount = CASE 
        WHEN @Quantity BETWEEN 1 AND 2 THEN 0.00
        WHEN @Quantity BETWEEN 3 AND 5 THEN 0.05
        WHEN @Quantity BETWEEN 6 AND 9 THEN 0.10
        WHEN @Quantity >= 10 THEN 0.15
    END;
    RETURN @Discount;
END;
go

CREATE PROCEDURE sales.sp_GetCustomerOrderHistory
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SELECT 
        o.order_id,
        o.order_date,
        SUM(oi.list_price * oi.quantity) AS order_total
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
    AND (@StartDate IS NULL OR o.order_date >= @StartDate)
    AND (@EndDate IS NULL OR o.order_date <= @EndDate)
    GROUP BY o.order_id, o.order_date;
END;

go
CREATE PROCEDURE production.sp_RestockProduct
    @StoreID INT,
    @ProductID INT,
    @RestockQuantity INT,
    @OldQuantity INT OUTPUT,
    @NewQuantity INT OUTPUT,
    @Success BIT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT @OldQuantity = quantity
        FROM production.stocks
        WHERE store_id = @StoreID AND product_id = @ProductID;

        IF @OldQuantity IS NOT NULL
        BEGIN
            UPDATE production.stocks
            SET quantity = quantity + @RestockQuantity
            WHERE store_id = @StoreID AND product_id = @ProductID;

            SET @NewQuantity = @OldQuantity + @RestockQuantity;
            SET @Success = 1;
        END
        ELSE
        BEGIN
            SET @Success = 0;
        END
    END TRY
    BEGIN CATCH
        SET @Success = 0;
    END CATCH;
END;
go

CREATE PROCEDURE sales.sp_ProcessNewOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @StoreID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO sales.orders (customer_id, order_date, store_id, staff_id, order_status)
        VALUES (@CustomerID, GETDATE(), @StoreID, 1, 1);

        DECLARE @OrderID INT = SCOPE_IDENTITY();
        INSERT INTO sales.order_items (order_id, product_id, quantity, list_price, discount)
        VALUES (@OrderID, @ProductID, @Quantity, (SELECT list_price FROM production.products WHERE product_id = @ProductID), 0);

        UPDATE production.stocks
        SET quantity = quantity - @Quantity
        WHERE store_id = @StoreID AND product_id = @ProductID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
go
go
CREATE PROCEDURE sales.sp_SearchProducts
    @ProductName NVARCHAR(100) = NULL,
    @CategoryID INT = NULL,
    @MinPrice DECIMAL(10,2) = NULL,
    @MaxPrice DECIMAL(10,2) = NULL,
    @SortColumn NVARCHAR(50) = 'list_price'
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX) = 'SELECT p.product_id, p.product_name, p.list_price, c.category_name, b.brand_name 
                                 FROM sales.products p 
                                 JOIN sales.categories c ON p.category_id = c.category_id 
                                 JOIN sales.brands b ON p.brand_id = b.brand_id 
                                 WHERE 1=1';

    IF @ProductName IS NOT NULL
        SET @SQL = @SQL + ' AND p.product_name LIKE ''%' + @ProductName + '%''';
    IF @CategoryID IS NOT NULL
        SET @SQL = @SQL + ' AND p.category_id = ' + CAST(@CategoryID AS NVARCHAR(10));
    IF @MinPrice IS NOT NULL
        SET @SQL = @SQL + ' AND p.list_price >= ' + CAST(@MinPrice AS NVARCHAR(10));
    IF @MaxPrice IS NOT NULL
        SET @SQL = @SQL + ' AND p.list_price <= ' + CAST(@MaxPrice AS NVARCHAR(10));
    SET @SQL = @SQL + ' ORDER BY ' + QUOTENAME(@SortColumn) + ' DESC';

    EXEC sp_executesql @SQL;
END;

DECLARE @StartDate DATE = '2017-01-01';
DECLARE @EndDate DATE = '2017-03-31';
DECLARE @BonusRateLow DECIMAL(5,2) = 0.02;
DECLARE @BonusRateHigh DECIMAL(5,2) = 0.05;

SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    SUM(oi.list_price * oi.quantity) AS quarterly_sales,
    CASE 
        WHEN SUM(oi.list_price * oi.quantity) > 10000 THEN @BonusRateHigh * SUM(oi.list_price * oi.quantity)
        ELSE @BonusRateLow * SUM(oi.list_price * oi.quantity)
    END AS bonus_amount
FROM sales.staffs s
JOIN sales.orders o ON s.staff_id = o.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_date BETWEEN @StartDate AND @EndDate
GROUP BY s.staff_id, s.first_name, s.last_name;

SELECT 
    p.product_id,
    p.product_name,
    s.quantity,
    CASE 
        WHEN s.quantity < 10 THEN 
            CASE c.category_name
                WHEN 'Electronics' THEN 50
                ELSE 20
            END
        WHEN s.quantity < 20 THEN 
            CASE c.category_name
                WHEN 'Electronics' THEN 30
                ELSE 10
            END
        ELSE 0
    END AS reorder_quantity
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
JOIN production.categories c ON p.category_id = c.category_id;

WITH CustomerSpending AS (
    SELECT 
        c.customer_id,
        COALESCE(SUM(oi.list_price * oi.quantity), 0) AS total_spent
    FROM sales.customers c
    LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    cs.total_spent,
    CASE 
        WHEN cs.total_spent > 10000 THEN 'Platinum'
        WHEN cs.total_spent > 5000 THEN 'Gold'
        WHEN cs.total_spent > 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_tier
FROM sales.customers c
JOIN CustomerSpending cs ON c.customer_id = cs.customer_id;

go
CREATE PROCEDURE sales.sp_DiscontinueProduct
    @ProductID INT,
    @ReplacementProductID INT = NULL
AS
BEGIN
    DECLARE @PendingOrders INT;
    SELECT @PendingOrders = COUNT(*)
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE oi.product_id = @ProductID AND o.order_status IN (1, 2);

    IF @PendingOrders > 0
    BEGIN
        IF @ReplacementProductID IS NOT NULL
        BEGIN
            UPDATE sales.order_items
            SET product_id = @ReplacementProductID
            WHERE product_id = @ProductID AND order_id IN (
                SELECT order_id FROM sales.orders WHERE order_status IN (1, 2)
            );
            PRINT 'Replaced ' + CAST(@PendingOrders AS NVARCHAR(10)) + ' pending orders with replacement product.';
        END
        ELSE
        BEGIN
            PRINT 'Cannot discontinue product with ' + CAST(@PendingOrders AS NVARCHAR(10)) + ' pending orders.';
            RETURN;
        END
    END

    UPDATE production.stocks
    SET quantity = 0
    WHERE product_id = @ProductID;

    PRINT 'Product ' + CAST(@ProductID AS NVARCHAR(10)) + ' discontinued successfully.';
END;

WITH MonthlySales AS (
    SELECT 
        YEAR(o.order_date) AS sale_year,
        MONTH(o.order_date) AS sale_month,
        s.staff_id,
        p.category_id,
        SUM(oi.list_price * oi.quantity) AS monthly_total
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN sales.staffs s ON o.staff_id = s.staff_id
    JOIN production.products p ON oi.product_id = p.product_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date), s.staff_id, p.category_id
),
StaffPerformance AS (
    SELECT 
        staff_id,
        SUM(monthly_total) AS staff_total
    FROM MonthlySales
    GROUP BY staff_id
),
CategoryPerformance AS (
    SELECT 
        category_id,
        SUM(monthly_total) AS category_total
    FROM MonthlySales
    GROUP BY category_id
)
SELECT 
    ms.sale_year,
    ms.sale_month,
    s.first_name + ' ' + s.last_name AS staff_name,
    c.category_name,
    ms.monthly_total,
    sp.staff_total AS staff_quota,
    cp.category_total AS category_quota,
    RANK() OVER (PARTITION BY ms.sale_year, ms.sale_month ORDER BY ms.monthly_total DESC) AS sales_rank
FROM MonthlySales ms
JOIN sales.staffs s ON ms.staff_id = s.staff_id
JOIN production.categories c ON ms.category_id = c.category_id
JOIN StaffPerformance sp ON ms.staff_id = sp.staff_id
JOIN CategoryPerformance cp ON ms.category_id = cp.category_id
ORDER BY ms.sale_year, ms.sale_month, ms.monthly_total DESC;

go
CREATE FUNCTION sales.fn_ValidateCustomer (@CustomerID INT)
RETURNS BIT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM sales.customers WHERE customer_id = @CustomerID);
END;
go

GO
CREATE FUNCTION sales.fn_ValidateInventory 
(
    @ProductID INT, 
    @StoreID INT, 
    @Quantity INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @AvailableQuantity INT;
    DECLARE @Result BIT;

    SELECT @AvailableQuantity = quantity
    FROM production.stocks
    WHERE product_id = @ProductID AND store_id = @StoreID;

    SET @Result = CASE 
                    WHEN @AvailableQuantity >= @Quantity THEN 1 
                    ELSE 0 
                  END;

    RETURN @Result;
END;
GO

go
CREATE PROCEDURE sales.sp_ValidateAndInsertOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT,
    @StoreID INT
AS
BEGIN
    IF sales.fn_ValidateCustomer(@CustomerID) = 0
    BEGIN
        RAISERROR ('Invalid customer ID', 16, 1);
        RETURN;
    END

    IF sales.fn_ValidateInventory(@ProductID, @StoreID, @Quantity) = 0
    BEGIN
        RAISERROR ('Insufficient inventory', 16, 1);
        RETURN;
    END
	

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO sales.orders (customer_id, order_date, store_id, staff_id, order_status)
        VALUES (@CustomerID, GETDATE(), @StoreID, 1, 1);
        DECLARE @OrderID INT = SCOPE_IDENTITY();
        INSERT INTO sales.order_items (order_id, product_id, quantity, list_price, discount)
        VALUES (@OrderID, @ProductID, @Quantity, (SELECT list_price FROM production.products WHERE product_id = @ProductID), 0);
        UPDATE production.stocks
        SET quantity = quantity - @Quantity
        WHERE store_id = @StoreID AND product_id = @ProductID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;