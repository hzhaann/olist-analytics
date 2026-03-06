#!/bin/bash

# Olist 项目快速启动脚本
# 用途：自动化环境配置和数据导入

echo "================================"
echo "Olist 电商分析项目 - 快速启动"
echo "================================"

# 检查 Python 是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误: 未找到 Python3，请先安装 Python"
    exit 1
fi

# 检查 MySQL 是否安装
if ! command -v mysql &> /dev/null; then
    echo "❌ 错误: 未找到 MySQL，请先安装 MySQL"
    exit 1
fi

echo ""
echo "步骤 1/5: 检查数据文件..."
if [ ! -d "archive" ] || [ -z "$(ls -A archive/*.csv 2>/dev/null)" ]; then
    echo "⚠️  警告: archive/ 目录下未找到 CSV 文件"
    echo "请从 Kaggle 下载 Olist 数据集并解压到 archive/ 目录"
    echo "下载地址: https://www.kaggle.com/olistbr/brazilian-ecommerce"
    read -p "是否已下载数据？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "步骤 2/5: 创建 Python 虚拟环境..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✓ 虚拟环境创建成功"
else
    echo "✓ 虚拟环境已存在"
fi

echo ""
echo "步骤 3/5: 安装 Python 依赖..."
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo "✓ 依赖安装完成"

echo ""
echo "步骤 4/5: 导入数据到 MySQL..."
read -p "请输入 MySQL 用户名 (默认: root): " mysql_user
mysql_user=${mysql_user:-root}

read -sp "请输入 MySQL 密码: " mysql_pass
echo

echo "正在执行 SQL 脚本..."
mysql --local-infile=1 -u "$mysql_user" -p"$mysql_pass" < sql/00_setup/01_create_tables.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ 建表完成"
else
    echo "❌ 建表失败，请检查 MySQL 连接"
    exit 1
fi

mysql --local-infile=1 -u "$mysql_user" -p"$mysql_pass" < sql/00_setup/02_load_data.sql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ 数据导入完成"
else
    echo "⚠️  数据导入可能失败，请检查文件路径"
fi

mysql --local-infile=1 -u "$mysql_user" -p"$mysql_pass" < sql/10_model/03_build_fact.sql 2>/dev/null
echo "✓ 事实表构建完成"

mysql --local-infile=1 -u "$mysql_user" -p"$mysql_pass" < sql/10_model/04_build_dm.sql 2>/dev/null
echo "✓ 主题表构建完成"

echo ""
echo "步骤 5/5: 启动 Jupyter Notebook..."
echo "Jupyter 将在浏览器中打开，按 Ctrl+C 退出"
echo ""
jupyter notebook notebooks/

echo ""
echo "================================"
echo "✓ 项目启动完成！"
echo "================================"
echo ""
echo "下一步："
echo "1. 在 Jupyter 中运行 01_data_quality_checks.ipynb"
echo "2. 使用 Power BI/Tableau 连接 MySQL 数据库"
echo "3. 执行专题分析 SQL (sql/05_*.sql)"
echo ""
