# 🚀 从这里开始 - Olist 电商分析项目

欢迎！这是你的第一个数据分析作品集项目。

---

## 📋 项目概述

**项目名称**: Olist 电商经营分析与指标监控看板  
**项目类型**: 个人作品集项目  
**技术栈**: MySQL, SQL, Tableau, Python  
**预计时间**: 10-15 天  
**当前状态**: 🟡 基础结构完成，待完善分析

---

## 🎯 项目目标

通过这个项目，你将：
1. ✅ 展示完整的数据分析流程（建模 → 分析 → 可视化 → 报告）
2. ✅ 掌握 SQL 数据建模与专题分析
3. ✅ 产出可投递的 GitHub 项目
4. ✅ 准备好面试所需的代码、看板、报告

---

## 🏃 快速开始（3 步）

### Step 1: 确认数据已准备

检查 `archive/` 目录是否包含以下 CSV 文件：
```
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_customers_dataset.csv
olist_order_reviews_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
olist_geolocation_dataset.csv
product_category_name_translation.csv
```

如果没有，请从 [Kaggle](https://www.kaggle.com/olistbr/brazilian-ecommerce) 下载。

### Step 2: 导入数据到 MySQL

```bash
# 1. 创建数据库并建表
mysql --local-infile=1 -u root -p < sql/00_setup/01_create_tables.sql

# 2. 导入数据
mysql --local-infile=1 -u root -p < sql/00_setup/02_load_data.sql

# 3. 构建事实表
mysql --local-infile=1 -u root -p < sql/10_model/03_build_fact.sql

# 4. 构建主题表
mysql --local-infile=1 -u root -p < sql/10_model/04_build_dm.sql
```

### Step 3: 验证数据

```sql
-- 登录 MySQL
mysql -u root -p

-- 切换数据库
USE db_olist;

-- 检查表
SHOW TABLES;

-- 检查数据量
SELECT 'stg_orders' AS table_name, COUNT(*) AS row_count FROM stg_orders
UNION ALL
SELECT 'fact_orders', COUNT(*) FROM fact_orders
UNION ALL
SELECT 'dm_kpi_daily', COUNT(*) FROM dm_kpi_daily;
```

---

## 📁 项目结构一览

```
olist_analytics/
├── 📄 README.md                    # 项目主文档
├── 📄 START_HERE.md                # 本文件（快速开始）
│
├── 📂 archive/                     # 原始数据（9个CSV文件）
│
├── 📂 sql/                         # SQL 脚本
│   ├── 00_setup/                   # 建表与导入
│   ├── 10_model/                   # 事实表与主题表
│   └── 20_analysis/                # 专题分析
│
├── 📂 notebooks/                   # Python 分析
│   └── 01_data_quality_checks.ipynb
│
├── 📂 docs/                        # 文档
│   ├── kpi_dictionary.md           # 指标口径 ⭐
│   ├── data_dictionary.md          # 数据字典 ⭐
│   ├── analysis_summary.md         # 分析报告
│   └── RESUME_TEMPLATE.md          # 简历写法参考 ⭐
│
└── 📂 tableau/                     # Tableau 看板
    └── dashboard_screenshots/      # 看板截图
```

**⭐ 标记的是核心文档，优先关注！**

---

## 📚 核心文档导航

### 1️⃣ 开始分析前必读

- **[PROJECT_ROADMAP.md](PROJECT_ROADMAP.md)**: 10天推进计划
- **[data_dictionary.md](../data_dictionary.md)**: 数据字典
- **[kpi_dictionary.md](../kpi_dictionary.md)**: 指标口径

### 2️⃣ 分析过程中参考

- **SQL 脚本**: `sql/20_analysis/` 目录
- **Python Notebook**: `notebooks/01_data_quality_checks.ipynb`

### 3️⃣ 完成分析后填写

- **[analysis_summary.md](../analysis_summary.md)**: 分析报告
- **[RESUME_TEMPLATE.md](../RESUME_TEMPLATE.md)**: 简历写法参考

---

## 🗓️ 推荐推进计划（10天）

### Day 1-2: 环境搭建与数据导入
- [ ] 下载数据集
- [ ] 导入 MySQL
- [ ] 验证数据完整性

### Day 3-4: 数据建模
- [ ] 构建事实表（fact_orders）
- [ ] 构建主题表（dm_*）
- [ ] 验证数据质量

### Day 5-7: 专题分析
- [ ] 留存 Cohort 分析
- [ ] 转化漏斗分析
- [ ] RFM 用户分层
- [ ] 销售趋势分析
- [ ] 差评根因分析

### Day 8-9: Tableau 看板
- [ ] 连接 MySQL
- [ ] 创建 3 页看板
- [ ] 截图保存

### Day 10: 文档完善
- [ ] 填写分析报告
- [ ] 完善 README
- [ ] 准备简历描述

---

## 🎓 学习资源

### MySQL
- [MySQL 官方文档](https://dev.mysql.com/doc/)
- [SQL 窗口函数教程](https://www.mysqltutorial.org/mysql-window-functions/)

### Tableau
- [Tableau 学习路径](https://www.tableau.com/learn)

### Python
- [pandas 文档](https://pandas.pydata.org/docs/)
- [Jupyter Notebook 教程](https://jupyter.org/documentation)

---

## ✅ 完成标准（MVP）

要达到"可投递"状态，必须完成：

1. ✅ MySQL 数据库（包含事实表和主题表）
2. ✅ 至少 3 个专题分析 SQL（留存/漏斗/RFM）
3. ✅ Tableau 看板（至少 1 页总览）
4. ✅ 指标口径文档（kpi_dictionary.md）
5. ✅ 分析报告（analysis_summary.md）
6. ✅ 简历描述（基于 RESUME_TEMPLATE.md）

---

## 🤔 常见问题

### Q1: MySQL 导入数据失败？
A: 检查以下几点：
- 确认 `local_infile` 已启用: `SET GLOBAL local_infile = 1;`
- 检查文件路径是否正确（使用绝对路径）
- 确认文件编码为 UTF-8

### Q2: 如何连接 Tableau 到 MySQL？
A: 
1. 安装 MySQL 驱动（按 Tableau 官方文档选择对应版本）
2. 在 Tableau 中选择"连接到数据" → "MySQL"
3. 输入服务器地址（localhost）和数据库名（db_olist）

### Q3: 如何运行 SQL 脚本？
A:
```bash
# 方法1: 命令行
mysql -u root -p < sql/20_analysis/05_cohort_retention.sql

# 方法2: MySQL Workbench
# 打开文件 → 执行
```

### Q4: Python Notebook 如何连接 MySQL？
A: 使用 `pymysql` 或 `mysql-connector-python`：
```python
import pymysql
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='your_password',
    database='db_olist'
)
```

---

## 📞 需要帮助？

### 项目文档
- 快速开始: START_HERE.md（本文件）
- 项目路线: PROJECT_ROADMAP.md
- 目录结构: DIRECTORY_STRUCTURE.md

### 技术文档
- 数据字典: data_dictionary.md
- 指标口径: kpi_dictionary.md
- SQL 脚本: sql/ 目录

### 面试准备
- 简历模板: RESUME_TEMPLATE.md
- 分析报告: analysis_summary.md

---

## 🎉 准备好了吗？

现在就开始吧！

1. ✅ 确认数据已下载
2. ✅ 导入数据到 MySQL
3. ✅ 开始专题分析

 

---

**创建日期**: 2025-02  
**项目负责人**: hzhaan  
**项目状态**: 🟡 进行中
