USE db_olist;
DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders AS WITH oi AS (
  SELECT order_id,
    SUM(COALESCE(price, 0)) AS items_price,
    SUM(COALESCE(freight_value, 0)) AS freight_amount,
    SUM(COALESCE(price, 0) + COALESCE(freight_value, 0)) AS item_gmv
  FROM stg_order_items
  GROUP BY order_id
),
pay AS (
  SELECT order_id,
    SUM(COALESCE(payment_value, 0)) AS paid_gmv
  FROM stg_order_payments
  GROUP BY order_id
),
rev AS (
  SELECT order_id,
    MAX(review_score) AS review_score
  FROM stg_reviews
  GROUP BY order_id
)
SELECT o.order_id,
  c.customer_unique_id,
  c.customer_state,
  c.customer_city,
  DATE(o.order_purchase_timestamp) AS purchase_date,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  o.order_status,
  COALESCE(oi.items_price, 0) AS items_price,
  COALESCE(oi.freight_amount, 0) AS freight_amount,
  COALESCE(oi.item_gmv, 0) AS item_gmv,
  COALESCE(pay.paid_gmv, 0) AS paid_gmv,
  rev.review_score,
  TIMESTAMPDIFF(
    DAY,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
  ) AS delivery_days,
  GREATEST(
    TIMESTAMPDIFF(
      DAY,
      o.order_estimated_delivery_date,
      o.order_delivered_customer_date
    ),
    0
  ) AS delay_days,
  CASE
    WHEN o.order_delivered_customer_date IS NULL
    OR o.order_estimated_delivery_date IS NULL THEN NULL
    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1
    ELSE 0
  END AS ontime_flag,
  CASE
    WHEN rev.review_score IS NOT NULL
    AND rev.review_score <= 2 THEN 1
    ELSE 0
  END AS bad_review_flag
FROM stg_orders o
  JOIN stg_customers c ON c.customer_id = o.customer_id
  LEFT JOIN oi ON oi.order_id = o.order_id
  LEFT JOIN pay ON pay.order_id = o.order_id
  LEFT JOIN rev ON rev.order_id = o.order_id
WHERE o.order_status = 'delivered';
ALTER TABLE fact_orders
ADD PRIMARY KEY (order_id),
  ADD KEY idx_fact_purchase_date (purchase_date),
  ADD KEY idx_fact_customer (customer_unique_id),
  ADD KEY idx_fact_state (customer_state);