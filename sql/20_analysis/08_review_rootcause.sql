-- =====================================================
-- 差评根因分析（review_score <= 2）
-- =====================================================
-- 目标：从履约时效、延迟、地区、类目、卖家等维度定位差评率上升的可能原因
-- 输入表：fact_orders, stg_order_items, stg_products, stg_product_category_translation

USE db_olist;

-- 1) 差评率总览
SELECT COUNT(*) AS delivered_orders,
  COUNT(CASE WHEN bad_review_flag = 1 THEN 1 END) AS bad_review_orders,
  COUNT(CASE WHEN review_score IS NOT NULL THEN 1 END) AS reviewed_orders,
  COUNT(CASE WHEN bad_review_flag = 1 THEN 1 END) / NULLIF(COUNT(CASE WHEN review_score IS NOT NULL THEN 1 END), 0) AS bad_review_rate
FROM fact_orders;

-- 2) 履约时长分桶 vs 差评率
SELECT CASE
    WHEN delivery_days IS NULL THEN 'unknown'
    WHEN delivery_days <= 7 THEN '0-7'
    WHEN delivery_days <= 14 THEN '8-14'
    WHEN delivery_days <= 21 THEN '15-21'
    ELSE '22+'
  END AS delivery_bucket,
  COUNT(*) AS orders,
  AVG(CASE WHEN review_score IS NOT NULL THEN 1 ELSE 0 END) AS review_coverage,
  AVG(bad_review_flag) AS bad_review_rate,
  AVG(ontime_flag) AS ontime_rate
FROM fact_orders
GROUP BY delivery_bucket
ORDER BY FIELD(delivery_bucket, '0-7', '8-14', '15-21', '22+', 'unknown');

-- 3) 延迟天数分桶 vs 差评率
SELECT CASE
    WHEN delay_days IS NULL THEN 'unknown'
    WHEN delay_days = 0 THEN '0'
    WHEN delay_days <= 3 THEN '1-3'
    WHEN delay_days <= 7 THEN '4-7'
    ELSE '8+'
  END AS delay_bucket,
  COUNT(*) AS orders,
  AVG(CASE WHEN review_score IS NOT NULL THEN 1 ELSE 0 END) AS review_coverage,
  AVG(bad_review_flag) AS bad_review_rate
FROM fact_orders
GROUP BY delay_bucket
ORDER BY FIELD(delay_bucket, '0', '1-3', '4-7', '8+', 'unknown');

-- 4) 州维度：订单量足够的州（Top 15 by orders）
WITH s AS (
  SELECT customer_state AS state,
    COUNT(*) AS orders,
    AVG(bad_review_flag) AS bad_review_rate,
    AVG(ontime_flag) AS ontime_rate,
    AVG(delivery_days) AS avg_delivery_days
  FROM fact_orders
  GROUP BY customer_state
)
SELECT *
FROM s
ORDER BY orders DESC
LIMIT 15;

-- 5) 类目维度：差评率最高的类目（Top 20，需订单量门槛）
WITH item_base AS (
  SELECT i.order_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
  FROM stg_order_items i
  LEFT JOIN stg_products p ON p.product_id = i.product_id
  LEFT JOIN stg_product_category_translation t ON t.product_category_name = p.product_category_name
  GROUP BY i.order_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown')
),
order_cat AS (
  SELECT order_id,
    MIN(category) AS category
  FROM item_base
  GROUP BY order_id
),
cat_rate AS (
  SELECT oc.category,
    COUNT(*) AS orders,
    AVG(f.bad_review_flag) AS bad_review_rate,
    AVG(f.ontime_flag) AS ontime_rate,
    AVG(f.delay_days) AS avg_delay_days
  FROM fact_orders f
  JOIN order_cat oc ON oc.order_id = f.order_id
  GROUP BY oc.category
)
SELECT *
FROM cat_rate
WHERE orders >= 500
ORDER BY bad_review_rate DESC
LIMIT 20;

-- 6) 卖家维度：差评率最高的卖家（Top 20，需订单量门槛）
WITH order_seller AS (
  SELECT order_id,
    seller_id
  FROM stg_order_items
  GROUP BY order_id,
    seller_id
),
seller_rate AS (
  SELECT os.seller_id,
    COUNT(*) AS orders,
    AVG(f.bad_review_flag) AS bad_review_rate,
    AVG(f.ontime_flag) AS ontime_rate,
    AVG(f.delay_days) AS avg_delay_days
  FROM fact_orders f
  JOIN order_seller os ON os.order_id = f.order_id
  GROUP BY os.seller_id
)
SELECT *
FROM seller_rate
WHERE orders >= 200
ORDER BY bad_review_rate DESC
LIMIT 20;
