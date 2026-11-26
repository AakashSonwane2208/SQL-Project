DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
  transactions_id INT,
  sale_date DATE,
  sale_time TIME,
  customer_id INT ,
  gender VARCHAR(10),
  age INT,
  category VARCHAR(15),
  quantity INT,
  price_per_unit INT,
  cogs FLOAT,
  total_sale INT
);

-- Determine total number of records in dataset
SELECT COUNT(*) FROM retail_sales;

SELECT DISTINCT COUNT(customer_id) FROM retail_sales;

-- Find out unique product category from retail_sales
SELECT DISTINCT(category) FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
     transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR
	 age IS NULL OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

-- Count null from each column 

SELECT
SUM(CASE WHEN transactions_id IS NULL THEN 1 ELSE 0 END) as transactions_id_Null,
SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) as sale_date_Null,
SUM(CASE WHEN sale_time IS NULL THEN 1 ELSE 0 END) as sale_time_Null,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as customer_id_Null,
SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) as gender_Null,
SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) as age_time_Null,
SUM(CASE WHEN quantiy IS NULL THEN 1 ELSE 0 END) as quantity_Null,
SUM(CASE WHEN price_per_unit IS NULL THEN 1 ELSE 0 END) as price_per_unit_Null,
SUM(CASE WHEN cogs IS NULL THEN 1 ELSE 0 END) as cogs_Null,
SUM(CASE WHEN total_sale IS NULL THEN 1 ELSE 0 END) as total_sale 
FROM retail_sales;

-- DELETE the null values
USE retail_store;
DELETE FROM retail_sales
WHERE
     transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR
	 age IS NULL OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;

-- Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:(Pending)
SELECT * FROM retail_sales
WHERE 
category = 'Clothing'
AND
TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
AND 
quantiy >=4;

-- Q3. Write a SQL query to calculate the total sales (total_sale) for each category.:
SELECT 
	category, SUM(total_sale) as Total_sale,
    COUNT(8) as Total_Orders
FROM retail_sales
GROUP BY category
ORDER BY 1 DESC;

-- Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT 
   ROUND(AVG(age),2)as Avg_age_Customers
FROM retail_sales
WHERE category = 'beauty';

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT * FROM retail_sales
WHERE total_sale> 1000;

-- Q6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
SELECT 
	category,
    gender,
    COUNT(transactions_id) as Total_Transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY 1,2;

-- Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
SELECT 
     Year_,
     Month_,
     Avg_sale     
FROM
(
SELECT 
    EXTRACT(YEAR FROM sale_date) as Year_,
    EXTRACT(MONTH FROM sale_date) as Month_,
    AVG(total_sale) as Avg_sale,
    RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) Desc) AS Best_rank
FROM retail_sales
GROUP BY Year_, Month_
-- ORDER BY Avg_sale DESC
) as t1
  Where Best_rank = 1;
  
  
SELECT 
    EXTRACT(YEAR FROM sale_date) as Year_,
    EXTRACT(MONTH FROM sale_date) as Month_,
    AVG(total_sale) as Avg_sale
    --  RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) Desc) AS Best_rank
FROM retail_sales
GROUP BY Year_, Month_
ORDER BY Avg_sale DESC;

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales:
SELECT
     customer_id,
     SUM(total_sale) as Total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY Total_sales DESC
Limit 5;

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT 
     category,
     COUNT(DISTINCT customer_id) as Unique_Customers
FROM retail_sales
GROUP BY category;

-- Q10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

WITH result as 
(
 SELECT *,
 CASE
	WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	WHEN EXTRACT(HOUR FROM sale_time) > 17 THEN 'Evening'
 END as Shifts
 FROM retail_sales
)

Select
      shifts,
      COUNT(transactions_id) as Number_Orders
FROM result
GROUP by shifts
ORDER BY 2 Desc;









