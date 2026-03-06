USE db_olist;
DROP TABLE IF EXISTS dm_kpi_daily;
CREATE TABLE dm_kpi_daily AS
SELECT purchase_date AS dt,
  COUNT(*) AS orders,
  COUNT(DISTINCT customer_unique_id) AS buyers,
  SUM(item_gmv) AS item_gmv,
  SUM(paid_gmv) AS paid_gmv,
  SUM(item_gmv) / NULLIF(COUNT(*), 0) AS aov,
  AVG(delivery_days) AS avg_delivery_days,
  AVG(ontime_flag) AS ontime_rate,
  AVG(bad_review_flag) AS bad_review_rate
FROM fact_orders
GROUP BY purchase_date;
ALTER TABLE dm_kpi_daily
ADD PRIMARY KEY (dt);
DROP TABLE IF EXISTS dm_state_daily;
CREATE TABLE dm_state_daily AS
SELECT purchase_date AS dt,
  customer_state AS state,
  COUNT(*) AS orders,
  COUNT(DISTINCT customer_unique_id) AS buyers,
  SUM(item_gmv) AS item_gmv,
  SUM(paid_gmv) AS paid_gmv,
  SUM(item_gmv) / NULLIF(COUNT(*), 0) AS aov,
  AVG(delivery_days) AS avg_delivery_days,
  AVG(ontime_flag) AS ontime_rate,
  AVG(bad_review_flag) AS bad_review_rate
FROM fact_orders
GROUP BY purchase_date,
  customer_state;
ALTER TABLE dm_state_daily
ADD KEY idx_state_daily_dt_state (dt, state);
DROP TABLE IF EXISTS dm_category_daily;
CREATE TABLE dm_category_daily AS WITH item_base AS (
  SELECT o.order_id,
    DATE(o.order_purchase_timestamp) AS dt,
    c.customer_unique_id,
    CASE
      WHEN t.product_category_name_english IS NOT NULL
      AND t.product_category_name_english <> '' THEN t.product_category_name_english
      WHEN p.product_category_name IS NOT NULL
      AND p.product_category_name <> '' THEN p.product_category_name
      ELSE 'unknown'
    END AS category,
    (
      COALESCE(i.price, 0) + COALESCE(i.freight_value, 0)
    ) AS item_gmv
  FROM stg_orders o
    JOIN stg_customers c ON c.customer_id = o.customer_id
    JOIN stg_order_items i ON i.order_id = o.order_id
    LEFT JOIN stg_products p ON p.product_id = i.product_id
    LEFT JOIN stg_product_category_translation t ON t.product_category_name = p.product_category_name
  WHERE o.order_status = 'delivered'
),
item_cat AS (
  SELECT order_id,
    dt,
    customer_unique_id,
    category,
    SUM(item_gmv) AS item_gmv
  FROM item_base
  GROUP BY order_id,
    dt,
    customer_unique_id,
    category
),
order_tot AS (
  SELECT order_id,
    SUM(item_gmv) AS order_item_gmv
  FROM item_base
  GROUP BY order_id
),
order_flags AS (
  SELECT o.order_id,
    CASE
      WHEN o.order_delivered_customer_date IS NULL
      OR o.order_estimated_delivery_date IS NULL THEN NULL
      WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1
      ELSE 0
    END AS ontime_flag,
    CASE
      WHEN MAX(r.review_score) IS NOT NULL
      AND MAX(r.review_score) <= 2 THEN 1
      ELSE 0
    END AS bad_review_flag,
    SUM(COALESCE(p.payment_value, 0)) AS paid_gmv
  FROM stg_orders o
    LEFT JOIN stg_reviews r ON r.order_id = o.order_id
    LEFT JOIN stg_order_payments p ON p.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY o.order_id,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
)
SELECT ic.dt,
  ic.category,
  COUNT(DISTINCT ic.order_id) AS orders,
  COUNT(DISTINCT ic.customer_unique_id) AS buyers,
  SUM(ic.item_gmv) AS item_gmv,
  SUM(
    COALESCE(ofl.paid_gmv, 0) * (ic.item_gmv / NULLIF(ot.order_item_gmv, 0))
  ) AS paid_gmv,
  SUM(ic.item_gmv) / NULLIF(COUNT(DISTINCT ic.order_id), 0) AS aov,
  AVG(ofl.ontime_flag) AS ontime_rate,
  AVG(ofl.bad_review_flag) AS bad_review_rate
FROM item_cat ic
  LEFT JOIN order_tot ot ON ot.order_id = ic.order_id
  LEFT JOIN order_flags ofl ON ofl.order_id = ic.order_id
GROUP BY ic.dt,
  ic.category;
ALTER TABLE dm_category_daily
ADD KEY idx_category_daily_dt_cat (dt, category);
DROP TABLE IF EXISTS dm_customer_rfm;
CREATE TABLE dm_customer_rfm AS WITH as_of AS (
  SELECT MAX(purchase_date) AS as_of_date
  FROM fact_orders
),
base AS (
  SELECT customer_unique_id,
    MAX(purchase_date) AS last_purchase_date,
    COUNT(*) AS frequency,
    SUM(item_gmv) AS monetary,
    AVG(delivery_days) AS avg_delivery_days,
    AVG(ontime_flag) AS ontime_rate,
    AVG(bad_review_flag) AS bad_review_rate
  FROM fact_orders
  GROUP BY customer_unique_id
)
SELECT b.customer_unique_id,
  b.last_purchase_date,
  DATEDIFF(a.as_of_date, b.last_purchase_date) AS recency_days,
  b.frequency,
  b.monetary,
  b.avg_delivery_days,
  b.ontime_rate,
  b.bad_review_rate
FROM base b
  CROSS JOIN as_of a;
ALTER TABLE dm_customer_rfm
ADD PRIMARY KEY (customer_unique_id);