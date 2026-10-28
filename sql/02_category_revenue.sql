WITH product_revenue AS (
    SELECT 
        oi.product_id,
        MAX(oi.price) AS product_price,
        SUM(oi.price) AS total_revenue_product,
        COUNT(oi.product_id) AS units_sold
    FROM raw.order_items oi
    JOIN raw.orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY product_id
),
revenue_by_category AS (
    SELECT 
        p.product_category_name,
        SUM(pr.total_revenue_product) AS total_revenue_category,
        ROUND(AVG(pr.total_revenue_product), 2) AS average_revenue_category,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY pr.total_revenue_product) AS median_revenue_category,
        COUNT(DISTINCT pr.product_id) AS product_count,
        SUM(pr.units_sold) AS units_sold,
        ROUND(AVG(pr.product_price), 2) AS average_price
    FROM product_revenue pr
    JOIN raw.products p ON p.product_id = pr.product_id
    GROUP BY p.product_category_name
),
revenue_by_category_en AS (
    SELECT
        pcnt.product_category_name_english AS category,
        rbc.total_revenue_category AS total_revenue,
        rbc.average_revenue_category AS average_revenue,
        rbc.median_revenue_category AS median_revenue,
        rbc.product_count,
        rbc.units_sold,
        rbc.average_price
    FROM revenue_by_category rbc
    JOIN raw.product_category_name_translation pcnt
    ON pcnt.product_category_name = rbc.product_category_name
)
SELECT * FROM revenue_by_category_en
ORDER BY median_revenue DESC;
