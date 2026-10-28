-- maximum delivery delay
SELECT
    ROUND(MAX(
        EXTRACT (
            EPOCH FROM (order_delivered_customer_date - order_estimated_delivery_date)
        ) / 86400
    ), 2) AS highest_delay
FROM
    raw.orders;


-- review_score_delay_stats
WITH get_review_score_delay_stats AS ( 
    SELECT
        orw.review_score,
        COUNT(*) AS order_count,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY od.order_delay) AS median_delay,
        ROUND(AVG(od.order_delay), 2) AS average_delay
    FROM
        analytics.get_orders_delay od
    JOIN analytics.get_orders_review orw
        ON od.order_id = orw.order_id
    WHERE od.order_delay >= 1 -- avoid minute-hour delays
    GROUP BY orw.review_score 
)
SELECT * FROM get_review_score_delay_stats;

-- low review score, delay association
WITH get_review_score_delay_association AS (
    SELECT
        CASE
            WHEN od.order_delay >= 1 THEN 'late'
            ELSE 'not late'
        END AS delivery_status,
        COUNT(*) AS order_count,
        ROUND(AVG(orw.review_score), 2) AS average_review_score,
        ROUND(
            COUNT(*) FILTER (WHERE orw.review_score <= 2) * 100.0 / COUNT(*), 2
        ) AS low_review_rate -- a low review rate has a score of 2 or lower
    FROM 
        analytics.get_orders_delay od
    JOIN 
        analytics.get_orders_review orw
            ON orw.order_id = od.order_id
    WHERE od.order_delay IS NOT NULL
    GROUP BY CASE
                WHEN od.order_delay >= 1 THEN 'late'
                ELSE 'not late'
            END
)
SELECT * FROM get_review_score_delay_association;
