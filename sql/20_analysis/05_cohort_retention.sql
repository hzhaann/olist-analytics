-- =====================================================
-- Cohort 留存分析（首购月 Cohort）
-- =====================================================
-- 目标：计算用户首购月 cohort 在后续月份的复购率
-- 适用场景：增长分析、用户留存监控
USE db_olist;
-- Step 1: 计算每个用户的首购月
DROP TABLE IF EXISTS tmp_customer_first_purchase;
CREATE TEMPORARY TABLE tmp_customer_first_purchase AS
SELECT customer_unique_id,
    DATE_FORMAT(MIN(order_purchase_timestamp), '%Y-%m') AS first_purchase_month,
    MIN(order_purchase_timestamp) AS first_purchase_date
FROM fact_orders
GROUP BY customer_unique_id;
-- Step 2: 计算每个用户在各月的购买情况
DROP TABLE IF EXISTS tmp_customer_monthly_purchase;
CREATE TEMPORARY TABLE tmp_customer_monthly_purchase AS
SELECT customer_unique_id,
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS purchase_month,
    COUNT(DISTINCT order_id) AS order_count
FROM fact_orders
GROUP BY customer_unique_id,
    purchase_month;
DROP TABLE IF EXISTS tmp_cohort_size;
CREATE TEMPORARY TABLE tmp_cohort_size AS
SELECT first_purchase_month,
    COUNT(DISTINCT customer_unique_id) AS cohort_size
FROM tmp_customer_first_purchase
GROUP BY first_purchase_month;
DROP TABLE IF EXISTS tmp_total_customers;
CREATE TEMPORARY TABLE tmp_total_customers AS
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM tmp_customer_first_purchase;
-- Step 3: 计算 Cohort 留存矩阵
SELECT fp.first_purchase_month AS cohort_month,
    mp.purchase_month,
    TIMESTAMPDIFF(
        MONTH,
        STR_TO_DATE(
            CONCAT(fp.first_purchase_month, '-01'),
            '%Y-%m-%d'
        ),
        STR_TO_DATE(CONCAT(mp.purchase_month, '-01'), '%Y-%m-%d')
    ) AS months_since_first,
    COUNT(DISTINCT fp.customer_unique_id) AS retained_customers,
    MAX(cs.cohort_size) AS cohort_size,
    ROUND(
        COUNT(DISTINCT fp.customer_unique_id) * 100.0 / MAX(cs.cohort_size),
        2
    ) AS retention_rate_pct
FROM tmp_customer_first_purchase fp
    INNER JOIN tmp_customer_monthly_purchase mp ON fp.customer_unique_id = mp.customer_unique_id
    INNER JOIN tmp_cohort_size cs ON cs.first_purchase_month = fp.first_purchase_month
WHERE mp.purchase_month >= fp.first_purchase_month
GROUP BY fp.first_purchase_month,
    mp.purchase_month
ORDER BY fp.first_purchase_month,
    mp.purchase_month;
-- Step 4: 简化版 - 按月份间隔汇总（更适合可视化）
SELECT TIMESTAMPDIFF(
        MONTH,
        STR_TO_DATE(
            CONCAT(fp.first_purchase_month, '-01'),
            '%Y-%m-%d'
        ),
        STR_TO_DATE(CONCAT(mp.purchase_month, '-01'), '%Y-%m-%d')
    ) AS months_since_first,
    COUNT(DISTINCT fp.customer_unique_id) AS total_retained_customers,
    COUNT(DISTINCT fp.customer_unique_id) * 100.0 / (
        SELECT total_customers
        FROM tmp_total_customers
    ) AS avg_retention_rate_pct
FROM tmp_customer_first_purchase fp
    INNER JOIN tmp_customer_monthly_purchase mp ON fp.customer_unique_id = mp.customer_unique_id
WHERE mp.purchase_month >= fp.first_purchase_month
    AND TIMESTAMPDIFF(
        MONTH,
        STR_TO_DATE(
            CONCAT(fp.first_purchase_month, '-01'),
            '%Y-%m-%d'
        ),
        STR_TO_DATE(CONCAT(mp.purchase_month, '-01'), '%Y-%m-%d')
    ) <= 12 -- 只看前12个月
GROUP BY months_since_first
ORDER BY months_since_first;
-- Step 5: 复购用户分析（首购后有再次购买的用户）
DROP TABLE IF EXISTS tmp_repurchasers;
CREATE TEMPORARY TABLE tmp_repurchasers AS
SELECT DISTINCT fp.customer_unique_id
FROM tmp_customer_first_purchase fp
    INNER JOIN tmp_customer_monthly_purchase mp ON fp.customer_unique_id = mp.customer_unique_id
WHERE mp.purchase_month > fp.first_purchase_month;
SELECT '总用户数' AS metric,
    total_customers AS value
FROM tmp_total_customers;
SELECT '复购用户数' AS metric,
    COUNT(*) AS value
FROM tmp_repurchasers;
SELECT '复购率(%)' AS metric,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT total_customers
            FROM tmp_total_customers
        ),
        2
    ) AS value
FROM tmp_repurchasers;
-- 清理临时表
DROP TABLE IF EXISTS tmp_customer_first_purchase;
DROP TABLE IF EXISTS tmp_customer_monthly_purchase;
DROP TABLE IF EXISTS tmp_cohort_size;
DROP TABLE IF EXISTS tmp_total_customers;
DROP TABLE IF EXISTS tmp_repurchasers;