--1. Count the total number of products in the database.
select count(*) as Tnum_products
from production.products 

--2. Find the average, minimum, and maximum price of all products.

select avg(list_price) as average, min(list_price) as min_salary, max(list_price) as max_salary
from production.products 
--3. Count how many products are in each category.

select count(*) as num_product,p.category_id
from production.products p inner join production.categories c
on p.category_id =c.category_id 
group by p.category_id

--4. Find the total number of orders for each store.

select count(*) as Tnum_order ,o.store_id
from sales.orders o inner join  sales.stores s
on o.store_id = s.store_id
group by o.store_id

--5. Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers.

select top 10  upper(first_name) as Fname ,lower(last_name) as Lname
from sales.customers 
--6. Get the length of each product name. Show product name and its length for the first 10 products.

select top 10  product_name,len(product_name) as lenght_pname 
from production.products
--7. Format customer phone numbers to show only the area code (first 3 digits) for customers 1-15.

select top 15 phone , left(phone,3) as area_code
from sales.customers
--8. Show the current date and extract the year and month from order dates for orders 1-10.

select  top 10  year(order_date) as year_date ,month(order_date) as month_date ,getdate() as currentdate
from sales.orders 
--9. Join products with their categories. Show product name and category name for first 10 products.

select top 10 	product_name ,category_name
from production.products p inner join production.categories c
on p.category_id =c.category_id

--10. Join customers with their orders. Show customer name and order date for first 10 orders.
select top 10 first_name+'  '+last_name as customer_name ,order_date
from sales.customers c inner join  sales.orders o
on c.customer_id =o.customer_id

--11. Show all products with their brand names, even if some products don't have brands. Include product name, brand name (show 'No Brand' if null).

select product_name ,isnull(brand_name,'No Brand') as brand_name
from   production.products p left join production.brands b
on p.brand_id = b.brand_id

--12. Find products that cost more than the average product price. Show product name and price.

select product_name ,list_price 
from production.products
where list_price >(select  avg(list_price) from production.products)
--13. Find customers who have placed at least one order. Use a subquery with IN. Show customer_id and customer_name.

select customer_id ,first_name+'  '+last_name as [full name] 
from sales.customers 
where customer_id in (select customer_id from sales.orders where order_status >=1)
--14. For each customer, show their name and total number of orders using a subquery in the SELECT clause.

select first_name+'  '+last_name as [full name]  , (select count( order_status) from sales.orders ) as tnum_order
from sales.customers

--15. Create a simple view called easy_product_list that shows product name, category name, and price. Then write a query to select all products from this view where price > 100.

create view easy_product_list 
as select product_name ,category_name , list_price 
from production.products p inner join production.categories c
on p.category_id = c.category_id

select * 
from easy_product_list 
where list_price > 100
--16. Create a view called customer_info that shows customer ID, full name (first + last), email, and city and state combined. Then use this view to find all customers from California (CA).

create view customer_info 
as select customer_id , first_name+'  '+last_name as[full name] ,email ,city+'  '+state as location
from sales.customers

select * 
from customer_info 
where location like '%CA'
--17. Find all products that cost between $50 and $200. Show product name and price, ordered by price from lowest to highest.

select product_name ,list_price
from production.products
where list_price between $50 and $200
order by list_price asc

--18. Count how many customers live in each state. Show state and customer count, ordered by count from highest to lowest.

select state ,count(customer_id) as Cust_count
from sales.customers
group by state 
order by count(customer_id) desc

--19. Find the most expensive product in each category. Show category name, product name, and price.

select category_name ,product_name ,max(list_price) as maxProduct 
from production.products p inner join production.categories c
on p.category_id =c.category_id
group by category_name ,product_name


--20. Show all stores and their cities, including the total number of orders from each store. Show store name, city, and order count.

select store_name , city ,count(order_id) as tnum_orders
from sales.stores s left join sales.orders o 
on s.store_id =o.store_id
group by store_name , city