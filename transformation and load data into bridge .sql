INSERT INTO dim_order_items_bridge 
SELECT 
    soi.order_id, 
    dp.product_sk,
    ds.seller_sk
 FROM staging.Order_Items soi 
INNER JOIN dim_product dp 
    ON dp.product_id = soi.product_id 
INNER JOIN dim_seller ds  
    ON soi.seller_id = ds.seller_id;


 