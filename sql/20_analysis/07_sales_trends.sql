-- =====================================================
-- 销售趋势分析
-- =====================================================
-- 目标：从时间趋势 + 结构拆解（地区/类目）定位 GMV 与订单变化来源
-- 输入表：fact_orders, dm_category_daily, dm_state_daily, dm_kpi_daily

USE db_olist;

-- 1) 按月经营趋势（GMV/订单/买家/客单/体验）
SELECT DATE_FORMAT(dt, '%Y-%m') AS ym,
  SUM(orders) AS orders,
  SUM(buyers) AS buyers,
  SUM(item_gmv) AS item_gmv,
  SUM(paid_gmv) AS paid_gmv,
  SUM(item_gmv) / NULLIF(SUM(orders), 0) AS aov,
  AVG(ontime_rate) AS ontime_rate,
  AVG(bad_review_rate) AS bad_review_rate
FROM dm_kpi_daily
GROUP BY DATE_FORMAT(dt, '%Y-%m')
ORDER BY ym;

-- 2) 最近 12 个月：Top 10 类目（GMV）
WITH base AS (
  SELECT DATE_FORMAT(dt, '%Y-%m') AS ym,
    category,
    SUM(item_gmv) AS item_gmv,
    SUM(orders) AS orders
  FROM dm_category_daily
  GROUP BY DATE_FORMAT(dt, '%Y-%m'),
    category
),
last_12m AS (
  SELECT *
  FROM base
  WHERE ym >= DATE_FORMAT(DATE_SUB((SELECT MAX(dt) FROM dm_kpi_daily), INTERVAL 12 MONTH), '%Y-%m')
),
cat_tot AS (
  SELECT category,
    SUM(item_gmv) AS item_gmv
  FROM last_12m
  GROUP BY category
)
SELECT l.category,
  SUM(l.item_gmv) AS item_gmv,
  SUM(l.orders) AS orders,
  SUM(l.item_gmv) / NULLIF(SUM(l.orders), 0) AS aov
FROM last_12m l
JOIN (
  SELECT category
  FROM cat_tot
  ORDER BY item_gmv DESC
  LIMIT 10
) t ON t.category = l.category
GROUP BY l.category
ORDER BY item_gmv DESC;

-- 3) 最近 12 个月：Top 10 州（GMV）
WITH base AS (
  SELECT DATE_FORMAT(dt, '%Y-%m') AS ym,
    state,
    SUM(item_gmv) AS item_gmv,
    SUM(orders) AS orders
  FROM dm_state_daily
  GROUP BY DATE_FORMAT(dt, '%Y-%m'),
    state
),
last_12m AS (
  SELECT *
  FROM base
  WHERE ym >= DATE_FORMAT(DATE_SUB((SELECT MAX(dt) FROM dm_kpi_daily), INTERVAL 12 MONTH), '%Y-%m')
),
state_tot AS (
  SELECT state,
    SUM(item_gmv) AS item_gmv
  FROM last_12m
  GROUP BY state
)
SELECT l.state,
  SUM(l.item_gmv) AS item_gmv,
  SUM(l.orders) AS orders,
  SUM(l.item_gmv) / NULLIF(SUM(l.orders), 0) AS aov
FROM last_12m l
JOIN (
  SELECT state
  FROM state_tot
  ORDER BY item_gmv DESC
  LIMIT 10
) t ON t.state = l.state
GROUP BY l.state
ORDER BY item_gmv DESC;

-- 4) 趋势拆解：环比增长（最近 6 个月）
WITH m AS (
  SELECT DATE_FORMAT(dt, '%Y-%m') AS ym,
    SUM(item_gmv) AS item_gmv,
    SUM(orders) AS orders,
    SUM(buyers) AS buyers
  FROM dm_kpi_daily
  GROUP BY DATE_FORMAT(dt, '%Y-%m')
),
latest AS (
  SELECT MAX(ym) AS max_ym
  FROM m
)
SELECT m.ym,
  m.item_gmv,
  m.orders,
  m.buyers,
  (m.item_gmv - LAG(m.item_gmv) OVER (ORDER BY m.ym)) / NULLIF(LAG(m.item_gmv) OVER (ORDER BY m.ym), 0) AS mom_item_gmv,
  (m.orders - LAG(m.orders) OVER (ORDER BY m.ym)) / NULLIF(LAG(m.orders) OVER (ORDER BY m.ym), 0) AS mom_orders
FROM m
CROSS JOIN latest
WHERE m.ym >= DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(latest.max_ym, '-01'), '%Y-%m-%d'), INTERVAL 6 MONTH), '%Y-%m')
ORDER BY m.ym;
