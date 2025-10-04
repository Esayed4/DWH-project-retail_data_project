# Retail Data Warehouse Project

## 📑 Contents
1. [Project Overview](#-project-overview)
2. [Resources](#-resources)
3. [Requirements](#-requirements)
4. [Folder Structure](#-folder-structure)
5. [Design OLAP](#-design-olap)
6. [ETL Process](#-etl-process)
7. [Setup Instructions](#-setup-instructions)
8. [Areas of Improvement](#-areas-of-improvement)


## Project Overview:
Ecommerce website dataset is ready for you to build data warehouse for to answer business questions. The project consist of 3 main phases.
1. Building data warehouse model to serve business queries.
2. Building ETL pipeline to land data into the warehouse.
3. Run analytical queries to answer business questions

## Resources:
Dataset is used from [this](https://medium.com/@williamong1400/project-1-solving-problem-in-e-commerce-with-data-ac7ed38d7b4) series. I just played around with it using pandas, numpy and [sdv](https://github.com/sdv-dev/SDV) to transform the limited files into an endless stream of data. I then created a mysql database to serve as a destination for the generated data - to act as an operational data store if you can say so -.

## Requirements:
-	Design Data warehouse schema.
-	Build ETL pipeline to load data into DW
-	Answer Below business questions:
    1.  When is the peak season of our ecommerce ?
    2.	What time users are most likely make an order or using the ecommerce app?
    3.	What is the preferred way to pay in the ecommerce?
    4.	How many installment is usually done when paying in the ecommerce?
    5.	What is the average spending time for user for our ecommerce?
    6.	What is the frequency of purchase on each state?
    7.	Which logistic route that have heavy traffic in our ecommerce?
    8.	How many late delivered order in our ecommerce? Are late order affecting the customer satisfaction?
    9.	How long are the delay for delivery / shipping process in each state?
    10.	How long are the difference between estimated delivery time and actual delivery time in each state?

##  Folder Structure
Retail Data Warehouse Project:.

```text
Retail Data Warehouse Project
│   readme.md
│
├── data
│   ├── feedback_dataset.csv     
│   ├── order_dataset.csv        
│   ├── order_item_dataset.csv   
│   ├── payment_dataset.csv      
│   ├── product_dataset.csv      
│   ├── seller_dataset.csv       
│   └── user_dataset.csv
│
├── db_scripts
│   ├── database.sql
│   └── retail_data_project_OLTP_relationship.drawio
│
├── Extract data and check
│   ├── Data Validation
│   │   ├── create the validation log table.sql
│   │   ├── Data Validation after Extraction.txt
│   │   ├── Data validation Compare Data Type.sql
│   │   └── Data validation Count Rows.sql
│   │
│   └── Extract
│       └── Extract Script.sql
│
├── MSSQL generator
│   ├── mix_generator.py
│   └── tempCodeRunnerFile.py
│
├── OLAP design and code script
│   ├── create the OLAP script.sql
│   ├── retail_data_project_OLAP.drawio
│   └── retail_data_project_OLAP.drawio.png
│
└── Transformation and load
    ├── insert values into date dimension.sql
    ├── transformation and load data into bridge.sql
    ├── Transformation and load Script for Dimensions.sql
    └── Transformation and loading the data into fact Table.sql
```
ذذ   
##  Design OLAP
The DWH follows a **star schema** with:
- **Dimensions**:  
  - `dim_user` (users)    SCD 2
  - `dim_seller` (sellers)  SCD 2
  - `dim_product` (products)  
  - `dim_payment` (payments)  
  - `dim_feedback` (feedbacks)  
  - `dim_date` (calendar for time-based analysis)  
- **Fact Table**:  
  - `fact_order` → stores order metrics (status, total amount, durations, arrival flag)  
- **Bridge Table**:  
  - `dim_order_items_bridge` → handles many-to-many between orders and products  <img width="682" height="1372" alt="retail_data_project_OLAP  drawio" src="https://github.com/user-attachments/assets/52a9016f-e31c-4b78-9528-695d5aa458f4" />

##  ETL Process
The ETL is split into 3 main stages:

1. **Extract**  
   - Copy raw data from `online_store` (OLTP) to `staging` schema.  
   - Validate row counts between OLTP and staging.  

2. **Transform**  
   - Clean and standardize values.  
   - Generate surrogate keys (e.g. `user_sk`, `seller_sk`, `product_sk`).  
   - Build derived fields (durations, on-time delivery flags).  

3. **Load**  
   - Insert transformed data into dimension tables.  
   - Update foreign keys in `fact_order`.  
   - Load bridge table for order items.  
   - Validate totals and key relationships.

![Screenshot 2025-10-04 172638](https://github.com/user-attachments/assets/5e825404-4a42-461b-8099-79c536c8b76e)

## 🚀 Setup Instructions
1. Clone this repo:
   ```bash
   git clone https://github.com/Esayed4/DWH-project-retail_data_project
Open SQL Server Management Studio (SSMS).

Run oltp/create_oltp.sql to create the OLTP schema and load source data.

Run staging/staging_extract.sql to build and populate the staging layer.

Run validation queries (row counts, totals, key integrity).

Run scripts in dwh/ to create dimensions, fact, and bridge tables.

Execute transform_load.sql to populate the warehouse.


## Areas of Improvement
1. **Multiple Data Sources** – Currently, the project uses a single OLTP source. In the future, integrating multiple data sources (e.g., APIs, flat files, or external databases) would create a richer dataset.  
2. **Incremental Loading** – The ETL process is designed as a full load. Implementing incremental or CDC (Change Data Capture) would improve efficiency and scalability.  
3. **SSIS Integration** – Rebuilding the ETL pipeline using SQL Server Integration Services (SSIS) would provide a more enterprise-level, visual, and manageable solution.  
4. **Cloud Deployment** – Migrating the DWH to a cloud platform (Azure Synapse, AWS Redshift, or GCP BigQuery) would make the system more scalable, available, and suitable for real-world use cases.  
 



 
