-- =====================================================
-- 转化漏斗分析
-- =====================================================
-- 目标：分析订单从下单到评价的各环节转化率
-- 适用场景：体验优化、流失点定位
USE db_olist;
-- 整体漏斗（所有订单）
SELECT '1. 下单' AS stage,
    COUNT(DISTINCT o.order_id) AS order_count,
    100.00 AS conversion_rate_pct,
    0.00 AS drop_rate_pct
FROM stg_orders o
UNION ALL
SELECT '2. 支付完成' AS stage,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS conversion_rate_pct,
    ROUND(
        100 - COUNT(DISTINCT o.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS drop_rate_pct
FROM stg_orders o
WHERE o.order_status NOT IN ('canceled', 'unavailable')
UNION ALL
SELECT '3. 已发货' AS stage,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS conversion_rate_pct,
    ROUND(
        100 - COUNT(DISTINCT o.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS drop_rate_pct
FROM stg_orders o
WHERE o.order_status IN ('shipped', 'delivered')
UNION ALL
SELECT '4. 已送达' AS stage,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS conversion_rate_pct,
    ROUND(
        100 - COUNT(DISTINCT o.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS drop_rate_pct
FROM stg_orders o
WHERE o.order_status = 'delivered'
UNION ALL
SELECT '5. 已评价' AS stage,
    COUNT(DISTINCT r.order_id) AS order_count,
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS conversion_rate_pct,
    ROUND(
        100 - COUNT(DISTINCT r.order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
        ),
        2
    ) AS drop_rate_pct
FROM stg_reviews r
    INNER JOIN stg_orders o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered';
-- 按月份的漏斗趋势
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN o.order_status NOT IN ('canceled', 'unavailable') THEN o.order_id
        END
    ) AS paid_orders,
    COUNT(
        DISTINCT CASE
            WHEN o.order_status IN ('shipped', 'delivered') THEN o.order_id
        END
    ) AS shipped_orders,
    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'delivered' THEN o.order_id
        END
    ) AS delivered_orders,
    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'delivered'
            AND r.order_id IS NOT NULL THEN o.order_id
        END
    ) AS reviewed_orders,
    -- 转化率
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_status NOT IN ('canceled', 'unavailable') THEN o.order_id
            END
        ) * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS paid_rate_pct,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'delivered' THEN o.order_id
            END
        ) * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS delivery_rate_pct,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'delivered'
                AND r.order_id IS NOT NULL THEN o.order_id
            END
        ) * 100.0 / COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'delivered' THEN o.order_id
            END
        ),
        2
    ) AS review_rate_pct
FROM stg_orders o
    LEFT JOIN stg_reviews r ON o.order_id = r.order_id
GROUP BY order_month
ORDER BY order_month;
-- 按品类的漏斗对比（Top 10 品类）
WITH top_categories AS (
    SELECT COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) AS category,
        COUNT(DISTINCT oi.order_id) AS order_count
    FROM stg_order_items oi
        INNER JOIN stg_products p ON oi.product_id = p.product_id
        LEFT JOIN stg_product_category_translation t ON t.product_category_name = p.product_category_name
        INNER JOIN stg_orders o ON oi.order_id = o.order_id
    WHERE COALESCE(
            t.product_category_name_english,
            p.product_category_name
        ) IS NOT NULL
    GROUP BY COALESCE(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        )
    ORDER BY order_count DESC
    LIMIT 10
)
SELECT COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'delivered' THEN o.order_id
        END
    ) AS delivered_orders,
    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'delivered'
            AND r.order_id IS NOT NULL THEN o.order_id
        END
    ) AS reviewed_orders,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'delivered' THEN o.order_id
            END
        ) * 100.0 / COUNT(DISTINCT o.order_id),
        2
    ) AS delivery_rate_pct,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'delivered'
                AND r.order_id IS NOT NULL THEN o.order_id
            END
        ) * 100.0 / COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'delivered' THEN o.order_id
            END
        ),
        2
    ) AS review_rate_pct
FROM stg_order_items oi
    INNER JOIN stg_products p ON oi.product_id = p.product_id
    LEFT JOIN stg_product_category_translation t ON t.product_category_name = p.product_category_name
    INNER JOIN stg_orders o ON oi.order_id = o.order_id
    LEFT JOIN stg_reviews r ON o.order_id = r.order_id
WHERE COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) IN (
        SELECT category
        FROM top_categories
    )
GROUP BY COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
ORDER BY total_orders DESC;
-- 流失原因分析（取消/不可用订单）
SELECT order_status,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 / (
            SELECT COUNT(DISTINCT order_id)
            FROM stg_orders
            WHERE order_status IN ('canceled', 'unavailable')
        ),
        2
    ) AS pct
FROM stg_orders
WHERE order_status IN ('canceled', 'unavailable')
GROUP BY order_status;