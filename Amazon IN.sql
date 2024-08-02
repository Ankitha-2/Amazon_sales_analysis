-- creating customers table

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
                            customer_id VARCHAR(25) PRIMARY KEY,
                            customer_name VARCHAR(25),
                            state VARCHAR(25)
);


-- creating sellers table

DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
                        seller_id VARCHAR(25) PRIMARY KEY,
                        seller_name VARCHAR(25)
);


-- creating products table

DROP TABLE IF EXISTS products;
CREATE TABLE products (
                        product_id VARCHAR(25) PRIMARY KEY,
                        product_name VARCHAR(255),
                        Price FLOAT,
                        cogs FLOAT
);



-- creating orders table

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
                        order_id VARCHAR(25) PRIMARY KEY,
                        order_date DATE,
                        customer_id VARCHAR(25),  -- this is a foreign key from customers(customer_id)
                        state VARCHAR(25),
                        category VARCHAR(25),
                        sub_category VARCHAR(25),
                        product_id VARCHAR(25),   -- this is a foreign key from products(product_id)
                        price_per_unit FLOAT,
                        quantity INT,
                        sale FLOAT,
                        seller_id VARCHAR(25),    -- this is a foreign key from sellers(seller_id)
    
                        CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
                        CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),    
                        CONSTRAINT fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);



-- creating returns table

DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
                        order_id VARCHAR(25),
                        return_id VARCHAR(25),
                        CONSTRAINT pk_returns PRIMARY KEY (order_id), -- Primary key constraint
                        CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);



-- Q1 Find top 5 states by total orders where each state sale is greater than average orders across orders

Select
		count(order_id) as total_orders,
		state,
		sum(sale) as total_sale 
from orders
group by state
Having sum(sale) > (select avg(sale) as average_sale from orders)
order by total_orders desc
limit 5

/* -- Q2 Find the details of the top 5 products with the highest total sales, 
where the total sale for each product is greater than the average sale across all products.
*/

Select product_id,
       sum(sale) as total_sales
from orders
group by product_id
having sum(sale)> (select avg(sale) as average_sale from orders)
order by total_sales desc
limit 5

or

Select 
		product_id,
       sum(sale) as total_sales
from orders
group by product_id
having sum(sale) > (select 
							avg(total_sales) 
					from 
						(
						Select
								product_id,
			       				sum(sale) as total_sales
								from orders
								group by product_id
						) as average_sale)  
order by total_sales desc
limit 5

--using cte
	
With cte1
as
(
	Select 
			product_id,
       		sum(sale) as total_sales
from orders
group by product_id
), average_sale as (
					Select avg(total_sales) as avg_sale from cte1
				)
Select 
    product_id,
    total_sales
from 
    cte1
where 
    total_sales > (SELECT avg_sale FROM average_sale)
order by total_sales DESC
limit 5;

/* -- Q3 List all orders along with the product details(product name, price) 
and seller details (seller_name) for each order.
	*/

Select * from products
Select * from sellers
Select * from orders

Select 	o.order_id,
		p.product_id,
		s.seller_id,
		p.product_name,
		s.seller_name,
		p.price
from orders as o
join products as p
on o.product_id = p.product_id
join sellers as s
on o.seller_id = s.seller_id

-- Q4 Find the total sales amount for each category

Select  category,
		sum(sale) as total_sale
from orders
where category is not null
group by category
order by total_sale desc

-- Q5 List all customers who have made returns along with the number of returns made by each customer

Select  o.customer_id,
		count(r.return_id) as number_of_returns
from orders as o
join returns as r
on o.order_id = r.order_id
group by o.customer_id
order by number_of_returns desc;

-- Q6 Find the average price of products sold by each seller

Select * from products
Select * from sellers

Select 
		p.product_name,
		p.product_id,
		s.seller_name,
		s.seller_id,
		avg(p.price) as avg_price
From orders as o
join products as p
on o.product_id = p.product_id
join sellers as s
on o.seller_id = s.seller_id
group by p.product_name, s.seller_name, p.product_id, s.seller_id

-- Q7 Identify the top 3 sellers based on the total sales amount.

Select 
		s.seller_name,
		s.seller_id,
		sum(o.sale) as total_sales
from orders as o
join sellers as s
on o.seller_id = s.seller_id
Group by s.seller_name, s.seller_id
order by total_sales
limit 3;

--Q8 List all orders where the quantity sold is greater than the average quantity sold across all orders.

Select 
		order_id,
		sum(quantity) as total_quantity 
from orders
group by order_id
having sum(quantity) > (select avg(quantity) from orders)
order by total_quantity desc

-- Q9 find the total sales amount for each category in each state

Select
		state,
		category,
		sum(sale) as total_sales
from orders
group by state, category
order by total_sales desc

-- Q10 List the products that have not been sold yet

Select
	p.product_id,
	p.product_name
from products as p
left join orders as o
on o.product_id = p.product_id
where o.product_id is null;

-- Q11 Find the total sales amount for each seller, excluding the sales amount for orders with returns

Select
		o.seller_id,
		sum(sale) as total_sales
from orders as o
left join returns as r
on r.order_id = o.order_id
group by o.seller_id
order by total_sales

-- Q12 Identify the customers who have made orders in more than one state

Select  o.customer_id,
		c.customer_name
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by o.customer_id, c.customer_name
having count(distinct o.state)> 1

-- Case Statement

/* --Q13 Classify orders by quantity: 
Categorize orders as 'low', 'medium', or 'high' based on the quantity ordered
quantity > 10 'high quantity'
quantity between 3 and 10 'medium quantity'
quantity < 3 'low price'
*/
Select * from orders

select min(quantity) from orders

select max(quantity) from orders

select avg(quantity) from orders

Select *,
		Case
			when quantity > (select avg(quantity) from orders) then 'High Quantity'
			when quantity = (select avg(quantity) from orders) then 'Medium Quantity' 
			else 'Low Quantity'
		End as Quantity_ordered
from orders
	
/* -- Q14 Categorize products by price range:
Classify products as 'low', 'medium', or 'high' based on their prices 
price > 1000 'high price'
price between 60 and 1000 'medium price'
price > 68 'low price'
	*/

Select * from products

select min(price) from products

select max(price) from products

select avg(price) from products


Select *,
		case
			when price > (select avg(price) from products) then 'high price product'
			when price = (select avg(price) from products) then 'medium price product'
			else 'low price product'
		End as product_category
from products
order by price desc;

or 

Select *,
		case
			when price > 1000 then 'high price product'
			when price between 68 and 1000 then 'medium price product'
			else 'low price product'
		End as product_category
from products
order by price desc;

/* --Q15 Identify returning customers: 
Label customers as "returning" if they have placed more than one return; 
otherwise, mark them as 'new'

-- if return >1 then 'returning' else new_cs
-- How many orders customers have placed
-- How many orders have customers returned join the return table with the orders table
-- Customer name joins with customers and orders table
*/

Select * from orders;

Select * from returns;

Select * from customers;

-- how many orders customers has placed

Select  customer_id,
		count(order_id) as total_orders
from orders
group by customer_id
order by total_orders desc;

-- how many orders customers has returned join return table with  orders table

Select 
		o.customer_id,
		count(r.return_id) as total_returns,
		count(o.order_id) as total_orders
from orders as o
left join returns as r
on
r.order_id = o.order_id
group by o.customer_id
order by total_orders desc;

-- cutomers name join with customers and orders table

Select
		o.customer_id,
		c.customer_name,
		count(r.return_id) as total_returns,
		count(o.order_id) as total_orders
from orders as o
left join customers as c
on o.customer_id = c.customer_id
left join returns as r
on r.order_id = o.order_id
group by o.customer_id, c.customer_name
order by total_orders desc;

-- if return >1 then 'returning' else new_cs	

Select 
		o.customer_id,
		c.customer_name,
		count(r.return_id) as total_returns,
		count(o.order_id) as total_orders,
	case
		when count(r.return_id) > 1 then 'returning_cs'
		else 'new_cs'
	End
from orders as o
left join customers as c
on o.customer_id = c.customer_id
left join returns as r
on r.order_id = o.order_id
group by o.customer_id, c.customer_name

/* -- Q16 Determine seller performance: 
Evaluate sellers as "top Performers" if their total sales amount exceeds the average sales amount; 
otherwise, classify them as "Average Performer" 
*/

SELECT 
    s.seller_id,
    s.seller_name,
    SUM(o.sale) AS total_sales,
    CASE
        WHEN SUM(o.sale) > (
            SELECT AVG(total_sales) 
            FROM (
                SELECT SUM(sale) AS total_sales
                FROM orders
                GROUP BY seller_id
            ) AS subquery
        ) THEN 'Top Performer'
        ELSE 'Average Performer'
    END AS performance
FROM 
    orders o
JOIN 
    sellers s ON o.seller_id = s.seller_id
GROUP BY 
    s.seller_id, s.seller_name
order by total_sales desc;

OR
	
-- With cte

with Total_sale
as (
		Select
				s.seller_name,
				s.seller_id,
				sum(o.sale) as total_sales
		from orders o
		join sellers s
		on s.seller_id = o.seller_id
		group by s.seller_name, s.seller_id
	),
Averagae_sale 
as (
		Select 
		avg(total_sales) 
		from Total_sale
	)
Select
		ts.seller_name,
		ts.seller_id,
		ts.total_sales,
	Case
		when ts.total_sales > (Select avg(total_sales) from Total_sale) then 'Top Performer'
		Else 'Average Performer'
	End as performance
from Total_sale as ts
Order by ts.total_sales desc;

-- Window Functions

-- Q17 Ranking top 5 products by sales:

Select *
	from
	( 
		Select
				product_id,
				sum(sale) as total_sale,
				rank() over(order by sum(sale) desc) as rn
		from orders
		group by product_id
	) as subquery
where rn<=5

-- Q18 Find the top 3 products based on total_sales, along with their sales figures.

Select *
	from
	(
		Select 
				p.product_id, 
				p.product_name,
				sum(o.sale) as total_sales,
				rank() over (order by sum(o.sale) desc) as ranking,
				row_number() over (order by sum(o.sale) desc) as RN,
				dense_rank() over (order by sum(o.sale) desc) as DS
	from orders o
	left join products p
	on p.product_id = o.product_id
	group by 1, 2
	) 
where ranking <= 3
	
/* -- Q19 Identifying customer loyalty:
Rank customers based on the  total number of orders placed, 
showing their rank the corresponding customer id and the customer's full name
*/

Select 
		c.customer_id,
		c.customer_name,
		count(o.order_id) as total_orders,
		rank() over(order by count(o.order_id) desc) as Customer_Rank
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by 1,2