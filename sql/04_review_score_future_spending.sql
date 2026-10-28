-- get earliest and latest review dates
WITH get_minimum_and_maximum_review_answer_dates AS (
    SELECT
        MIN(review_answer_timestamp) AS earliest_review_answer,
        MAX(review_answer_timestamp) AS latest_review_answer
    FROM
        raw.order_reviews
)
SELECT * FROM get_minimum_and_maximum_review_answer_dates;

-- first review - new order
WITH get_reviews_for_order AS (
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
),
get_latest_review_for_order AS (
    SELECT
        order_id,
        review_score,
        review_answer_timestamp
    FROM
        get_reviews_for_order
    WHERE review_number = 1
),
get_user_order_review_score_and_followup AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        orw.review_score,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp ASC
        ) AS order_number,
        orw.review_answer_timestamp
    FROM
        raw.customers c
    JOIN raw.orders o ON c.customer_id = o.customer_id
    JOIN analytics.get_orders_review orw ON o.order_id = orw.order_id
),
get_first_user_order_review_score_and_followup AS (
    SELECT
        customer_unique_id,
        order_id,
        review_score,
        EXISTS (
            SELECT
                1
            FROM
                raw.orders later_o
            JOIN raw.customers later_c ON later_c.customer_id = later_o.customer_id
            WHERE later_c.customer_unique_id = first_o.customer_unique_id AND later_o.order_purchase_timestamp > first_o.review_answer_timestamp
        ) AS led_to_subsequent_purchase
    FROM
        get_user_order_review_score_and_followup first_o
    WHERE
        order_number = 1
),
get_scores_followups AS (
    SELECT
        review_score,
        COUNT(*) AS customers,
        COUNT(*) FILTER(WHERE led_to_subsequent_purchase) AS repeat_customers,
        ROUND(COUNT(*) FILTER(WHERE led_to_subsequent_purchase) * 100.0 / COUNT(*), 2) AS rate
    FROM get_first_user_order_review_score_and_followup
    GROUP BY review_score
)
SELECT * FROM get_scores_followups