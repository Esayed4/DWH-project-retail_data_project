;WITH RankedFeedbacks AS ( 
    SELECT  
        feedback_id, 
        ROW_NUMBER() OVER ( 
            PARTITION BY order_id  
            ORDER BY feedback_answer_date DESC, feedback_form_sent_date DESC 
        ) AS rn 
    FROM staging.Feedbacks 
) 
DELETE FROM staging.Feedbacks
WHERE feedback_id IN (
    SELECT feedback_id
    FROM RankedFeedbacks
    WHERE rn > 1
);
