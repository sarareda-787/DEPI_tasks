-- 1.Write a query that classifies all products into price categories:

--Products under $300: "Economy"
--Products $300-$999: "Standard"
--Products $1000-$2499: "Premium"
--Products $2500 and above: "Luxury"
select product_name ,list_price ,
  case 
      when list_price < $300 then 'Economy'
	  when list_price between $300 and $999  then 'Standard'
	  when list_price between $1000 and $2499  then 'Premium'
	  else 'Luxury'
  end 
  as price_categories
from production.products

--2.Create a query that shows order processing information with user-friendly status descriptions:

--Status 1: "Order Received"
--Status 2: "In Preparation"
--Status 3: "Order Cancelled"
--Status 4: "Order Delivered"
--Also add a priority level:

--Orders with status 1 older than 5 days: "URGENT"
--Orders with status 2 older than 3 days: "HIGH"
--All other orders: "NORMAL"  
select order_status , day(order_date) as order_day,
case 
     when (order_status = 1) then 'Order Received'   
	 when (order_status = 2) then 'In Preparation'  
	  when (order_status = 3) then 'Order Cancelled'
	  when (order_status = 4) then 'Order Delivered'
	  else 'invalid'	  
end 
as processing_information
 , case
    when order_status = 1 and   day(order_date)>5 then 'URGENT'
	 when order_status = 2  and day(order_date)>3 then 'HIGH'
     else 'NORMAL'
 end 
 as priority_level
from sales.orders 

--3.Write a query that categorizes staff based on the number of orders they've handled:

--0 orders: "New Staff"
--1-10 orders: "Junior Staff"
--11-25 orders: "Senior Staff"
--26+ orders: "Expert Staff"
select concat(first_name,'  ',last_name) as [full name] , count(order_id) as num_order ,
case 
     when count(order_id) =0 then 'New Staff'
	 when count(order_id) between 1 and 10 then 'Junior Staff'
	 when count(order_id) between 11 and 25  then 'Senior Staff'
	 else 'Expert Staff'
end 
from sales.staffs s left join sales.orders o
on s.staff_id = o.staff_id
group by concat(first_name,'  ',last_name)

--4.Create a query that handles missing customer contact information:

--Use ISNULL to replace missing phone numbers with "Phone Not Available"
--Use COALESCE to create a preferred_contact field (phone first, then email, then "No Contact Method")
--Show complete customer information
select  isnull(phone,'Phone Not Available')  as contact_information,
       coalesce(phone , email ,'No Contact Method') as contact_information ,
	   phone , email

from sales.customers

--5.Write a query that safely calculates price per unit in stock:

--Use NULLIF to prevent division by zero when quantity is 0
--Use ISNULL to show 0 when no stock exists
--Include stock status using CASE WHEN
--Only show products from store_id = 1 
select p.product_id ,isnull((list_price/nullif(quantity ,0)),0) as  price_per_unit,
       p.product_name , s.quantity ,
case 
        WHEN quantity = 0 THEN 'Out of Stock'
        WHEN s.quantity < 10 THEN 'Low Stock'
        ELSE 'In Stock'                      
end
as stock_status
from production.stocks s left join production.products p
on s.product_id = p.product_id
where store_id=1

order by p.product_id 

--6.Create a query that formats complete addresses safely:

--Use COALESCE for each address component
--Create a formatted_address field that combines all components
--Handle missing ZIP codes gracefully
select 
coalesce(street,'no_street') as street,
coalesce(city,'no_city') as city ,
coalesce(state,'no_state') as state,
concat(coalesce(street,'no_street'),'  ',
coalesce(city,'no_city'),'  ',
coalesce(state,'no_state'),'  ',
isnull(zip_code,'no_code')) as formatted_address,
isnull(zip_code,'no_code') as zip_code
from sales.customers
 

-- 7.Use a CTE to find customers who have spent more than $1,500 total:

--Create a CTE that calculates total spending per customer
--Join with customer information
--Show customer details and spending
--Order by total_spent descending
WITH total_spending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 1500
)
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS [full name],
    ts.total_spent
FROM total_spending ts
JOIN sales.customers c ON c.customer_id = ts.customer_id
ORDER BY ts.total_spent DESC

--8.Create a multi-CTE query for category analysis:

--CTE 1: Calculate total revenue per category
--CTE 2: Calculate average order value per category
--Main query: Combine both CTEs
--Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"
WITH total_revenue AS ( 
    SELECT  
        c.category_id,  
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id
),

average_order AS (
    SELECT  
        c.category_id,  
        AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS average_order_value
    FROM production.categories c
    JOIN production.products p ON c.category_id = p.category_id
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id
)

SELECT 
    tr.category_id,
    tr.total_revenue,
    ao.average_order_value,

    CASE 
        WHEN tr.total_revenue > 50000 THEN 'Excellent'
        WHEN tr.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_rating

FROM total_revenue tr
JOIN average_order ao ON tr.category_id = ao.category_id;

--9.Use CTEs to analyze monthly sales trends:

--CTE 1: Calculate monthly sales totals
--CTE 2: Add previous month comparison
--Show growth percentage 
WITH monthly_sales AS (
    SELECT 
        MONTH(shipped_date) AS month_date, 
        SUM(quantity * list_price * (1 - discount)) AS monthly_sales
    FROM sales.order_items oi
    INNER JOIN sales.orders o ON oi.order_id = o.order_id
    GROUP BY MONTH(shipped_date)
),

sales_with_prev AS (
    SELECT 
        month_date,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month_date) AS previous_month_sales
    FROM monthly_sales
)

SELECT 
    month_date,
    monthly_sales,
    previous_month_sales, 
   ROUND((monthly_sales - previous_month_sales) * 100.0 / previous_month_sales,2)
    AS growth_percentage
FROM sales_with_prev
ORDER BY month_date;

--10.Create a query that ranks products within each category:

--Use ROW_NUMBER() to rank by price (highest first)
--Use RANK() to handle ties
--Use DENSE_RANK() for continuous ranking
--Only show top 3 products per category
WITH ranked_products AS (
    SELECT 
        product_name,
        category_id,
        list_price,
        ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS row_price,
        RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS rank_price,
        DENSE_RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS drank_price

    FROM production.products
)
SELECT 
    product_name,
    category_id,
    list_price,
    row_price,
    rank_price,
    drank_price
FROM ranked_products
WHERE row_price <= 3
ORDER BY category_id, row_price

--11.Rank customers by their total spending:

--Calculate total spending per customer
--Use RANK() for customer ranking
--Use NTILE(5) to divide into 5 spending groups
--Use CASE for tiers: 1="VIP", 2="Gold", 3="Silver", 4="Bronze", 5="Standard"
WITH total_spending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
   )
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS [full name],
    ts.total_spent,
	rank() over (order by ts.total_spent asc)  as customer_ranking,
	NTILE(5) over (order by ts.total_spent asc)  as spending_groups,
	case 
	when rank() over (order by ts.total_spent asc) =1 then 'VIP'
	when rank() over (order by ts.total_spent asc) =2 then 'Gold'
	when rank() over (order by ts.total_spent asc) =3 then 'Silver'
	when rank() over (order by ts.total_spent asc)=4 then 'Bronze'
	when rank() over (order by ts.total_spent asc)=5 then 'Standard'
	end as tiers
FROM total_spending ts
JOIN sales.customers c ON c.customer_id = ts.customer_id

--12.Create a comprehensive store performance ranking:

--Rank stores by total revenue
--Rank stores by number of orders
--Use PERCENT_RANK() to show percentile performance
WITH store_performance AS (
    SELECT 
        s.store_id,
        s.store_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
)
SELECT 
    store_id,
    store_name,
    total_orders,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_percentile,
    RANK() OVER (ORDER BY total_orders DESC) AS order_rank,
    PERCENT_RANK() OVER (ORDER BY total_orders DESC) AS order_percentile
FROM store_performance
ORDER BY revenue_rank

--13.Create a PIVOT table showing product counts by category and brand:

--Rows: Categories
--Columns: Top 4 brands (Electra, Haro, Trek, Surly)
--Values: Count of products
select * from 
(
select c.category_name,
        brand_name
from production.categories c inner join production.products p
on c.category_id = p.category_id
join production.brands b 
on b.brand_id =p.brand_id
where brand_name in ('Electra', 'zara', 'Trek', 'Surly')
) as source_table
pivot (
count(brand_name)
FOR brand_name IN ([Electra], [zara], [Trek], [Surly])
) AS pivot_table
select * from production.brands
--14.Create a PIVOT showing monthly sales revenue by store:

--Rows: Store names
--Columns: Months (Jan through Dec)
--Values: Total revenue
--Add a total column
WITH monthly_sales AS (
    SELECT 
        s.store_name,
        MONTH(o.order_date) AS order_month,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS monthly_revenue
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_name, MONTH(o.order_date)
)

SELECT 
    store_name,
    ISNULL([1], 0) AS Jan,
    ISNULL([2], 0) AS Feb,
    ISNULL([3], 0) AS Mar,
    ISNULL([4], 0) AS Apr,
    ISNULL([5], 0) AS May,
    ISNULL([6], 0) AS Jun,
    ISNULL([7], 0) AS Jul,
    ISNULL([8], 0) AS Aug,
    ISNULL([9], 0) AS Sep,
    ISNULL([10], 0) AS Oct,
    ISNULL([11], 0) AS Nov,
    ISNULL([12], 0) AS Deca,
   
    ISNULL([1],0)+ISNULL([2],0)+ISNULL([3],0)+ISNULL([4],0)+ISNULL([5],0)+ISNULL([6],0)+
    ISNULL([7],0)+ISNULL([8],0)+ISNULL([9],0)+ISNULL([10],0)+ISNULL([11],0)+ISNULL([12],0) AS Total_Revenue

FROM monthly_sales
PIVOT (
    SUM(monthly_revenue) FOR order_month IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12] )
) AS pivot_months;

--15.PIVOT order statuses across stores:

--Rows: Store names
--Columns: Order statuses (Pending, Processing, Completed, Rejected)
--Values: Count of orders
SELECT *
FROM (
    SELECT 
        s.store_name,
        CASE 
            WHEN o.order_status = 1 THEN 'Pending'
            WHEN o.order_status = 2 THEN 'Processing'
            WHEN o.order_status = 3 THEN 'Rejected'
            WHEN o.order_status = 4 THEN 'Completed'
            ELSE 'Other'
        END AS status_label
    FROM sales.orders o
    JOIN sales.stores s ON o.store_id = s.store_id
) AS source_data

PIVOT (
    COUNT(status_label)
    FOR status_label IN ([Pending], [Processing], [Completed], [Rejected])
) AS pivot_status;

--16.Create a PIVOT comparing sales across years:

--Rows: Brand names
--Columns: Years (2016, 2017, 2018)
--Values: Total revenue
--Include percentage growth calculations

WITH brand_year_sales AS (
    SELECT 
        pb.brand_name,
        YEAR(o.order_date) AS sales_year,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM production.products p
    JOIN sales.order_items oi ON p.product_id = oi.product_id
    JOIN sales.orders o ON oi.order_id = o.order_id
	join production.brands pb on pb.brand_id =p.brand_id
    WHERE YEAR(o.order_date) IN (2016, 2017, 2018)
    GROUP BY pb.brand_name, YEAR(o.order_date)
),

pivoted AS (
    SELECT *
    FROM brand_year_sales
    PIVOT (
        SUM(total_revenue)
        FOR sales_year IN ([2016], [2017], [2018])
    ) AS pivot_years
)

SELECT 
    brand_name,
    ISNULL([2016], 0) AS Revenue_2016,
    ISNULL([2017], 0) AS Revenue_2017,
    ISNULL([2018], 0) AS Revenue_2018,
    CASE 
        WHEN ISNULL([2016], 0) = 0 THEN NULL
        ELSE ROUND(([2017] - [2016]) * 100.0 / [2016], 2)
    END AS Growth_16_to_17,
    CASE 
        WHEN ISNULL([2017], 0) = 0 THEN NULL
        ELSE ROUND(([2018] - [2017]) * 100.0 / [2017], 2)
    END AS Growth_17_to_18

FROM pivoted
ORDER BY brand_name;

 
-- 17.Use UNION to combine different product availability statuses:

--Query 1: In-stock products (quantity > 0)
--Query 2: Out-of-stock products (quantity = 0 or NULL)
--Query 3: Discontinued products (not in stocks table)
SELECT 
    p.product_id,
    p.product_name,
    'In Stock' AS availability_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0
UNION
SELECT 
    p.product_id,
    p.product_name,
    'Out of Stock' AS availability_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL
UNION
SELECT 
    p.product_id,
    p.product_name,
    'Discontinued' AS availability_status
FROM production.products p
LEFT JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.product_id IS NULL;

--18.Use INTERSECT to find loyal customers:

--Find customers who bought in both 2017 AND 2018
--Show their purchase patterns
WITH loyal_customers AS (
    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE YEAR(order_date) = 2017

    INTERSECT

    SELECT DISTINCT customer_id
    FROM sales.orders
    WHERE YEAR(order_date) = 2018
)
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
FROM loyal_customers lc
JOIN sales.customers c ON c.customer_id = lc.customer_id
JOIN sales.orders o ON o.customer_id = c.customer_id
JOIN sales.order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--19.Use multiple set operators to analyze product distribution:

--INTERSECT: Products available in all 3 stores
SELECT product_id
FROM production.stocks
WHERE store_id = 1
INTERSECT
SELECT product_id
FROM production.stocks
WHERE store_id = 2
INTERSECT
SELECT product_id
FROM production.stocks
WHERE store_id = 3

--EXCEPT: Products available in store 1 but not in store 2
SELECT product_id
FROM production.stocks
WHERE store_id = 1
EXCEPT
SELECT product_id
FROM production.stocks
WHERE store_id = 2

--UNION: Combine above results with different labels
SELECT 
    product_id,
    'Common in All Stores' AS availability_status
FROM (
    SELECT product_id
    FROM production.stocks WHERE store_id = 1
    INTERSECT
    SELECT product_id FROM production.stocks WHERE store_id = 2
    INTERSECT
    SELECT product_id FROM production.stocks WHERE store_id = 3
) AS common
UNION
SELECT 
    product_id,
    'Only in Store 1' AS availability_status
FROM (
    SELECT product_id FROM production.stocks WHERE store_id = 1
    EXCEPT
    SELECT product_id FROM production.stocks WHERE store_id = 2
) AS only1

--20.Complex set operations for customer retention:

--Find customers who bought in 2016 but not in 2017 (lost customers)
--Find customers who bought in 2017 but not in 2016 (new customers)
--Find customers who bought in both years (retained customers)
--Use UNION ALL to combine all three groups

SELECT DISTINCT customer_id, 'Lost Customer' AS customer_status
FROM sales.orders
WHERE YEAR(order_date) = 2016
EXCEPT
SELECT DISTINCT customer_id, 'Lost Customer'
FROM sales.orders
WHERE YEAR(order_date) = 2017
UNION ALL
SELECT DISTINCT customer_id, 'New Customer' AS customer_status
FROM sales.orders
WHERE YEAR(order_date) = 2017
EXCEPT
SELECT DISTINCT customer_id, 'New Customer'
FROM sales.orders
WHERE YEAR(order_date) = 2016
UNION ALL
SELECT DISTINCT customer_id, 'Retained Customer' AS customer_status
FROM sales.orders
WHERE YEAR(order_date) = 2016
INTERSECT
SELECT DISTINCT customer_id, 'Retained Customer'
FROM sales.orders
WHERE YEAR(order_date) = 2017;
