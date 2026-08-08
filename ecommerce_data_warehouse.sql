CREATE DATABASE ecommerce_dwh;
use ecommerce_dwh;


-- STAGING LAYER


create table stg_customers(customer_id int,customer_name varchar(50),gender varchar(20),age int,city varchar(30),state varchar(40),country varchar(50));

create table stg_orders(order_id int,customer_id int,product_id int ,order_date date, quantity int,unitprice int,total_amount int);

select * from stg_customers;
SELECT COUNT(*) AS total_rows
FROM stg_orders;


select * from stg_orders;  
select count(*) from stg_customers;
select count(*) from stg_orders;
select * from stg_orders;


select order_id,count(*) as duplicates
from stg_orders 
group by order_id 
having count(*) > 1;                                                                                                                                                                                                                                                                                                                                                                                                     


create table stg_products(product_id int,product_name varchar(30),category varchar(30),cost_price int,selling_price int);

select * from stg_products;

desc stg_products;

-- ODS LAYER

create schema ods;

CREATE TABLE ODS.Customers
(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(30),
    state VARCHAR(40),
    country VARCHAR(50)
);


CREATE TABLE ODS.Products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(30),
    category VARCHAR(30),
    cost_price INT,
    selling_price INT
);


CREATE TABLE ODS.Orders
(
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    unitprice INT,
    total_amount INT);


-- ODS ETL
-- LOAD DATA FROM STAGING INTO ODS

INSERT INTO ODS.Customers
SELECT DISTINCT
       customer_id,
       TRIM(customer_name),
       TRIM(gender),
       age,
       TRIM(city),
       TRIM(state),
       TRIM(country)
FROM stg_Customers
WHERE customer_id IS NOT NULL;



INSERT INTO ODS.Products
SELECT DISTINCT
       product_id,
       TRIM(product_name),
       TRIM(category),
       cost_price,
       selling_price
FROM stg_Products
WHERE product_id IS NOT NULL;


INSERT INTO ODS.Orders
SELECT DISTINCT
       order_id,
       customer_id,
       product_id,
       order_date,
       quantity,
       unitprice,
       total_amount
FROM stg_Orders
WHERE order_id IS NOT NULL;


-- ODS VALIDATION 
select * from ods.customers;

select * from ods.products;

select * from ods.orders;

 -- DUPLICATE CHECK
 SELECT customer_id,COUNT(*)
FROM ODS.Customers
GROUP BY customer_id
HAVING COUNT(*)>1;

SELECT product_id,COUNT(*)
FROM ODS.Products
GROUP BY product_id
HAVING COUNT(*)>1;

SELECT order_id,COUNT(*)
FROM ODS.Orders
GROUP BY order_id
HAVING COUNT(*)>1;

-- NULL CHECK

SELECT *
FROM ODS.Customers
WHERE customer_id IS NULL;

SELECT *
FROM ODS.Products
WHERE product_id IS NULL;

SELECT *
FROM ODS.Orders
WHERE order_id IS NULL;



-- DATA WAREHOUSE LAYER

CREATE TABLE dim_customer
(
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(50),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(30),
    state VARCHAR(40),
    country VARCHAR(50)
);


INSERT INTO dim_customer
(
    customer_id,
    customer_name,
    gender,
    age,
    city,
    state,
    country
)
SELECT
    customer_id,
    customer_name,
    gender,
    age,
    city,
    state,
    country
FROM ods.customers;

SELECT * FROM dim_customer;

select * from ods.customers;

CREATE TABLE dim_product
(
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2)
);

INSERT INTO dim_product
(
    product_id,
    product_name,
    category,
    cost_price,
    selling_price
)
SELECT
    product_id,
    product_name,
    category,
    cost_price,
    selling_price
FROM ods.products;

select * from dim_product;

CREATE TABLE dim_date
(
    date_key INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    day_name VARCHAR(20)
);

INSERT INTO dim_date
(
    order_date,
    day,
    month,
    month_name,
    quarter,
    year,
    day_name
)
SELECT DISTINCT
    order_date,
    DAY(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    QUARTER(order_date),
    YEAR(order_date),
    DAYNAME(order_date)
FROM ods.orders;

select * from dim_date;



-- FACT TABLE

CREATE TABLE fact_sales
(
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_key INT,
    product_key INT,
    date_key INT,
    quantity INT,
    unitprice DECIMAL(10,2),
    total_amount DECIMAL(10,2),

    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);



INSERT INTO fact_sales
(
    customer_key,
    product_key,
    date_key,
    quantity,
    unitprice,
    total_amount
)
SELECT
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    o.quantity,
    o.unitprice,
    o.total_amount
FROM ods.orders o	
JOIN dim_customer dc
ON o.customer_id = dc.customer_id
JOIN dim_product dp
ON o.product_id = dp.product_id
JOIN dim_date dd
ON o.order_date = dd.order_date;



SELECT * FROM fact_sales;


-- DATAMART


CREATE VIEW sales_datamart AS
SELECT
    fs.sales_key,
    dc.customer_name,
    dc.city,
    dp.product_name,
    dp.category,
    dd.order_date,
    dd.month_name,
    dd.year,
    fs.quantity,
    fs.unitprice,
    fs.total_amount
FROM fact_sales fs
JOIN dim_customer dc
ON fs.customer_key = dc.customer_key
JOIN dim_product dp
ON fs.product_key = dp.product_key
JOIN dim_date dd
ON fs.date_key = dd.date_key;


SELECT * FROM sales_datamart;
select count(*) from sales_datamart;


-- BUSINESS ANALYSIS QUERIES

-- SALES ANALYSIS


-- 1. What is the total revenue generated?
select sum(total_amount) as total_revenue_generated
from sales_datamart;

-- 2. How many orders were placed?
select count(*) as total_orders
from sales_datamart;

-- 3. How many unique customers purchased?
select count(distinct customer_name) as unique_customers
from sales_datamart;

-- 4.What is the average value of each order?
select avg(total_amount) as avg_value
from sales_datamart;

-- 5.Which order had the highest value?
select max(total_amount) as higest_value
from sales_datamart;

-- 6.Which order had the lowest value?
select min(total_amount) as lowest_value
from sales_datamart;

-- 7.How many products were sold?
select sum(quantity) as total_products_sold
from sales_datamart;

-- 8.Which product category generated the most revenue?
select category,sum(total_amount) as total_revenue
from sales_datamart
group by category
ORDER BY total_revenue DESC;

-- 9.Which city generated the highest revenue?
select city,sum(total_amount) as higest_city_revenue
from sales_datamart
group by city
order by higest_city_revenue DESC;

-- 10.How much revenue was generated each year?
SELECT 
    year, SUM(total_amount) AS highest_revenue_of_The_year
FROM
    sales_datamart
GROUP BY year
ORDER BY highest_revenue_of_The_year desc;

select year,count(year)
from sales_datamart
group by year;


-- CUSTOMER ANALYSIS

-- 1. Which customers generated the highest revenue? (top 10)
select customer_name,sum(total_amount) as highest_revenue
from sales_datamart
group by customer_name 
order by highest_revenue desc
limit 10;

-- 2. How much revenue did each customer contribute?
SELECT
    customer_name,
    SUM(total_amount) AS total_sales
FROM sales_datamart
GROUP BY customer_name;

-- 3. Which customers placed the most orders?
SELECT
    customer_name,
    COUNT(*) AS total_orders
FROM sales_datamart
GROUP BY customer_name
ORDER BY total_orders DESC;

-- 4.On average, how much does each customer spend?
select customer_name,avg(total_amount) as avg_spend
from sales_datamart
group by customer_name;

-- 5. How many customers belong to each city?
select city,count(distinct customer_name) as total
from sales_datamart
group by city;




-- 6.Which customers spent more than ₹50,000?
select customer_name,sum(total_amount) as more
from sales_datamart
group by customer_name
having sum(total_amount) > 50000
order by more desc;

-- 7.How many products did each customer purchase?
SELECT
    year,
    SUM(total_amount) AS total_revenue
FROM sales_datamart
GROUP BY year
ORDER BY total_revenue DESC;

-- 8.What is the average quantity purchased by each customer?
SELECT
    customer_name,
    AVG(quantity) AS average_quantity
FROM sales_datamart
GROUP BY customer_name;

-- 9. Who are the customers with the lowest spending?
SELECT
    customer_name,
    SUM(total_amount) AS total_sales
FROM sales_datamart
GROUP BY customer_name
ORDER BY total_sales ASC
LIMIT 10;



-- PRODUCT ANALYSIS

-- 1.Which products generated the highest revenue?
select product_name,sum(total_amount) as highest
from sales_datamart
group by product_name
order by highest desc;

-- 2.Which are the Top 5 selling products?
select * from sales_datamart;
select product_name,sum(total_amount) as hig
from sales_datamart 
group by product_name
order by hig desc
limit 5;

-- 3.Which products generated the lowest revenue?
select * from sales_datamart;
select product_name,sum(total_amount) as low
from sales_datamart 
group by product_name
order by low asc
limit 5;

-- 4. Which product sold the highest quantity?
select product_name,sum(quantity) as hig
from sales_datamart
group by product_name 
order by hig desc;

-- 6. What is the average revenue generated per sale for each product?
SELECT
    product_name,
    AVG(total_amount) AS average_sales
FROM sales_datamart
GROUP BY product_name;

-- 7. Which category generated the highest revenue
select category,sum(total_amount) as hig
from sales_datamart
group by category
order by hig desc;

-- 8.Which category sold the highest number of product
SELECT
    category,
    SUM(quantity) AS total_quantity
FROM sales_datamart
GROUP BY category
ORDER BY total_quantity DESC;


-- 9. How many different products are available in each category?
SELECT
    category,
    COUNT(DISTINCT product_name) AS total_products
FROM sales_datamart
GROUP BY category;














