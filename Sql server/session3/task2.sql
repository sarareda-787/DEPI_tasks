--List all products with list price greater than 1000

select * 
from production.products
where list_price > 1000
--Get customers from "CA" or "NY" states

select *
from sales.customers
where state in ('CA','NY')
--Retrieve all orders placed in 2023

select * 
from sales.orders 
where year(shipped_date) =2023
--Show customers whose emails end with @gmail.com

select *
from sales.customers
where email like'%@gmail.com'
--Show all inactive staff

select *
from sales.staffs
where active =0
--List top 5 most expensive products

select top 5 *
from production.products
order by list_price desc
--Show latest 10 orders sorted by date

select top 10 * 
from sales.orders 
order by order_date desc
--Retrieve the first 3 customers alphabetically by last name

select top 3 *
from sales.customers
order by last_name
--Find customers who did not provide a phone number

select * 
from sales.customers
where phone is null
--Show all staff who have a manager assigned

select * 
from sales.staffs
where manager_id is not null
--Count number of products in each category

select count(*) as num_product ,c.category_id
from production.products p inner join production.categories c
on p.category_id = c.category_id
group by c.category_id
--Count number of customers in each state

select count(*) as num_customer, state
from sales.customers
group by state
--Get average list price of products per brand

select avg(list_price) as average ,b.brand_id
from production.products p inner join production.brands b
on p.brand_id =b.brand_id
group by b.brand_id
--Show number of orders per staff

select count(*) as num_order ,s.staff_id
from sales.orders o inner join sales.staffs s
on o.staff_id =s.staff_id
group by s.staff_id
--Find customers who made more than 2 orders

select c.customer_id ,order_status
from sales.customers c inner join sales.orders o
on c.customer_id =o.customer_id
where order_status >2 
--Products priced between 500 and 1500

select * 
from production.products 
where list_price between 500 and 1500
--Customers in cities starting with "S"

select * 
from sales.customers
where city like 'S%'
--Orders with order_status either 2 or 4

select  * 
from sales.orders
where order_status in (2,4)
--Products from category_id IN (1, 2, 3)

select * 
from production.products
where category_id in(1,2,3)
--Staff working in store_id = 1 OR without phone number

select *
from sales.staffs
where store_id = 1 or phone is null
