# 项目路线图 - Olist 电商分析

## 项目目标

完成一个端到端的电商数据分析项目，用于简历作品集，展示以下能力：
- SQL 数据建模与多表关联
- 指标体系搭建与口径管理
- 专题分析（留存/漏斗/RFM/根因）
- BI 看板设计与交互
- 数据驱动的业务建议

## 推进计划（10-15天）

### Day 1-2: 环境搭建与数据导入（4-6小时）

**任务清单**:
- [x] 下载 Olist 数据集（9个CSV文件）
- [x] 创建 MySQL 数据库（db_olist）
- [x] 执行建表脚本（01_create_tables.sql）
- [ ] 执行数据导入脚本（02_load_data.sql）
- [ ] 验证数据完整性

**产出**:
- MySQL 数据库包含 9 张 stg_ 表
- 数据量验证报告

**验证命令**:
```sql
USE db_olist;
SELECT 'stg_orders' AS table_name, COUNT(*) AS row_count FROM stg_orders
UNION ALL SELECT 'stg_order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'stg_order_payments', COUNT(*) FROM stg_order_payments
UNION ALL SELECT 'stg_customers', COUNT(*) FROM stg_customers
UNION ALL SELECT 'stg_reviews', COUNT(*) FROM stg_reviews
UNION ALL SELECT 'stg_products', COUNT(*) FROM stg_products
UNION ALL SELECT 'stg_sellers', COUNT(*) FROM stg_sellers
UNION ALL SELECT 'stg_product_category_translation', COUNT(*) FROM stg_product_category_translation
UNION ALL SELECT 'stg_geolocation', COUNT(*) FROM stg_geolocation;
```

---

### Day 3-4: 数据建模（4-6小时）

**任务清单**:
- [ ] 构建事实表（fact_orders）
  - [ ] 执行 03_build_fact.sql
  - [ ] 验证数据质量
  - [ ] 检查 GMV 口径一致性
- [ ] 构建主题表（dm_*）
  - [ ] 执行 04_build_dm.sql
  - [ ] 验证主题表数据
- [ ] 完善数据字典
- [ ] 完善指标口径文档

**产出**:
- fact_orders 事实表
- dm_kpi_daily, dm_state_daily, dm_category_daily, dm_customer_rfm 主题表
- 完整的数据字典
- 完整的指标口径文档

**验证命令**:
```sql
-- 检查事实表
SELECT COUNT(*) AS total_orders,
       SUM(item_gmv) AS total_gmv,
       AVG(item_gmv) AS avg_order_value
FROM fact_orders;

-- 检查主题表
SELECT * FROM dm_kpi_daily ORDER BY dt DESC LIMIT 10;
SELECT * FROM dm_state_daily ORDER BY dt DESC, state LIMIT 10;
SELECT * FROM dm_category_daily ORDER BY dt DESC, category LIMIT 10;
SELECT * FROM dm_customer_rfm ORDER BY monetary DESC LIMIT 10;
```

---

### Day 5-7: 专题分析（6-9小时）

#### Day 5: 留存与漏斗分析

**任务清单**:
- [ ] 留存 Cohort 分析
  - [ ] 执行 05_cohort_retention.sql
  - [ ] 导出结果到 CSV
  - [ ] 分析留存趋势
- [ ] 转化漏斗分析
  - [ ] 执行 06_funnel_analysis.sql
  - [ ] 识别流失环节
  - [ ] 提出优化建议

**产出**:
- 留存 Cohort 矩阵
- 转化漏斗数据
- 初步分析结论

#### Day 6: 销售与RFM分析

**任务清单**:
- [ ] 销售趋势分析
  - [ ] 执行 07_sales_trends.sql
  - [ ] 按月/周趋势分析
  - [ ] Top 品类/地区分析
- [ ] RFM 用户分层
  - [ ] 执行 09_rfm_segmentation.sql
  - [ ] 用户分层统计
  - [ ] 策略建议

**产出**:
- 销售趋势图表数据
- RFM 分层结果
- 用户运营建议

#### Day 7: 根因分析

**任务清单**:
- [ ] 差评根因分析
  - [ ] 执行 08_review_rootcause.sql
  - [ ] 履约时长 vs 评分分析
  - [ ] 差评 Top 品类/卖家
- [ ] 异常定位
  - [ ] 识别异常月份/地区
  - [ ] 交叉验证分析

**产出**:
- 差评根因分析报告
- 优化优先级建议

---

### Day 8-9: Tableau 看板（4-6小时）

#### Day 8: 看板设计与开发

**任务清单**:
- [ ] 连接 MySQL 数据库
- [ ] 创建数据模型
- [ ] Page 1: 经营总览
  - [ ] KPI 卡片（GMV/订单/客单/复购/差评）
  - [ ] 趋势图（按月）
  - [ ] Top 排行（品类/地区）
  - [ ] 切片器（时间/地区/品类）
- [ ] Page 2: 增长与用户
  - [ ] 新老客对比
  - [ ] Cohort 留存热力图
  - [ ] RFM 分层
- [ ] Page 3: 履约与体验
  - [ ] 物流链路时长
  - [ ] 准时率分析
  - [ ] 评分关联分析

**产出**:
- Tableau 文件（可选）
- 3 页交互式看板

#### Day 9: 看板优化与截图

**任务清单**:
- [ ] 优化看板设计
  - [ ] 调整配色
  - [ ] 优化布局
  - [ ] 添加交互
- [ ] 截图保存
  - [ ] 每页截图（高清）
  - [ ] 保存到 tableau/dashboard_screenshots/
- [ ] 测试交互功能

**产出**:
- 优化后的看板
- 3 页看板截图

---

### Day 10: 文档完善与总结（2-3小时）

**任务清单**:
- [ ] 填写分析报告
  - [ ] 核心发现（Top 3-5）
  - [ ] 优化建议（Top 2-3）
  - [ ] 风险与限制
- [ ] 完善 README
  - [ ] 更新项目状态
  - [ ] 添加核心发现
  - [ ] 更新交付物清单
- [ ] 准备简历描述
  - [ ] 基于 RESUME_TEMPLATE.md
  - [ ] 填写量化结果
  - [ ] 准备面试问题答案
- [ ] 整理代码与注释
- [ ] 更新 CHANGELOG

**产出**:
- 完整的分析报告
- 最终版 README
- 简历描述
- 可投递的项目仓库

---

## 最低完成标准（MVP）

要达到"可投递"状态，必须完成：

### 必须有（Must Have）
1. ✅ MySQL 数据库（包含事实表和主题表）
2. ✅ 指标口径文档（kpi_dictionary.md）
3. ✅ 数据字典（data_dictionary.md）
4. [ ] 至少 3 个专题分析 SQL（留存/漏斗/RFM）
5. [ ] Tableau 看板（至少 1 页总览）
6. [ ] 分析报告（analysis_summary.md）
7. [ ] 简历描述（基于 RESUME_TEMPLATE.md）

### 应该有（Should Have）
- [ ] Python 数据质量检查 Notebook
- [ ] 完整的 3 页 Tableau 看板
- [ ] 看板截图（每页）
- [ ] 5 个专题分析 SQL

### 可以有（Could Have）
- [ ] 更多专题分析（季节性/促销效果等）
- [ ] 交互式可视化（Plotly）
- [ ] 自动化报告生成脚本
- [ ] 视频演示

---

## 面试准备清单

### 必须能回答的问题

1. **数据建模**
   - 为什么选择星型模型？
   - 事实表和主题表的区别？
   - 如何保证数据质量？

2. **指标口径**
   - item_gmv 和 paid_gmv 的区别？
   - 如何定义有效订单？
   - 复购率如何计算？

3. **专题分析**
   - Cohort 留存分析的业务价值？
   - 如何定位差评根因？
   - RFM 分层的策略建议？

4. **BI 看板**
   - 为什么设计 3 页看板？
   - 如何选择可视化类型？
   - 如何优化看板性能？

5. **业务理解**
   - 核心发现是什么？
   - 优化建议是什么？
   - 如何衡量优化效果？

### 必须能展示的内容

1. **SQL 代码**
   - 留存 Cohort SQL
   - 转化漏斗 SQL
   - RFM 分层 SQL

2. **Tableau 看板**
   - 经营总览页
   - 增长与用户页
   - 履约与体验页

3. **文档**
   - 指标口径文档
   - 数据字典
   - 分析报告

---

## 常见问题与解决方案

### Q1: MySQL 导入数据慢怎么办？
**A**: 
- 临时禁用索引和外键约束
- 使用 `LOAD DATA LOCAL INFILE`
- 增加 `innodb_buffer_pool_size`

### Q2: Tableau 连接 MySQL 失败？
**A**:
- 安装 MySQL ODBC 驱动
- 检查 MySQL 服务是否运行
- 确认用户权限

### Q3: 如何设计 Cohort 留存分析？
**A**:
- 定义 Cohort（首购月）
- 计算后续月份复购率
- 使用热力图可视化

### Q4: 如何优化 SQL 查询性能？
**A**:
- 添加索引
- 使用临时表
- 避免子查询
- 使用 EXPLAIN 分析

---

## 时间管理建议

### 如果只有 5 天
- Day 1: 数据导入 + 建模
- Day 2-3: 核心专题分析（留存/漏斗/RFM）
- Day 4: Tableau 看板（1 页总览）
- Day 5: 文档完善

### 如果有 10 天
- 按完整路线图推进
- 有时间做更深入的分析
- 可以加入可选内容

### 如果有 15 天
- 完整路线图 + 可选内容
- 更多专题分析
- 视频演示
- 自动化脚本

---

## 下一步行动

**立即开始**:
1. [ ] 确认数据已下载
2. [ ] 导入数据到 MySQL
3. [ ] 验证数据完整性

**本周完成**:
- [ ] 完成数据建模
- [ ] 完成核心专题分析
- [ ] 产出初步结论

**下周完成**:
- [ ] 完成 Tableau 看板
- [ ] 完善文档
- [ ] 准备面试材料

---

**创建日期**: 2025-02  
**最后更新**: 2025-02  
**状态**: 进行中
