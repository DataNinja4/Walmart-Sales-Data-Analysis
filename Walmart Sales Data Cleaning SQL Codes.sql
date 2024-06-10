-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- ---- FEATURE ENGINEERING --  ------------------
-- Create a New column and call it "time_of_day" --  -----

-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add a new column called 'day'  column --
SELECT
	date,
	DAYNAME(date) 
FROM sales;

ALTER TABLE sales ADD COLUMN day VARCHAR(10);

UPDATE sales
SET day = DAYNAME(date);


-- Add another column and call it 'month' --
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month VARCHAR(10);

UPDATE sales
SET month = MONTHNAME(date);

-- Let's do some EDA on the products -- 
-- How many  products does the data have?
SELECT
	COUNT(DISTINCT product_line)
FROM sales;
-- There are 6 procudt lines -- 

-- Which product sells the most --
SELECT
	SUM(quantity) as qty,
    product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- Electronic accessories has the highest number of sales -- 

--  Which product brings in more revenue -- 
SELECT 
      SUM(quantity * unit_price) AS revenue,
      product_line
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- We see that Food and Beverages gave us the highest revenue while Electronic accessories gave us he lowest revenue --
-- This shows that higher sales isn't always equals higher revenue because Electronic accessories had the highest number of sales --
-- But it gave us the lowest amount of money --

-- What is the total revenue by month
SELECT
	month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month 
ORDER BY total_revenue DESC;

-- We see that January had the highest revenue -- 
-- We might have thought that revenue in january might not be highest because customers would have spent a lot on christmas shopping -- 

-- What is the total revenue by day
SELECT
	day,
	SUM(total) AS total_revenue
FROM sales
GROUP BY day 
ORDER BY total_revenue DESC;

-- We see we get the highest sales  on saturdays --

-- What is the city with the largest revenue and on which day it has the highest revenue?
WITH city_revenue AS (
    SELECT
        city,
        SUM(total) AS total_revenue
    FROM sales
    GROUP BY city
    ORDER BY total_revenue DESC
    LIMIT 1
)
SELECT
    s.city,
    s.day,
    SUM(s.total) AS daily_total
FROM sales s
JOIN city_revenue cr ON s.city = cr.city
GROUP BY s.city, s.day
ORDER BY daily_total DESC
LIMIT 1;

-- We see that Naypyitaw has the highest revenue and this also happens on saturdays --

-- Categorise each product line and give it a name as either 'GOOD' or "BAD' depending on if the sales quantity is above or below the average sales --

SELECT 
	ROUND(AVG(quantity), 2) AS avg_qnty
FROM sales;

SELECT
	product_line,
	(CASE
		WHEN AVG(quantity) > 5.50 THEN "Good"
        ELSE "Bad"
    END) AS remark
FROM sales
GROUP BY product_line;

--  Sales from Food & Beverages and Fashion accessories were below average --
-- But sales from Health& Beauty, Sports and Travle and Home& Lifestyle were above  average --

-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- It is not surprising that the FEmale gender bought more fashion accessories --
-- However. it is surprising that the Male customers bought more Health and beauty products than the female customers --


-- CUstomers -----
-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;
-- There are 2 classes of customers --

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;
-- Our dataset shows 3 payment methods --


SELECT
	 payment,
     SUM(total) as tot_revenue
FROM sales
GROUP BY payment
ORDER BY tot_revenue DESC;
-- We see that customers who pay with cash tend to spend more --

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- There is no much difference between the gender of our customers --

-- Which customer gives us the most revenue --
SELECT
     customer_type,
     SUM(total) AS total
FROM sales
GROUP BY customer_type
ORDER BY total DESC;
-- We get more money from sales from "MEMBER SUATOMERS' than from our "NORMAL CUSTOMERS"

-- WHich time  of the day has the highest sales --
SELECT 
      time_of_day,
      SUM(quantity) AS qty
FROM sales
GROUP BY time_of_day
ORDER BY qty DESC;

-- WE have the highest number of  sales in the EVenings --

-- Which time_of_day has highest revenue --
SELECT 
      time_of_day,
      SUM(total) AS total
FROM sales
GROUP BY time_of_day
ORDER BY total DESC;
-- Evenings also had the highest revenue --
-- We can hypothesize that there is a positive correlation between the number of sales and the revenue --








