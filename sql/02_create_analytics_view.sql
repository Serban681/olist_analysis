CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.get_orders_review AS (
    WITH latest_review_prep AS (
        SELECT
            order_id,
            review_score,
            review_answer_timestamp,
            ROW_NUMBER() OVER(
                PARTITION BY order_id
                ORDER BY review_answer_timestamp DESC
            ) AS review_number
        FROM 
            raw.order_reviews
    )
    SELECT
        order_id,
        review_score,
        review_answer_timestamp
    FROM latest_review_prep
    WHERE review_number = 1
)

CREATE OR REPLACE VIEW analytics.get_orders_delay AS (
    SELECT
        order_id,
        ROUND(MAX(
            EXTRACT (
                EPOCH FROM (order_delivered_customer_date - order_estimated_delivery_date)
            ) / 86400
        ), 2) AS order_delay
    FROM 
        raw.orders
    GROUP BY order_id
)