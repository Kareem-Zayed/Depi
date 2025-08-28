Use StoreDB

CREATE NONCLUSTERED INDEX IX_Customers_Email
ON sales.customers (email);


CREATE NONCLUSTERED INDEX IX_Products_Category_Brand
ON production.products (category_id, brand_id);


CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
ON sales.orders (order_date)
INCLUDE (customer_id, store_id, order_status);


CREATE TABLE customer_log (
    log_id INT IDENTITY PRIMARY KEY,
    customer_id INT,
    message NVARCHAR(255),
    log_date DATETIME DEFAULT GETDATE()
);

CREATE TABLE price_history (
    history_id INT IDENTITY PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date DATETIME DEFAULT GETDATE()
);

CREATE TABLE order_audit (
    audit_id INT IDENTITY PRIMARY KEY,
    order_id INT,
    customer_id INT,
    store_id INT,
    order_status NVARCHAR(50),
    order_date DATETIME,
    created_at DATETIME DEFAULT GETDATE()
);


go
CREATE TRIGGER trg_AddCustomerLog
ON sales.customers
AFTER INSERT
AS
BEGIN
    INSERT INTO customer_log (customer_id, message)
    SELECT customer_id, 'Welcome new customer!'
    FROM inserted;
END;
go


CREATE TRIGGER trg_LogPriceChange
ON production.products
AFTER UPDATE
AS
BEGIN
    IF UPDATE(list_price)
    BEGIN
        INSERT INTO price_history (product_id, old_price, new_price)
        SELECT d.product_id, d.list_price, i.list_price
        FROM deleted d
        INNER JOIN inserted i ON d.product_id = i.product_id;
    END
END;

go
CREATE TRIGGER trg_PreventCategoryDelete
ON production.categories
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM production.products p
        INNER JOIN deleted d ON p.category_id = d.category_id
    )
    BEGIN
        RAISERROR('Cannot delete category because products are associated with it.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM production.categories
        WHERE category_id IN (SELECT category_id FROM deleted);
    END
END;


go
CREATE TRIGGER trg_UpdateStockOnOrderItem
ON sales.order_items
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET s.quantity = s.quantity - i.quantity
    FROM production.stocks s
    INNER JOIN inserted i ON s.product_id = i.product_id
                         AND s.store_id = i.store_id;
END;
go

CREATE TRIGGER trg_LogNewOrder
ON sales.orders
AFTER INSERT
AS
BEGIN
    INSERT INTO order_audit (order_id, customer_id, store_id, order_status, order_date)
    SELECT order_id, customer_id, store_id, order_status, order_date
    FROM inserted;
END;
go