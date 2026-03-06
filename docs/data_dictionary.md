# Data Dictionary（Olist 电商项目）

本文档用于说明本项目在 MySQL（`db_olist`）中的核心表结构、粒度、主键/关联关系与关键字段口径。

## 1. 数据库与表分层

- 数据库：`db_olist`
- 分层：
  - `stg_*`：原始 CSV 导入的暂存层（字段基本与数据集一致）
  - `fact_*`：事实表（业务过程汇总后的核心分析表）
  - `dm_*`：数据集市/主题表（面向 BI 报表、性能更好）

## 2. 暂存层（stg）

### 2.1 `stg_orders`（订单主表）

- 粒度：`order_id`（一行一个订单）
- 主键：`order_id`
- 关键字段：
  - `customer_id`：下单时的客户 ID（注意不是去重后的唯一客户）
  - `order_status`：订单状态
  - `order_purchase_timestamp`：下单时间
  - `order_delivered_customer_date`：送达时间
  - `order_estimated_delivery_date`：预计送达时间

### 2.2 `stg_order_items`（订单明细表）

- 粒度：`order_id` + `order_item_id`（一行一个订单行）
- 主键：`(order_id, order_item_id)`
- 关键字段：
  - `product_id`：商品 ID
  - `seller_id`：卖家 ID
  - `price`：商品价格
  - `freight_value`：运费

### 2.3 `stg_order_payments`（支付流水表）

- 粒度：`order_id` + `payment_sequential`（同一订单可能多笔支付）
- 主键：`(order_id, payment_sequential)`
- 关键字段：
  - `payment_type`：支付方式
  - `payment_value`：支付金额

### 2.4 `stg_customers`（客户表）

- 粒度：`customer_id`
- 主键：`customer_id`
- 关键字段：
  - `customer_unique_id`：去重后的客户唯一 ID（用于复购/留存口径）
  - `customer_state` / `customer_city`：地区信息

### 2.5 `stg_reviews`（订单评价表）

- 粒度：`review_id`（一行一条评价）
- 主键：`review_id`
- 索引：`order_id`
- 关键字段：
  - `order_id`：关联订单
  - `review_score`：评分（1-5）
  - `review_creation_date`：评价创建时间

### 2.6 `stg_products`（商品表）

- 粒度：`product_id`
- 主键：`product_id`
- 关键字段：
  - `product_category_name`：葡语类目

### 2.7 `stg_product_category_translation`（类目翻译表）

- 粒度：`product_category_name`
- 主键：`product_category_name`
- 关键字段：
  - `product_category_name_english`：英文类目

### 2.8 `stg_sellers`（卖家表）

- 粒度：`seller_id`
- 主键：`seller_id`

### 2.9 `stg_geolocation`（地理位置表）

- 粒度：邮编前缀 + 坐标（该表可能存在重复行）
- 主键：无（原始数据特性）

## 3. 事实层（fact）

### 3.1 `fact_orders`（订单事实表）

- 粒度：`order_id`（一行一个“有效订单”）
- 主键：`order_id`
- 过滤口径：仅保留 `stg_orders.order_status = 'delivered'`
- 关键字段与口径：
  - `customer_unique_id`：来自 `stg_customers`，用于留存/复购
  - `purchase_date`：下单日期（`DATE(order_purchase_timestamp)`）
  - `item_gmv`：订单维度 GMV（按订单明细汇总 `sum(price + freight_value)`）
  - `paid_gmv`：订单维度实付（按支付汇总 `sum(payment_value)`）
  - `delivery_days`：下单到送达天数
  - `delay_days`：晚到天数（晚于预计送达的天数，最小为 0）
  - `ontime_flag`：是否准时（1/0/NULL）
  - `bad_review_flag`：是否差评（评分 <= 2 记为 1，否则 0）

## 4. 主题层（dm）

### 4.1 `dm_kpi_daily`（日粒度经营指标）

- 粒度：`dt`（天）
- 主键：`dt`
- 指标：订单数、买家数、GMV、客单价、履约/体验指标等

### 4.2 `dm_state_daily`（日粒度 x 州）

- 粒度：`dt` + `state`
- 用途：地区下钻分析、地图可视化

### 4.3 `dm_category_daily`（日粒度 x 类目）

- 粒度：`dt` + `category`
- 类目口径：优先使用英文类目（翻译表），缺失则使用葡语类目，否则为 `unknown`

### 4.4 `dm_customer_rfm`（客户粒度 RFM 基础指标）

- 粒度：`customer_unique_id`
- 主键：`customer_unique_id`
- 字段：
  - `recency_days`：距离分析基准日的天数
  - `frequency`：购买次数（有效订单）
  - `monetary`：累计消费（`item_gmv`）

## 5. 关系说明（简化）

- `stg_orders.customer_id` → `stg_customers.customer_id`
- `stg_order_items.order_id` → `stg_orders.order_id`
- `stg_order_items.product_id` → `stg_products.product_id`
- `stg_order_items.seller_id` → `stg_sellers.seller_id`
- `stg_reviews.order_id` → `stg_orders.order_id`
- `stg_products.product_category_name` → `stg_product_category_translation.product_category_name`

## 6. 与指标口径文档的对应

- 指标口径与定义：见 `docs/metric_dict.md` 或 `docs/kpi_dictionary.md`
