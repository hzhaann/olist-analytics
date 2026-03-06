# GitHub 仓库设置指南 - Olist 电商分析

## 目标

将 `olist_analytics` 项目上传到 GitHub，作为作品集展示。

---

## 步骤 1: 创建 GitHub 仓库

### 1.1 登录 GitHub
访问 [github.com](https://github.com) 并登录你的账号。

### 1.2 创建新仓库
1. 点击右上角的 `+` 号
2. 选择 `New repository`
3. 填写仓库信息：
   - **Repository name**: `olist-ecommerce-analytics`
   - **Description**: `E-Commerce Business Analysis with MySQL, Tableau & Python - KPI Dashboard, Cohort Retention, Funnel Analysis, RFM Segmentation`
   - **Public/Private**: 选择 `Public`（作品集项目建议公开）
   - **不要勾选** "Initialize this repository with a README"（我们已经有了）
4. 点击 `Create repository`

---

## 步骤 2: 初始化本地 Git 仓库

在项目根目录下运行：

```bash
cd olist_analytics

# 初始化 Git 仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Complete Olist e-commerce analytics project"
```

---

## 步骤 3: 连接到 GitHub 远程仓库

将 `<your-username>` 替换为你的 GitHub 用户名：

```bash
# 添加远程仓库
git remote add origin https://github.com/<your-username>/olist-ecommerce-analytics.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

---

## 步骤 4: 验证上传

1. 访问你的 GitHub 仓库页面
2. 确认所有文件都已上传
3. 检查 README.md 是否正确显示

---

## 步骤 5: 完善 GitHub 仓库

### 5.1 添加 Topics（标签）

在仓库页面点击 `Add topics`，添加：
- `data-analysis`
- `mysql`
- `sql`
- `tableau`
- `python`
- `business-intelligence`
- `ecommerce`
- `portfolio`
- `data-visualization`
- `cohort-analysis`
- `rfm-analysis`

### 5.2 添加 About（简介）

在仓库页面右侧的 `About` 部分：
- **Description**: `E-Commerce Business Analysis with MySQL, Tableau & Python - KPI Dashboard, Cohort Retention, Funnel Analysis, RFM Segmentation`
- **Website**: 可以留空或添加你的个人网站
- **Topics**: 已在上一步添加

### 5.3 固定仓库（Pin Repository）

在你的 GitHub 个人主页：
1. 点击 `Customize your pins`
2. 选择 `olist-ecommerce-analytics`
3. 保存

---

## 步骤 6: 后续更新

每次完成新的分析或更新文档后：

```bash
# 查看修改
git status

# 添加修改的文件
git add .

# 提交
git commit -m "描述你的修改"

# 推送到 GitHub
git push
```

### 提交信息（Commit Message）建议

- `feat: Add cohort retention analysis`
- `docs: Update analysis summary with findings`
- `fix: Correct SQL query in funnel analysis`
- `refactor: Optimize fact table creation`
- `style: Update Tableau dashboard design`
- `data: Add processed data files`

---

## Git 常用命令速查

### 查看状态
```bash
git status                 # 查看当前状态
git log                    # 查看提交历史
git diff                   # 查看修改内容
```

### 分支管理
```bash
git branch                 # 查看分支
git branch <name>          # 创建分支
git checkout <name>        # 切换分支
git merge <name>           # 合并分支
```

### 撤销操作
```bash
git checkout -- <file>     # 撤销文件修改
git reset HEAD <file>      # 取消暂存
git reset --hard HEAD^     # 回退到上一个版本
```

### 远程操作
```bash
git remote -v              # 查看远程仓库
git pull                   # 拉取远程更新
git push                   # 推送到远程
```

---

## 注意事项

### ✅ 应该提交的文件
- 代码文件（`.sql`, `.py`, `.ipynb`）
- 文档文件（`.md`）
- 配置文件（`requirements.txt`, `.gitignore`）
- 脚本文件（`.sh`）
- 看板截图（`.png`, `.jpg`）
- 占位文件（`.gitkeep`）

### ❌ 不应该提交的文件
- 原始数据文件（`archive/*.csv`）
- 处理后的数据文件（`data/processed/*.csv`）
- 虚拟环境（`venv/`）
- IDE 配置（`.vscode/`, `.idea/`）
- 系统文件（`.DS_Store`, `Thumbs.db`）
- Python 缓存（`__pycache__/`, `*.pyc`）
- Tableau 工作簿（如 `.twbx` - 太大，可以提供下载链接）

这些已经在 `.gitignore` 中配置好了。

---

## 简历中如何引用

在简历的项目描述中添加 GitHub 链接：

```
跨境电商经营分析与指标监控看板（Olist 数据集）｜个人项目｜2025.03 - 2025.06

- 项目描述：...
- 核心工作：...
- GitHub: https://github.com/<your-username>/olist-ecommerce-analytics
```

---

## 面试时如何展示

### 方式 1: 直接打开 GitHub 仓库
- 展示 README（项目概述）
- 展示 SQL 脚本（专题分析）
- 展示文档（指标口径、分析报告）

### 方式 2: 本地演示
```bash
# 打开 MySQL
mysql -u root -p

# 切换数据库
USE db_olist;

# 展示查询结果
SELECT * FROM dm_kpi_daily ORDER BY dt DESC LIMIT 10;
```

### 方式 3: 展示 Tableau 看板
- 打开 Tableau
- 演示交互功能

---

## 常见问题

### Q1: 如何删除已提交的大文件？
A: 如果不小心提交了大文件（如数据集）：
```bash
git rm --cached archive/*.csv
git commit -m "Remove large data files"
git push
```

### Q2: 如何修改最后一次提交？
A: 
```bash
git commit --amend -m "新的提交信息"
git push --force
```

### Q3: 如何创建 .gitignore？
A: 项目已经包含 .gitignore 文件，内容如下：
```
# Data files
archive/*.csv
data/raw/*.csv
data/processed/*.csv

# Python
__pycache__/
*.py[cod]
venv/

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Tableau
*.twb
*.twbx
```

### Q4: 如何添加 README Badge？
A: 在 README.md 顶部添加：
```markdown
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![Python](https://img.shields.io/badge/Python-3.8+-green)
![Tableau](https://img.shields.io/badge/Tableau-Latest-orange)
![License](https://img.shields.io/badge/License-MIT-green)
```

---

## 进阶：使用 GitHub Actions（可选）

可以设置自动化测试：

创建 `.github/workflows/test.yml`：
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    - name: Run tests
      run: |
        python -m pytest tests/
```

---

**创建日期**: 2025-02  
**最后更新**: 2025-02
