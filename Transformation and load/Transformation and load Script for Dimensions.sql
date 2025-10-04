delete from dim_user;
INSERT INTO dim_user ([user_id], user_zip_code, user_state, user_city, start_date, end_date, is_current)
SELECT 
    user_name,
    customer_zip_code,
    customer_state,
    customer_city,
    GETDATE() AS start_date,
    NULL AS end_date,
    1 AS is_current
FROM ( 
           SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_name      -- partition by the natural key
               ORDER BY user_name           -- define priority, e.g., latest date if you have one
           ) AS rn
           FROM staging.Users
	  ) as t
where rn=1
GO

 
DELETE FROM dim_payment;

INSERT INTO dim_payment (payment_sequential, payment_type, payment_installments, payment_value)
SELECT
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM (
       SELECT *,
              ROW_NUMBER() OVER (
                  PARTITION BY order_id, payment_sequential
                  ORDER BY payment_sequential
              ) AS rn
       FROM staging.Payments
) as t
WHERE rn = 1;
GO




DELETE FROM dim_feedback;

INSERT INTO dim_feedback (feedback_id, feedback_score, feedback_form_sent_date, feedback_answer_date)
SELECT
    feedback_id,
    feedback_score,
    feedback_form_sent_date,
    feedback_answer_date
FROM (
       SELECT *,
              ROW_NUMBER() OVER (
                  PARTITION BY feedback_id
                  ORDER BY feedback_id
              ) AS rn
       FROM staging.Feedbacks
) as t
WHERE rn = 1;
GO









-- dim_product     
DELETE FROM dim_product;

INSERT INTO dim_product (product_id, product_category, product_photos_qty)
SELECT
    product_id,
    product_category,
    product_photos_qty
FROM (
       SELECT *,
              ROW_NUMBER() OVER (
                  PARTITION BY product_id
                  ORDER BY product_id
              ) AS rn
       FROM staging.Products
) as t
WHERE rn = 1;
GO





 DELETE FROM dim_seller;

INSERT INTO dim_seller (seller_id, seller_zip_code, seller_state, seller_city, start_date, end_date, is_current)
SELECT
    seller_id,
    seller_zip_code,
    seller_state,
    seller_city,
    GETDATE() AS start_date,
    NULL AS end_date,
    1 AS is_current
FROM (
       SELECT *,
              ROW_NUMBER() OVER (
                  PARTITION BY seller_id
                  ORDER BY seller_id
              ) AS rn
       FROM staging.Sellers
) as t
WHERE rn = 1;
GO



