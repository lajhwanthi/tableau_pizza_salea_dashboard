use dbtest

select count(*) from pizza_salez

select sum(total_price) from pizza_salez

-- creating copy table
create table pizza_sales_copy
select *
from pizza_salez;

select * from pizza_sales_copy;

-- ** LITTLE DATA CLEANING ** -- 

-- changing date format from mm/dd/yyyy to yyyy/mm/dd
update pizza_sales_copy 
set order_date = date_format(str_to_date(order_date,'%m/%d/%Y'),'%Y/%m/%d');

-- changing column datatype
alter table pizza_sales_copy modify column order_date date;
alter table pizza_sales_copy modify column order_time time;

-- transforming single-letter representations in the 'pizza_size' column into their corresponding full-word equivalents

-- understanding the full range of pizza sizes available
select distinct pizza_size from pizza_sales_copy;

-- checking for null values
select count(pizza_size)
from pizza_sales_copy
where pizza_size is null;

update pizza_sales_copy
set pizza_size = 
	case
		when pizza_size = 'S' then 'Regular'
        when pizza_size = 'M' then 'Medium'
        when pizza_size = 'L' then 'Larger'
        when pizza_size = 'XL' then 'X-Large'
        when pizza_size = 'XXL' then 'XX-Large'
	end;

select * from pizza_sales_copy;

-- A. KPI`s
-- A(1). Total Revenue:
select sum(total_price) 
from pizza_sales_copy;

-- A(2). Avg Order Value
select (sum(total_price)/count(distinct(order_id))) as Avg_Order_Value 
from pizza_sales_copy;

-- A(3). Total Pizza Sold
select sum(quantity) as Total_Pizza_Sold
from pizza_sales_copy;

-- A(4). Total Orders
select count(distinct order_id) as Total_Orders
from pizza_sales_copy;

-- A(5). Avg_Pizzas Per Order
select cast(cast(sum(quantity) as decimal(10,2)) /
cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2))
as Avg_Pizzas_Per_Order
from pizza_sales_copy;

-- B. Hourly Trends for Total Pizzas Sold
select hour(order_time) as order_hours, sum(quantity) as total_pizzas_sold
from pizza_sales_copy
group by hour(order_time)
order by hour(order_time);


-- C. Weekly Trends for Orders
select 
    week(order_date, 3) as WeekNumber,
    year(order_date) as Year,
    count(distinct order_id) as Total_orders
from 
    pizza_sales_copy
group by 
    week(order_date, 3),
    year(order_date)
order by 
    Year, WeekNumber;

-- D.Percentage of Sales by Pizza Category
select pizza_category , cast(sum(total_price) as decimal(10,2)) as total_revenue,
cast((sum(total_price) * 100) / (select sum(total_price) from pizza_sales_copy )as decimal(10,2)) as PCT
from pizza_sales_copy
group by pizza_category
order by PCT desc;

-- E. Percentage of Sales by Pizza Size
select pizza_size, cast(sum(total_price) as decimal(10,2)) as total_revenue,
cast((sum(total_price) * 100)/(select sum(total_price) from pizza_sales_copy) as decimal(10,2)) as PCT
from pizza_sales_copy
group by pizza_size
order by PCT desc;

-- F. Total Pizzas Sold by Pizza Category
select pizza_category, sum(quantity) as Total_Quantity_Sold
from pizza_sales_copy
group by pizza_category
order by Total_Quantity_Sold desc;

--  G. Top 5 Pizzas by Revenue
select pizza_name, sum(total_price) as Total_Revenue
from pizza_sales_copy
group by pizza_name
order by total_revenue desc
limit 5;


-- H. Bottom 5 Pizzas by Revenue
select pizza_name, sum(total_price) as Total_Revenue
from pizza_sales_copy
group by pizza_name
order by total_revenue asc
limit 5;


-- I. Top 5 Pizzas by Quantity
select pizza_name, sum(quantity) as Total_Pizzas_Sold
from pizza_sales_copy
group by pizza_name
order by Total_Pizzas_Sold desc
limit 5;

-- J. Bottom 5 Pizzas by Quantity
select pizza_name, sum(quantity) as Total_Pizzas_Sold
from pizza_sales_copy
group by pizza_name
order by Total_Pizzas_Sold asc
limit 5;

-- K. Top 5 Pizzas by Total_Orders
select pizza_name, count(distinct order_id) as Total_Orders
from pizza_sales_copy
group by pizza_name
order by Total_Orders desc
limit 5;

-- L. Bottom 5 Pizzas by Total_Orders
select pizza_name, count(distinct order_id) as Total_Orders
from pizza_sales_copy
group by pizza_name
order by Total_Orders asc
limit 5;