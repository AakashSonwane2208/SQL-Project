database monday_coffee

DROP TABLE IF EXISTS city;
CREATE TABLE city
(
	city_id INT PRIMARY KEY,
	city_name VARCHAR(100),
	population BIGINT,
	estimated_rent FLOAT,
	city_rank INT
)

DROP TABLE IF EXISTS sales
CREATE TABLE sales
(
	sale_id INT ,
	sale_date DATE,
	product_id INT,
	customer_id INT,
	total FLOAT,
	rating INT,
	constraint fk_products foreign key(product_id) references products(product_id),
	constraint fk_customers foreign key(customer_id) references customer(customer_id)
)

DROP TABLE IF EXISTS customer;
CREATE TABLE customer
(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(100),
	city_id INT,
	constraint fk_city foreign key(city_id) references city(city_id)
)

DROP TABLE IF EXISTS products;
CREATE TABLE products
(
	product_id int primary key,
	product_name varchar(100),
	price float
)

select * from city
select * from customer
select * from products
select * from sales


/* 	Reports & Data Analysis:
	Q.1 Coffee Consumers Count
	How many people in each city are estimated to consume coffee, given that 25% of the population does? */
	
	select
		city_name, round(population *0.25/1000000,2) as coffee_consumer_in_Millions, city_rank
	from city
	order by 2 desc

/*	Q.2
	Total Revenue from Coffee Sales
	What is the total revenue generated from coffee sales across all cities in the last quarter of 2023? */

	select 
		c.city_name, sum(s.total)
	from city c
	join customer cust
	on c.city_id = cust.city_id
	join sales s
	on s.customer_id = cust.customer_id 
	where extract(year from s.sale_date) = 2023 and extract(quarter from s.sale_date) = 4
	group by 1
	order by 2 desc
	
/*	Q.3 Sales Count for Each Product
	How many units of each coffee product have been sold? */
	select p.product_name,count(sale_id) as Products_count
	from products p
	join sales s
	on p.product_id = s.product_id
	group by 1
	order by 2 desc

/* 	Q.4 Average Sales Amount per City
    What is the average sales amount per customer in each city?
    city abd total sale
    no cx in each these city */
	select
		c.city_name,sum(s.total),
		count(distinct cust.customer_id),
		(sum(s.total)/ count(distinct cust.customer_id))::int as avg_sale
	from city c
	join customer cust
	on cust.city_id = c.city_id
	join sales s
	on s.customer_id = cust.customer_id
	group by 1
	order by 2 desc

/* 	Q.5 City Population and Coffee Consumers (25%)
 	Provide a list of cities along with their populations and estimated coffee consumers.
	return city_name, total current cx, estimated coffee consumers (25%) */
	select c.city_name,
		round((c.population*0.25/1000000),2) as coffee_consumer_in_Millions,
		count(distinct s.customer_id)
	from city c
	join customer cust
	on cust.city_id = c.city_id
	join sales s
	on s.customer_id = cust.customer_id
	group by 1 ,2
	order by 2 desc

/*  Q6 Top Selling Products by City
	What are the top 3 selling products in each city based on sales volume? */
	With results as
	(
		select c.city_name,
			p.product_name,
			count(product_name) as count_of_products,
		    row_number() over(partition by c.city_name order by count(product_name) desc) as row_num
		from city c
		join customer cust
		on c.city_id = cust.city_id
		join sales s
		on s.customer_id = cust.customer_id
		join products p
		on p.product_id = s.product_id
		group by 1, 2
		order by 1,3 desc
	)

select * from results
where row_num in(1,2,3)

/*	Q.7 Customer Segmentation by City
	How many unique customers are there in each city who have purchased coffee products? */
	select
		c.city_name, count(distinct(s.customer_id)) as unique_cust,
		count(s.product_id) as purchased_products
	from city c
	join customer cust
	on cust.city_id = c.city_id
	join sales s
	on s.customer_id = cust.customer_id
	group by 1
	order by 3 desc


/*	Q.8 Average Sale vs Rent
	Find each city and their average sale per customer and avg rent per customer*/
	select
	c.city_name,
	round((sum(s.total)/count(distinct s.customer_id))::numeric,2) as avg_sale_per_cust,
	(sum(c.estimated_rent)/count(s.customer_id))as avg_rent_per_cust
	from city c
	join customer cust
	on c.city_id = cust.city_id
	join sales s
	on cust.customer_id = s.customer_id
	group by 1
	order by 2 desc


/*	Q.9 Monthly Sales Growth
	Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city8?*/
	with results as
	(
		select 
			c.city_name, 
			extract(year from s.sale_date) as year,
			extract(month from s.sale_date) as month,
			sum(s.total) as total_sale,
			lag(sum(s.total)) over(order by c.city_name, extract(year from s.sale_date), extract(month from s.sale_date) ) as previous_total_sale
	
	from city c
	join customer cust
	on cust.city_id = c.city_id
	join sales s
	on s.customer_id = cust.customer_id
	group by 1,2,3
	)
	
	select *,round(((total_sale-previous_total_sale)/previous_total_sale*100)::numeric,2) as growth
	from results
	order by 1,2,3

/*	Q.10 Market Potential Analysis
	Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer*/
	with results as 
	(
		select
			distinct c.city_name as city,
			sum(s.total) as total_sale,
			c.estimated_rent as Total_Rent,
			(count(distinct cust.customer_id)) as Total_cust_count,
			(c.population*0.25)::int as estimated_coffee_cust,
			COUNT(DISTINCT DATE_TRUNC('month', s.sale_date)) AS month_count
			 -- count(distinct extract(month from s.sale_Date)::numeric) as month
		from city c
		join customer cust
		on cust.city_id = c.city_id
		join sales s
		on s.customer_id = cust.customer_id
		group by 1,3,5
		order by 2 desc
	)
	
	select city, total_sale, (total_rent*month_count) as total_rent, Total_cust_count, estimated_coffee_cust
	from results




