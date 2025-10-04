DELETE FROM fact_order;

INSERT INTO fact_order
(
    order_id, 
    order_date_id, 
    approved_date_id, 
    pickup_date_id, 
    delivery_date_id, 
    estimated_delivery_date_id,
    duration_between_orderDate_pickupDate, 
    duration_between_orderDate_approvedDate, 
    duration_between_orderDate_deliveryDate,
    is_order_arrived_on_time, 
    order_status
)
SELECT 
    o.order_id, 
    CAST(FORMAT(o.order_date,'yyyyMMddHHmm') AS BIGINT),
    CAST(FORMAT(o.order_approved_date,'yyyyMMddHHmm') AS BIGINT),
    CAST(FORMAT(o.pickup_date,'yyyyMMddHHmm') AS BIGINT),
    CAST(FORMAT(o.delivered_date,'yyyyMMddHHmm') AS BIGINT),
    CAST(FORMAT(o.estimated_time_delivery,'yyyyMMddHHmm') AS BIGINT),
     DATEDIFF(MINUTE, o.order_date, o.pickup_date),
    DATEDIFF(MINUTE, o.order_date, o.order_approved_date),
    DATEDIFF(MINUTE, o.order_date, o.delivered_date),
    CASE WHEN o.delivered_date <= o.estimated_time_delivery THEN 1 ELSE 0 END,
    o.order_status
FROM staging.Orders o
 
GO


;WITH user_sk_cte AS ( 
    SELECT  
        fo.order_id, 
        du.user_sk
    FROM staging.Orders fo 
    INNER JOIN staging.Users su  
        ON su.user_name = fo.user_name 
    INNER JOIN dim_user du  
        ON du.user_id = su.user_name 
)
UPDATE fo
SET fo.user_sk = cte.user_sk
FROM fact_order fo
INNER JOIN user_sk_cte cte 
    ON fo.order_id = cte.order_id
WHERE fo.user_sk IS NULL;






;WITH feedback_sk_cte AS ( 

    SELECT  
        fo.order_id,df.feedback_id, df.feedback_sk
     FROM staging.Orders fo 
    INNER JOIN staging.Feedbacks sf  
        ON     fo.order_id=sf.order_id
	inner join dim_feedback df on df.feedback_id=sf.feedback_id 
 
)
update fo
set fo.feedback_sk= fsc.feedback_sk
from fact_order fo
	inner join feedback_sk_cte  fsc
	on fo.order_id = fsc.order_id
where fo.feedback_sk is null
 



;WITH total_amount_cte AS ( 
select order_id ,sum(price)+sum(shipping_cost) as total_amount
from staging.Order_Items
group by order_id
 
)
 
update fo
set fo.total_amount= tac.total_amount
from fact_order fo
	inner join total_amount_cte  tac
	on fo.order_id = tac.order_id
where fo.total_amount is null
 

 