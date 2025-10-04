select  *
FROM  fact_order fo
INNER JOIN (
    SELECT soi.order_id  , SUM(soi.price + soi.shipping_cost) AS sum_amount
    FROM staging.Order_Items soi
    GROUP BY soi.order_id
) totals 
    ON fo.order_id = totals.order_id;