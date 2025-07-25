--1.Create a non-clustered index on the email column in the sales.customers table
--to improve search performance when looking up customers by email.

create nonclustered index i1 on sales.customers(email)
select * from sales.customers
where email ='donald.walker10@verizon.net'

--2.Create a composite index on the production.products table that includes category_id and brand_id columns
--to optimize searches that filter by both category and brand.

create nonclustered index i2 on production.products( category_id , brand_id)
select * from production.products 
where category_id=1 and brand_id=20

--3.Create an index on sales.orders table for the order_date column 
--and include customer_id, store_id, and order_status as included columns 
--to improve reporting queries.

create nonclustered index i3 on sales.orders( order_date)
include ( customer_id, store_id,  order_status)
 select  customer_id, store_id,  order_status
 from  sales.orders
 where order_date ='2022-04-16'

 -- Customer activity log
CREATE TABLE sales.customer_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    action VARCHAR(50),
    log_date DATETIME DEFAULT GETDATE()
);

-- Price history tracking
CREATE TABLE production.price_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date DATETIME DEFAULT GETDATE(),
    changed_by VARCHAR(100)
);

-- Order audit trail
CREATE TABLE sales.order_audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    customer_id INT,
    store_id INT,
    staff_id INT,
    order_date DATE,
    audit_timestamp DATETIME DEFAULT GETDATE()
);


--4.Create a trigger that automatically inserts a welcome record into a customer_log table
--whenever a new customer is added to sales.customers. 
--(First create the log table, then the trigger)
CREATE TRIGGER t1
ON sales.customers
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.customer_log (customer_id, action)
    SELECT 
        i.customer_id,
        'Welcome, new customer!'  
    FROM inserted i;
END;

INSERT INTO sales.customers (first_name, last_name, email)
VALUES ('Sara', 'Reda', 'sara@example.com');
SELECT * FROM sales.customer_log
select * from sales.customers

--5.Create a trigger on production.products that logs any changes to the list_price column into a price_history table, storing the old price, new price, and change date.

CREATE TRIGGER t2
ON production.products
AFTER UPDATE
AS
BEGIN
    INSERT INTO production.price_history (
        product_id, old_price, new_price, change_date, changed_by
    )
    SELECT 
        d.product_id,
        d.list_price,
        i.list_price,
        GETDATE(),
        SYSTEM_USER
    FROM deleted d
    JOIN inserted i ON d.product_id = i.product_id
    WHERE ISNULL(d.list_price, 0) <> ISNULL(i.list_price, 0);  
END;
UPDATE production.products
SET list_price = 200.00
WHERE product_id = 1;
SELECT * FROM production.price_history;

--6.Create an INSTEAD OF DELETE trigger on production.categories that prevents deletion of categories that have associated products. Display an appropriate error message.

CREATE TRIGGER t3
ON production.categories
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN production.products p ON d.category_id = p.category_id
    )
    BEGIN
        RAISERROR('Cannot delete category: it has associated products.', 16, 1);
        RETURN;
    END

    DELETE FROM production.categories
    WHERE category_id IN (SELECT category_id FROM deleted);
END;

DELETE FROM production.categories
WHERE category_id = 1;


--7.Create a trigger on sales.order_items that automatically reduces the quantity in production.stocks when a new order item is inserted.

CREATE TRIGGER t4
ON sales.order_items
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET s.quantity = s.quantity - i.quantity
    FROM production.stocks s
    JOIN inserted i ON s.product_id = i.product_id;
END;


INSERT INTO sales.order_items (item_id, product_id, quantity, list_price)
VALUES (1, 101, 5, 100.00);

select * from  sales.order_items

--8.Create a trigger that logs all new orders into an order_audit table, capturing order details and the date/time when the record was created.

CREATE TRIGGER t5
ON sales.orders
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.order_audit (
        order_id, customer_id, store_id, staff_id, order_date
    )
    SELECT 
        i.order_id,
        i.customer_id,
        i.store_id,
        i.staff_id,
        i.order_date
    FROM inserted i;
END;
INSERT INTO sales.orders (customer_id, store_id, staff_id, order_date)
VALUES (1, 2, 3, '2025-07-25');
SELECT * FROM sales.order_audit;



