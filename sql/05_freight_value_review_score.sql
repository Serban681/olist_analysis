-- get freight value price range
SELECT
    MIN(freight_value) AS lowest_freight_value,
    MAX(freight_value) AS highest_freight_value
FROM
    raw.order_items

-- freight value review association
WITH get_order_freight_value AS (
    SELECT
        order_id,
        SUM(freight_value) AS total_freight_value,
        SUM(freight_value) + SUM(price) AS total_order_value,
        SUM(freight_value) / (SUM(freight_value) + SUM(price)) AS freight_burden
    FROM
        raw.order_items
    GROUP BY
        order_id
),
create_freight_value_review_score_association AS (
    SELECT
        ors.review_score,
        COUNT(*) AS order_count,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ofv.total_freight_value) AS median_freight,
        ROUND(AVG(ofv.total_freight_value), 2) AS average_freight,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ofv.total_order_value) AS median_order_value,
        ROUND(
            CAST((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ofv.freight_burden)) AS NUMERIC), 
            3
        ) AS median_freight_burden
    FROM
        analytics.get_orders_review ors
    LEFT JOIN
        get_order_freight_value ofv
    ON
        ors.order_id = ofv.order_id
    GROUP BY ors.review_score
    ORDER BY review_score
)
SELECT * FROM create_freight_value_review_score_association