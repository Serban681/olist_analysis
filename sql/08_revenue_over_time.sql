WITH get_order_value AS (
    SELECT
        order_id,
        SUM(price) AS order_value
    FROM raw.order_items
    GROUP BY order_id
),
get_delivered_orders_purchase_month_and_value AS (
    SELECT
        o.order_id,
        ov.order_value,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month
    FROM raw.orders o
    JOIN get_order_value ov
        ON o.order_id = ov.order_id
    WHERE order_status = 'delivered'
),
get_monthly_revenue_stats AS (
    SELECT
        purchase_month AS month,
        COUNT(*) AS order_count,
        SUM(order_value) AS revenue,
        ROUND(AVG(order_value), 2) AS average_order_value
    FROM
        get_delivered_orders_purchase_month_and_value
    GROUP BY purchase_month
    ORDER BY purchase_month
)
SELECT 
    * 
FROM get_monthly_revenue_stats;