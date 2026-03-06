# 📁 项目目录结构说明

本文档说明 Olist 电商分析项目的目录结构和文件组织方式。

---

## 📂 完整目录树

```
olist_analytics/
│
├── 📄 README.md                    # 项目主文档（必读）
├── 📄 requirements.txt             # Python 依赖包列表
├── 📄 .gitignore                   # Git 忽略文件配置
│
├── 📁 archive/                     # 原始数据文件（不提交到 Git）
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_customers_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   └── product_category_name_translation.csv
│
├── 📁 data/                        # 数据处理目录
│   ├── raw/                        # 原始数据备份（可选）
│   └── processed/                  # 处理后的数据（CSV/Parquet）
│
├── 📁 sql/                         # SQL 脚本
│   ├── 00_setup/
│   │   ├── 01_create_tables.sql    # 建表脚本
│   │   └── 02_load_data.sql        # 数据导入脚本
│   ├── 10_model/
│   │   ├── 03_build_fact.sql       # 事实表构建
│   │   └── 04_build_dm.sql         # 主题表构建
│   └── 20_analysis/
│       ├── 05_cohort_retention.sql # Cohort 留存分析
│       ├── 06_funnel_analysis.sql  # 转化漏斗分析
│       ├── 07_sales_trends.sql     # 销售趋势分析（待创建）
│       └── 08_review_rootcause.sql # 差评根因分析（待创建）
│
├── 📁 notebooks/                   # Jupyter Notebook 分析
│   ├── 01_data_quality_checks.ipynb    # 数据质量检查
│   └── 02_feature_engineering.ipynb    # 特征工程（待创建）
│
├── 📁 scripts/                     # 自动化脚本
│   ├── quick_start.sh              # 快速启动脚本
│   └── export_results.sh           # 结果导出脚本（待创建）
│
├── 📁 results/                     # 查询结果输出
│   ├── cohort_retention.txt        # 留存分析结果
│   ├── funnel_analysis.txt         # 漏斗分析结果
│   └── ...                         # 其他分析结果
│
├── 📁 reports/                     # 分析报告
│   ├── analysis_report.md          # 可导出 PDF 的投递版报告
│   └── analysis_report.pdf         # 导出 PDF（可选）
│
├── 📁 tableau/                     # Tableau 截图交付物
│   ├── README.md
│   └── dashboard_screenshots/
│       ├── tableau_p1_overview.png
│       ├── tableau_p2_growth_drivers.png
│       ├── tableau_p3_funnel_retention.png
│       ├── tableau_p4_delivery_reviews.png
│       └── tableau_p5_rfm.png
│
├── 📁 docs/                        # 文档目录
│   ├── 📄 metric_dict.md           # 指标口径文档
│   ├── 📄 kpi_dictionary.md        # 指标字典
│   ├── 📄 analysis_summary.md      # 分析报告（Markdown）
│   ├── 📄 RESUME_TEMPLATE.md       # 简历写法参考
│   │
│   ├── 📁 guides/                  # 指南文档
│   │   ├── START_HERE.md           # 新手入门指南（必读）
│   │   ├── PROJECT_ROADMAP.md      # 项目路线图
│   │   ├── GITHUB_SETUP.md         # GitHub 上传指南
│   │   └── DIRECTORY_STRUCTURE.md  # 本文档
│   │
│   └── 📁 screenshots/             # 截图目录
│       ├── tableau/                # Tableau 看板截图
│       │   ├── tableau_p1_overview.png
│       │   ├── tableau_p2_growth_drivers.png
│       │   ├── tableau_p3_funnel_retention.png
│       │   ├── tableau_p4_delivery_reviews.png
│       │   └── tableau_p5_rfm.png
│       └── sql_results/            # SQL 查询结果截图
│           ├── cohort_retention.png
│           └── funnel_analysis.png
```

---

## 📋 目录说明

### 根目录文件

| 文件 | 说明 | 重要性 |
|------|------|--------|
| `README.md` | 项目主文档，包含项目介绍、技术栈、使用方法 | ⭐⭐⭐⭐⭐ |
| `requirements.txt` | Python 依赖包列表 | ⭐⭐⭐⭐ |
| `.gitignore` | Git 忽略文件配置，避免上传大文件 | ⭐⭐⭐⭐ |

### 📁 archive/ - 原始数据

**用途**: 存放从 Kaggle 下载的原始 CSV 数据文件

**注意事项**:
- ⚠️ 不要提交到 Git（已在 .gitignore 中配置）
- ✅ 保持原始数据不变，不要修改
- ✅ 如果数据损坏，可以重新下载

**包含文件**: 9 个 CSV 文件（订单、商品、支付、评价等）

### 📁 data/ - 数据处理

**用途**: 存放数据处理过程中的中间文件和结果

**子目录**:
- `raw/`: 原始数据备份（可选）
- `processed/`: 清洗后的数据、特征工程结果

**使用场景**:
- Python 数据清洗后的输出
- 用于 BI 工具的预处理数据
- 中间计算结果

### 📁 sql/ - SQL 脚本

**用途**: 存放所有 SQL 查询脚本

**命名规范**: `序号_功能描述.sql`

**脚本分类**:
1. **基础脚本** (00_setup): 建表、导入
2. **建模脚本** (10_model): 事实表、主题表
3. **专题分析** (20_analysis): 留存、漏斗、趋势、根因

**最佳实践**:
- ✅ 每个脚本包含清晰的注释
- ✅ 可独立运行（不依赖其他脚本）
- ✅ 包含业务问题说明和结论

### 📁 notebooks/ - Jupyter Notebook

**用途**: Python 数据分析和可视化

**命名规范**: `序号_功能描述.ipynb`

**包含内容**:
- 数据质量检查
- 特征工程
- 探索性数据分析（EDA）
- 统计分析和可视化

**运行方式**:
```bash
source venv/bin/activate
jupyter notebook notebooks/
```

### 📁 scripts/ - 自动化脚本

**用途**: 存放自动化脚本和工具

**包含脚本**:
- `quick_start.sh`: 一键启动项目
- `export_results.sh`: 批量导出查询结果
- 其他自动化工具

**使用方式**:
```bash
chmod +x scripts/quick_start.sh
./scripts/quick_start.sh
```

### 📁 results/ - 查询结果

**用途**: 存放 SQL 查询结果和分析输出

**文件格式**:
- `.txt`: 文本格式查询结果
- `.csv`: CSV 格式数据导出
- `.json`: JSON 格式结果

**生成方式**:
```bash
mysql -u root -p db_olist < sql/20_analysis/05_cohort_retention.sql > results/cohort_retention.txt
```

### 📁 docs/ - 文档

**用途**: 存放所有项目文档

#### 根目录文档
- `metric_dict.md`: 指标口径说明（核心文档）
- `analysis_summary.md`: 分析报告
- `RESUME_TEMPLATE.md`: 简历写法参考

#### 📁 guides/ - 指南文档
- `START_HERE.md`: 新手入门指南（⭐ 必读）
- `PROJECT_ROADMAP.md`: 10 天实施计划
- `GITHUB_SETUP.md`: GitHub 上传步骤
- `DIRECTORY_STRUCTURE.md`: 本文档

#### 📁 screenshots/ - 截图
- `tableau/`: Tableau 看板截图
- `sql_results/`: SQL 查询结果截图

**截图规范**:
- 格式: PNG（高清）
- 命名: `功能_描述.png`
- 尺寸: 1920x1080 或更高

### 📁 tableau/ - Tableau 文件（可选）

**用途**: 存放 Tableau 看板文件

**注意事项**:
- 你可以只上传截图到 `tableau/dashboard_screenshots/`
- 截图命名统一（例如：`page1_overview.png`）

---

## 🔄 工作流程

### 1. 数据准备阶段
```
archive/ (下载数据) → sql/00_setup (导入) → MySQL 数据库
```

### 2. 数据建模阶段
```
sql/10_model (建模) → fact_orders + dm_* 表
```

### 3. 分析阶段
```
sql/20_analysis (专题分析) → results/ (结果输出)
notebooks/ (Python 分析) → data/processed/
```

### 4. 可视化阶段
```
MySQL → Tableau → tableau/dashboard_screenshots/
```

### 5. 文档阶段
```
reports/analysis_report.md (撰写) → PDF (导出)
```

### 6. 发布阶段
```
整理文件 → Git 提交 → GitHub 推送
```

---

## 📝 文件命名规范

### SQL 脚本
- 格式: `序号_功能描述.sql`
- 示例: `05_cohort_retention.sql`

### Notebook
- 格式: `序号_功能描述.ipynb`
- 示例: `01_data_quality_checks.ipynb`

### 截图
- 格式: `类型_描述.png`
- 示例: `page1_overview.png`

### 结果文件
- 格式: `分析名称.txt/csv`
- 示例: `cohort_retention.txt`

---

## 🚫 不要提交到 Git 的文件

已在 `.gitignore` 中配置：

```
# 数据文件
archive/*.csv
data/raw/*.csv
data/processed/*.csv
*.csv

# Python
__pycache__/
venv/
*.ipynb_checkpoints/

# macOS
.DS_Store

# Tableau（可选）
*.pbix

# 结果文件（可选）
results/*.txt
```

---

## ✅ 目录整理检查清单

在提交到 GitHub 前，确认：

- [ ] 所有 CSV 数据文件在 `archive/` 目录
- [ ] SQL 脚本在 `sql/` 目录，按序号命名
- [ ] Notebook 在 `notebooks/` 目录
- [ ] 文档在 `docs/` 目录，分类清晰
- [ ] 截图在 `docs/screenshots/` 对应子目录
- [ ] 脚本在 `scripts/` 目录且可执行
- [ ] `.gitignore` 正确配置
- [ ] 没有临时文件或系统文件（.DS_Store）
- [ ] README.md 在根目录且内容完整

---

## 🔧 目录维护

### 添加新的 SQL 分析
```bash
# 创建新脚本
touch sql/20_analysis/09_new_analysis.sql

# 运行并保存结果
mysql -u root -p db_olist < sql/20_analysis/09_new_analysis.sql > results/new_analysis.txt
```

### 添加新的 Notebook
```bash
# 在 Jupyter 中创建
jupyter notebook notebooks/

# 命名: 03_new_analysis.ipynb
```

### 添加新的截图
```bash
# 保存到对应目录
docs/screenshots/tableau/page4_new.png
docs/screenshots/sql_results/new_analysis.png
```

---

## 📚 相关文档

- [新手入门指南](START_HERE.md) - 从这里开始
- [项目路线图](PROJECT_ROADMAP.md) - 10 天实施计划
- [GitHub 上传指南](GITHUB_SETUP.md) - 如何上传到 GitHub
- [简历写法参考](../RESUME_TEMPLATE.md) - 如何写简历

---

**最后更新**: 2025-02-08  
**维护者**: 项目作者
