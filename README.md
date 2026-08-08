# E-Commerce Data Warehouse

## 📌 Project Overview

An end-to-end E-Commerce Data Warehouse project built using MySQL. The project demonstrates data extraction, cleaning, transformation, dimensional modeling, and business analysis using a structured data warehouse architecture.

The data is processed through multiple layers — Staging, ODS, Data Warehouse, and Data Mart — to transform raw e-commerce data into analysis-ready information.

## 🛠️ Technologies Used

- MySQL
- SQL
- ETL
- Dimensional Modeling
- Star Schema

## 🏗️ Data Warehouse Architecture

The project follows a layered data warehouse architecture:

**Source Data → Staging Layer → ODS Layer → Data Warehouse → Data Mart → Business Analysis**

### 1. Staging Layer

Raw e-commerce data is initially loaded into staging tables.

Main staging tables:

- `stg_customers`
- `stg_orders`
- `stg_products`
- `stg_payments`
- `stg_shipping`

### 2. ODS Layer

The ODS layer stores cleaned and structured operational data.

Main ODS tables:

- `ods.customers`
- `ods.products`
- `ods.orders`

Data cleaning operations such as `TRIM()` and NULL validation are performed during the ETL process.

### 3. Data Warehouse Layer

The data warehouse uses dimensional modeling with:

**Dimension Tables**
- `dim_customer`
- `dim_product`
- `dim_date`

**Fact Table**
- `fact_sales`

Surrogate keys and foreign keys are used to establish relationships between the fact and dimension tables.

### 4. Data Mart

A `sales_datamart` view is created by joining the fact and dimension tables.

This provides an analysis-ready dataset for business queries.

## ⭐ Star Schema

The project follows a Star Schema design where the `fact_sales` table acts as the central fact table and connects to the dimension tables:

- Customer
- Product
- Date

## 🔄 ETL Process

The project follows these major ETL steps:

1. Load raw data into the staging layer.
2. Validate the staging data.
3. Remove unnecessary whitespace using `TRIM()`.
4. Validate NULL values and duplicate records.
5. Load cleaned data into the ODS layer.
6. Create dimension tables using surrogate keys.
7. Load transactional data into the fact table.
8. Create the sales data mart.
9. Perform business analysis using SQL queries.

## 🔍 Data Validation

The project includes validation checks for:

- Duplicate records
- NULL values
- Record counts
- Data consistency
- Primary and foreign key relationships

## 📊 Business Analysis

SQL queries are used to analyze:

- Total revenue
- Highest and lowest revenue
- Revenue by category
- Revenue by city
- Revenue by year
- Customer purchasing behavior
- Product sales performance
- Top-performing products
- Product quantity sold
- Category-level product counts

## 📂 Project Files

- `ecommerce_data_warehouse.sql` — Complete SQL script containing the data warehouse creation, ETL process, dimensional model, data mart, validation, and business queries.

## 🎯 Key Learning Outcomes

- SQL data transformation
- ETL concepts
- Data warehouse architecture
- Dimensional modeling
- Star schema implementation
- Fact and dimension table design
- Data validation
- Business-oriented SQL analysis
