-- =====================================================
-- RFM 用户分层（基于 dm_customer_rfm）
-- =====================================================
-- 目标：将客户按 R/F/M 分位数评分并输出分层结果，便于在简历/面试中讲清分层逻辑
-- 输入表：dm_customer_rfm

USE db_olist;

-- 1) 生成 R/F/M 分位数评分（1-5），并给出分层标签
WITH scored AS (
  SELECT customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency) AS f_score,
    NTILE(5) OVER (ORDER BY monetary) AS m_score
  FROM dm_customer_rfm
),
seg AS (
  SELECT customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    CASE
      WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
      WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal'
      WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
      WHEN r_score = 3 AND f_score >= 3 THEN 'Potential Loyalist'
      WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
      WHEN r_score <= 2 AND m_score <= 2 THEN 'Hibernating'
      ELSE 'Others'
    END AS segment
  FROM scored
)
SELECT segment,
  COUNT(*) AS customers,
  AVG(recency_days) AS avg_recency_days,
  AVG(frequency) AS avg_frequency,
  AVG(monetary) AS avg_monetary
FROM seg
GROUP BY segment
ORDER BY customers DESC;

-- 2) 分层 Top 客户样例（便于检查与讲解）
WITH scored AS (
  SELECT customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency) AS f_score,
    NTILE(5) OVER (ORDER BY monetary) AS m_score
  FROM dm_customer_rfm
),
seg AS (
  SELECT customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE
      WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
      WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal'
      WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
      WHEN r_score = 3 AND f_score >= 3 THEN 'Potential Loyalist'
      WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
      WHEN r_score <= 2 AND m_score <= 2 THEN 'Hibernating'
      ELSE 'Others'
    END AS segment
  FROM scored
)
SELECT *
FROM seg
WHERE segment IN ('Champions', 'At Risk')
ORDER BY monetary DESC
LIMIT 20;
