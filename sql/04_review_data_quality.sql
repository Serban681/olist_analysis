-- total unique orders with reviews
WITH get_reviewed_orders AS (
    SELECT
        DISTINCT order_id
    FROM
        raw.order_reviews
)
SELECT COUNT(*) FROM get_reviewed_orders;

-- find orders that have multiple reviews 
WITH get_orders_with_multiple_reviews AS (
    SELECT
        order_id,
        COUNT(order_id),
        MIN(review_score),
        MAX(review_score)
    FROM
        raw.order_reviews
    GROUP BY order_id
    HAVING COUNT(order_id) > 1
)
SELECT * FROM get_orders_with_multiple_reviews;

SELECT
    *
FROM
    raw.order_reviews
WHERE
    order_id = '6318d8c5f6857de384c0b3186d036457';

SELECT
    *
FROM
    raw.orders
WHERE 
    order_id = '6318d8c5f6857de384c0b3186d036457';

SELECT
    *
FROM
    raw.order_items
WHERE 
    order_id = '6318d8c5f6857de384c0b3186d036457';