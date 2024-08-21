-- CREATE DATABSE --
CREATE DATABASE sql_project_01;

-- CREATE TABLE --
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

-- Data Exploration & Cleaning -- 
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
	
	

-- Data Exploration --

-- How many sales have?
SELECT COUNT(*) as total_sale FROM retail_sales	

-- How many uniuque customers ?
SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales

-- What are products ?
SELECT DISTINCT category FROM retail_sales

-- Data Analysis & Business Key Problems & Answers

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4	


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty' 

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
 
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift


-- Q.11 Identify the top 3 best-selling categories in terms of total sales and the total number of transactions.

SELECT 
    category,
    SUM(total_sale) AS total_sales,
    COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC
LIMIT 3;

-- Q.12 Calculate the percentage contribution of each category to the total sales of the store.

WITH total_sales AS (
    SELECT SUM(total_sale) AS store_total_sales
    FROM retail_sales
)
SELECT 
    category,
    SUM(total_sale) AS category_sales,
    ROUND((SUM(total_sale) / (SELECT store_total_sales FROM total_sales))::numeric * 100, 2) AS sales_percentage
FROM retail_sales
GROUP BY category
ORDER BY sales_percentage DESC;

-- Q.13 Analyze the purchasing behavior by finding the average quantity sold per transaction across different categories.]

SELECT 
    category,
    ROUND(AVG(quantity), 2) AS avg_quantity_per_transaction
FROM retail_sales
GROUP BY category
ORDER BY avg_quantity_per_transaction DESC;

-- Q.14 Identify categories that have a higher average sale per customer than the overall average sale across all categories.

WITH overall_avg_sale AS (
    SELECT AVG(total_sale) AS overall_avg
    FROM retail_sales
)
SELECT 
    category,
    AVG(total_sale) AS avg_sale_per_customer
FROM retail_sales
GROUP BY category
HAVING AVG(total_sale) > (SELECT overall_avg FROM overall_avg_sale)
ORDER BY avg_sale_per_customer DESC;


-- Q.15 Find the repeat customers (those who have made more than one purchase) and the total number of their transactions.

SELECT 
    customer_id,
    COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(transactions_id) > 1
ORDER BY total_transactions DESC;

-- Q.16 Calculate the total revenue generated by each gender in each category and find out which gender is the highest spender in each category.

SELECT 
    category,
    gender,
    SUM(total_sale) AS total_revenue,
    RANK() OVER (PARTITION BY category ORDER BY SUM(total_sale) DESC) AS revenue_rank
FROM retail_sales
GROUP BY category, gender
ORDER BY category, revenue_rank;

-- Q.17 Identify seasonal trends by finding the total sales for each quarter and comparing them across the years.

SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(QUARTER FROM sale_date) AS quarter,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY year, quarter
ORDER BY year, quarter;

-- Q.18 Find the customers who purchased from multiple categories and calculate the total amount they spent across all categories.

WITH customer_categories AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT category) AS num_categories,
        SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY customer_id
)
SELECT 
    customer_id,
    num_categories,
    total_spent
FROM customer_categories
WHERE num_categories > 1
ORDER BY total_spent DESC;


-- Q.19 Determine the correlation between the age of customers and the total amount they spent.

SELECT 
    age,
    SUM(total_sale) AS total_spent,
    COUNT(customer_id) AS num_transactions
FROM retail_sales
GROUP BY age
ORDER BY total_spent DESC;

-- Q.20 Analyze the sales distribution by age group (e.g., 18-25, 26-35, 36-45, etc.) and identify the age group with the highest sales.

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+' 
    END AS age_group,
    SUM(total_sale) AS total_sales,
    COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY age_group
ORDER BY total_sales DESC;

