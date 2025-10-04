CREATE DATABASE DWH_project_retail_data_project;
USE DWH_project_retail_data_project;

-- ==========================
-- Dimension Tables
-- ==========================

CREATE TABLE dim_date (
    date_id BIGINT PRIMARY KEY,   -- Format: YYYYMMDDHHMM (e.g., 202510022222)
    full_date DATE,
    year INT,
    month INT,
    day INT,
    hour INT,
    minute INT,
    quarter INT,
    week_of_year INT,
    week_of_month INT,
    day_of_year INT,
    day_of_month INT,
    day_of_week INT,
    is_holiday bit
);

CREATE TABLE dim_user (
    user_sk INT PRIMARY KEY IDENTITY(1,1),
    user_id VARCHAR(32),
    user_zip_code INT,
    user_state VARCHAR(50),
    user_city VARCHAR(50),
    start_date DATE,
    end_date DATE,
    is_current bit
);

CREATE TABLE dim_payment (
    payment_sk INT PRIMARY KEY IDENTITY(1,1),
    payment_sequential TINYINT,
    payment_type VARCHAR(50),
    payment_installments TINYINT,
    payment_value FLOAT
);

CREATE TABLE dim_feedback (
    feedback_sk INT PRIMARY KEY IDENTITY(1,1),
    feedback_id VARCHAR(32),
    feedback_score TINYINT,
    feedback_form_sent_date DATE,
    feedback_answer_date DATE
);

CREATE TABLE dim_seller (
    seller_sk INT PRIMARY KEY IDENTITY(1,1),
    seller_id VARCHAR(32),
    seller_zip_code INT,
    seller_state VARCHAR(50),
    seller_city VARCHAR(50),
    start_date DATE,
    end_date DATE,
    is_current bit
);

CREATE TABLE dim_product (
    product_sk INT PRIMARY KEY IDENTITY(1,1),
    product_id VARCHAR(32),
    product_category VARCHAR(50),
    product_photos_qty INT
);

-- ==========================
-- Fact Table
-- ==========================

CREATE TABLE fact_order (
    order_id VARCHAR(32) PRIMARY KEY,
    payment_sk INT,
    feedback_sk INT,
    order_date_id BIGINT,
    approved_date_id BIGINT,
    pickup_date_id BIGINT,
    delivery_date_id BIGINT,
    estimated_delivery_date_id BIGINT,
    user_sk INT,
    duration_between_orderDate_pickupDate INT,
    duration_between_orderDate_approvedDate INT,
    duration_between_orderDate_deliveryDate INT,
    is_order_arrived_on_time bit,
    order_status VARCHAR(50),
    total_amount FLOAT,

    FOREIGN KEY (payment_sk) REFERENCES dim_payment(payment_sk),
    FOREIGN KEY (feedback_sk) REFERENCES dim_feedback(feedback_sk),
    FOREIGN KEY (order_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (approved_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (pickup_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (delivery_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (estimated_delivery_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (user_sk) REFERENCES dim_user(user_sk)
);

-- ==========================
-- Bridge Table (Order Items)
-- ==========================

drop table dim_order_items_bridge
CREATE TABLE dim_order_items_bridge (
    order_id VARCHAR(32),
    product_sk INT,
    seller_sk INT,

    FOREIGN KEY (order_id) REFERENCES fact_order(order_id),
    FOREIGN KEY (product_sk) REFERENCES dim_product(product_sk),
    FOREIGN KEY (seller_sk) REFERENCES dim_seller(seller_sk)
);
