--1. Customer Spending Analysis#
--Write a query that uses variables to find the total amount spent by customer ID 1. Display a message showing whether they are a VIP customer (spent > $5000) or regular customer.
 declare @total_spent decimal(10,2) 
 select @total_spent=sum(quantity * list_price * (1- discount))  
 from sales.customers c inner join sales.orders o 
 on c.customer_id = o.customer_id
 inner join sales.order_items oi 
 on o.order_id =oi.order_id
 where c.customer_id =1 
 SELECT 
    @total_spent AS total_spent,
    CASE 
        WHEN @total_spent > 5000 THEN 'VIP customer'
        ELSE 'Regular customer'
    END AS customer_status
--2. Product Price Threshold Report#
--Create a query using variables to count how many products cost more than $1500. Store the threshold price in a variable and display both the threshold and count in a formatted message.
DECLARE @price_threshold DECIMAL(10,2) = 1500
DECLARE @count_product INT
SELECT @count_product = COUNT(product_id)
FROM production.products
WHERE list_price > @price_threshold;
SELECT 
    @price_threshold AS Threshold,
    @count_product AS Product_Count,
    CONCAT('There are ', @count_product, ' products with price above $', @price_threshold) AS Report_Message;

--3. Staff Performance Calculator#
--Write a query that calculates the total sales for staff member ID 2 in the year 2017
--Use variables to store the staff ID, year, and calculated total. Display the results with appropriate labels.
declare @staff_id  int =2
declare @year int  =2017
declare @calculated_total decimal(10,2)
select @calculated_total = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
FROM sales.staffs s
JOIN sales.orders o ON s.staff_id = o.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE s.staff_id = @staff_id AND YEAR(o.shipped_date) = @year
 select  @staff_id  as staff_id,
         @year as year_shipped_date,
         @calculated_total  as calculated_total ,
		 CONCAT('Staff member ', @staff_id, ' achieved sales of $', @calculated_total, ' in ', @year) AS Report_Message;
		  
select * from sales.staffs s
JOIN sales.orders o ON s.staff_id = o.staff_id where s.staff_id=2 and year(shipped_date) = 2017
--4. Global Variables Information#
--Create a query that displays the current server name, SQL Server version, and the number of rows affected by the last statement.
--Use appropriate global variables.
select @@SERVERNAME as  SERVERNAME ,
       @@VERSION    as sql_VERSION ,
	   @@ROWCOUNT   as rows_affected
--5.Write a query that checks the inventory level for product ID 1 in store ID 1. Use IF statements to display different messages based on stock levels:#
--If quantity > 20: Well stocked
--If quantity 10-20: Moderate stock
--If quantity < 10: Low stock - reorder needed
 declare @product_ID int =1 
 declare @store_ID int =1
 declare @quantity  int 
 select @quantity=quantity 
 from sales.orders o inner join sales.order_items oi
 on o.order_id= oi.order_id
 where product_id=@product_ID and store_id=@store_ID
  If @quantity > 20
 begin
 print'Well stocked'
 end 
 else if @quantity between 10 and 20 
 begin
 print'Moderate stock'
 end 
 else if @quantity <10
 begin
 print'Low stock - reorder needed'
 end 

--6.Create a WHILE loop that updates low-stock items (quantity < 5) in batches of 3 products at a time. 
--Add 10 units to each product and display progress messages after each batch.#
DECLARE @batch_size INT = 3;  
DECLARE @rows_updated INT = 1; 
WHILE @rows_updated > 0
BEGIN
    UPDATE TOP (@batch_size) production.stocks
    SET quantity = quantity + 10
    WHERE quantity < 5;

    SET @rows_updated = @@ROWCOUNT;

    PRINT 'Updated ' + CAST(@rows_updated AS VARCHAR(10)) + ' low-stock products';
END

--7. Product Price Categorization#
--Write a query that categorizes all products using CASE WHEN based on their list price:

--Under $300: Budget
--$300-$800: Mid-Range
--$801-$2000: Premium
--Over $2000: Luxury
SELECT 
    product_id,
    product_name,
    list_price,
    CASE 
        WHEN list_price < 300 THEN 'Budget'
        WHEN list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
        WHEN list_price BETWEEN 801 AND 2000 THEN 'Premium'
        WHEN list_price > 2000 THEN 'Luxury'
        ELSE 'Unknown'
    END AS price_category
FROM production.products
ORDER BY list_price;

--8. Customer Order Validation#
--Create a query that checks if customer ID 5 exists in the database.
--If they exist, show their order count. If not, display an appropriate message.
DECLARE @customer_id INT = 5;
IF EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @customer_id)
BEGIN
    DECLARE @order_count INT;

    SELECT @order_count = COUNT(*)
    FROM sales.orders
    WHERE customer_id = @customer_id;

    PRINT 'Customer found. Proceeding with order creation';
    PRINT 'Order count: ' + CAST(@order_count AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Customer not found. Please create customer record first.';
END

--9. Shipping Cost Calculator Function#
--Create a scalar function named CalculateShipping that takes an order total as input and returns shipping cost:
--Orders over $100: Free shipping ($0)
--Orders $50-$99: Reduced shipping ($5.99)
--Orders under $50: Standard shipping ($12.99)
CREATE FUNCTION dbo.CalculateShipping (@order_total DECIMAL(10,2))
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @shipping_cost VARCHAR(100)

    SET @shipping_cost = 
        CASE 
            WHEN @order_total > 100 THEN 'Free shipping ($0)'
            WHEN @order_total BETWEEN 50 AND 100 THEN 'Reduced shipping ($5.99)'
            ELSE 'Standard shipping ($12.99)'
        END;

    RETURN @shipping_cost;
END
SELECT dbo.CalculateShipping (500) AS ShippingMessage;

--10. Product Category Function#
--Create an inline table-valued function named GetProductsByPriceRange 
--that accepts minimum and maximum price parameters and 
--returns all products within that price range with their brand and category information.
create function dbo.GetProductsByPriceRange(@min decimal(10,2) ,@max decimal(10,2))
returns table
as return
(
select  brand_name,category_name ,list_price
from production.products p inner join production.categories c
on c.category_id =p.category_id
inner join production.brands b
on b.brand_id = p.brand_id
where list_price between @min and @max
)
select * from dbo.GetProductsByPriceRange(50 ,200)
--11. Customer Sales Summary Function#
--Create a multi-statement function named GetCustomerYearlySummary that takes a customer ID and 
--returns a table with yearly sales data including total orders, total spent, and average order value for each year.
CREATE FUNCTION dbo.GetCustomerYearlySummary (@customer_id INT)
RETURNS @summary TABLE (
    sales_year INT,
    total_orders INT,
    total_spent DECIMAL(18,2),
    average_order_value DECIMAL(18,2)
)
AS
BEGIN
    INSERT INTO @summary
    SELECT 
        YEAR(o.order_date) AS sales_year,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent,
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS average_order_value
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
    GROUP BY YEAR(o.order_date)
    
    RETURN
END
select * from .GetCustomerYearlySummary(5)

--12. Discount Calculation Function#
--Write a scalar function named CalculateBulkDiscount that determines discount percentage based on quantity:
--1-2 items: 0% discount
--3-5 items: 5% discount
--6-9 items: 10% discount
--10+ items: 15% discount
CREATE FUNCTION dbo.CalculateBulkDiscount (@count_item INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @discount_label VARCHAR(20);

    SET @discount_label = 
        CASE 
            WHEN @count_item IN (1, 2) THEN '0% discount'
            WHEN @count_item BETWEEN 3 AND 5 THEN '5% discount'
            WHEN @count_item BETWEEN 6 AND 9 THEN '10% discount'
            ELSE '15% discount'
        END;

    RETURN @discount_label;
END
select dbo.CalculateBulkDiscount(9) as CalculateBulkDiscount

--13. Customer Order History Procedure#
--Create a stored procedure named sp_GetCustomerOrderHistory that accepts a customer ID and optional start/end dates. 
--Return the customer's order history with order totals calculated.

CREATE PROCEDURE sp_GetCustomerOrders
    @customer_id INT,
    @start_date DATE = NULL,
    @end_date DATE = NULL
AS
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.order_status,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as order_total
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
        AND (@start_date IS NULL OR o.order_date >= @start_date)
        AND (@end_date IS NULL OR o.order_date <= @end_date)
    GROUP BY o.order_id, o.order_date, o.order_status
    ORDER BY o.order_date DESC;
END

EXEC sp_GetCustomerOrders @customer_id = 1;
EXEC sp_GetCustomerOrders @customer_id = 1, @start_date = '2017-01-01';

--14. Inventory Restock Procedure#
--Write a stored procedure named sp_RestockProduct with input parameters for 
--store ID, product ID, and restock quantity. Include output parameters for old quantity, new quantity, and success status.
CREATE PROCEDURE sp_RestockProduct
    @store_ID INT,
    @product_ID INT,
    @restock_quantity INT,
    @old_quantity INT OUTPUT,
    @new_quantity INT OUTPUT,
    @success BIT OUTPUT
AS
BEGIN
    SELECT @old_quantity = quantity
    FROM production.stocks
    WHERE store_id = @store_ID AND product_id = @product_ID
    IF @old_quantity IS NOT NULL
    BEGIN
        UPDATE production.stocks
        SET quantity = quantity + @restock_quantity
        WHERE store_id = @store_ID AND product_id = @product_ID
        SELECT @new_quantity = quantity
        FROM production.stocks
        WHERE store_id = @store_ID AND product_id = @product_ID
        SET @success = 1;
    END
    ELSE
    BEGIN
        SET @old_quantity = 0;
        SET @new_quantity = 0;
        SET @success = 0;
    END
END;
DECLARE @old INT, @new INT, @ok BIT;
EXEC sp_RestockProduct
    @store_ID = 1,
    @product_ID = 101,
    @restock_quantity = 20,
    @old_quantity = @old OUTPUT,
    @new_quantity = @new OUTPUT,
    @success = @ok OUTPUT;
SELECT 
    @old AS OldQuantity,
    @new AS NewQuantity,
    @ok AS SuccessStatus;
--15. Order Processing Procedure#
--Create a stored procedure named sp_ProcessNewOrder
--that handles complete order creation with proper transaction control and error handling.
--Include parameters for customer ID, product ID, quantity, and store ID.

CREATE PROCEDURE sp_ProcessNewOrder
    @customer_id INT,
    @product_id INT,
    @quantity INT,
    @store_id INT
AS
BEGIN
    DECLARE @order_id INT,
            @staff_id INT,
            @stock_qty INT,
            @price DECIMAL(10,2),
            @discount DECIMAL(4,2) = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = @customer_id)
        BEGIN
            RAISERROR('Customer does not exist.', 16, 1);
        END
        SELECT @stock_qty = quantity
        FROM production.stocks
        WHERE product_id = @product_id AND store_id = @store_id;
        IF @stock_qty IS NULL OR @stock_qty < @quantity
        BEGIN
            RAISERROR('Insufficient stock.', 16, 1);
        END
        SELECT TOP 1 @staff_id = staff_id
        FROM sales.staffs
        WHERE store_id = @store_id;
        SELECT @price = list_price
        FROM production.products
        WHERE product_id = @product_id;
        INSERT INTO sales.orders (customer_id, order_status, order_date, required_date, store_id, staff_id)
        VALUES (@customer_id, 1, GETDATE(), DATEADD(DAY, 7, GETDATE()), @store_id, @staff_id);
        SET @order_id = SCOPE_IDENTITY(); 
        INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
        VALUES (@order_id, 1, @product_id, @quantity, @price, @discount);
        UPDATE production.stocks
        SET quantity = quantity - @quantity
        WHERE product_id = @product_id AND store_id = @store_id;

        COMMIT TRANSACTION;
        PRINT ' Order created successfully.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END
 EXEC sp_ProcessNewOrder 
    @customer_id = 1,
    @product_id = 101,
    @quantity = 2,
    @store_id = 1;

--16. Dynamic Product Search Procedure#
--Write a stored procedure named sp_SearchProducts that builds dynamic SQL based on optional parameters: 
--product name search term, category ID, minimum price, maximum price, and sort column.
CREATE PROCEDURE sp_SearchProducts 
    @product_name VARCHAR(255) = NULL,
    @category_ID INT = NULL,
    @minimum_price DECIMAL(10,2) = NULL,
    @maximum_price DECIMAL(10,2) = NULL,
    @sort_column NVARCHAR(50) = 'product_name'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
    SELECT product_id, product_name, category_id, list_price
    FROM production.products
    WHERE 1 = 1'
    IF @product_name IS NOT NULL
        SET @sql += ' AND product_name LIKE ''%' + @product_name + '%''';
    IF @category_ID IS NOT NULL
        SET @sql += ' AND category_id = ' + CAST(@category_ID AS NVARCHAR);
    IF @minimum_price IS NOT NULL
        SET @sql += ' AND list_price >= ' + CAST(@minimum_price AS NVARCHAR);
    IF @maximum_price IS NOT NULL
        SET @sql += ' AND list_price <= ' + CAST(@maximum_price AS NVARCHAR);
    SET @sql += ' ORDER BY ' + QUOTENAME(@sort_column);
    EXEC sp_executesql @sql;
END
exec sp_SearchProducts  
    @product_name = 'J.Crew Baird McNutt Linen Shirt - Navy',
    @category_ID = 2,
    @minimum_price = 88.50,
    @maximum_price = 90.50,
    @sort_column = 'list_price';
	 select * from production.products

--17. Staff Bonus Calculation System#
--Create a complete solution that calculates quarterly bonuses for all staff members.
--Use variables to store date ranges and bonus rates. 
--Apply different bonus percentages based on sales performance tiers.
DECLARE @start_date DATE = '2022-01-01';
DECLARE @end_date DATE = '2022-03-31';  
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales,

    CASE 
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) < 10000 THEN 0.05
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) BETWEEN 10000 AND 20000 THEN 0.10
        ELSE 0.15
    END AS bonus_rate,


    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) *
    CASE 
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) < 10000 THEN 0.05
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) BETWEEN 10000 AND 20000 THEN 0.10
        ELSE 0.15
    END AS bonus_amount

FROM sales.staffs s
JOIN sales.orders o ON s.staff_id = o.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id

WHERE o.order_date BETWEEN @start_date AND @end_date

GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY bonus_amount DESC;
select * from sales.orders
--18. Smart Inventory Management#
--Write a complex query with nested IF statements that manages inventory restocking. 
--Check current stock levels and apply different reorder quantities based on product categories
--and current stock levels.
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    s.store_id,
    s.quantity AS current_stock,

    CASE 
        WHEN s.quantity < 5 THEN
            CASE 
                WHEN p.category_id = 1 THEN 50   
                WHEN p.category_id = 2 THEN 30   
                ELSE 20                          
            END

        WHEN s.quantity BETWEEN 5 AND 10 THEN
            CASE 
                WHEN p.category_id = 1 THEN 20
                WHEN p.category_id = 2 THEN 10
                ELSE 5
            END

        ELSE 0 
    END AS restock_quantity

FROM production.stocks s
JOIN production.products p ON s.product_id = p.product_id

--19. Customer Loyalty Tier Assignment#
--Create a comprehensive solution that assigns loyalty tiers to customers based on their total spending.
--Handle customers with no orders appropriately and use proper NULL checking.

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    ISNULL(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 0) AS total_spent,
    CASE
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) IS NULL THEN 'New'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) >= 10000 THEN 'VIP'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) >= 5000 THEN 'Gold'
        WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_tier

FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id

GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--20. Product Lifecycle Management#
--Write a stored procedure that handles product discontinuation including checking for pending orders,
--optional product replacement in existing orders, clearing inventory,
--and providing detailed status messages.
CREATE PROCEDURE sp_DiscontinueProduct
    @product_id INT,
    @replacement_product_id INT = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pending_orders INT;

    SELECT @pending_orders = COUNT(*)
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE oi.product_id = @product_id AND o.order_status IN (1, 2);  -- 1: Received, 2: In preparation

    IF @pending_orders > 0
    BEGIN
        PRINT 'There are ' + CAST(@pending_orders AS VARCHAR) + ' pending orders for this product.';
        IF @replacement_product_id IS NOT NULL
        BEGIN
            UPDATE sales.order_items
            SET product_id = @replacement_product_id
            WHERE product_id = @product_id;
            PRINT 'Pending orders updated to use replacement product ID: ' + CAST(@replacement_product_id AS VARCHAR);
        END
        ELSE
        BEGIN
            PRINT 'Warning: No replacement product provided. Pending orders still reference the discontinued product.';
        END
    END
    ELSE
    BEGIN
        PRINT 'No pending orders found for this product.';
    END
    UPDATE production.stocks
    SET quantity = 0
    WHERE product_id = @product_id;
    PRINT 'Inventory cleared for product ID: ' + CAST(@product_id AS VARCHAR);
    PRINT 'Product discontinuation process completed successfully.';
END
EXEC sp_DiscontinueProduct @product_id = 101, @replacement_product_id = 102;