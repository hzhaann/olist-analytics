USE db_olist;
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_orders_dataset.csv' INTO TABLE stg_orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  order_id,
  customer_id,
  order_status,
  @order_purchase_timestamp,
  @order_approved_at,
  @order_delivered_carrier_date,
  @order_delivered_customer_date,
  @order_estimated_delivery_date
)
SET order_purchase_timestamp = NULLIF(@order_purchase_timestamp, ''),
  order_approved_at = NULLIF(@order_approved_at, ''),
  order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date, ''),
  order_delivered_customer_date = NULLIF(@order_delivered_customer_date, ''),
  order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date, '');
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_order_items_dataset.csv' INTO TABLE stg_order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  order_id,
  order_item_id,
  product_id,
  seller_id,
  @shipping_limit_date,
  price,
  freight_value
)
SET shipping_limit_date = NULLIF(@shipping_limit_date, '');
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_order_payments_dataset.csv' INTO TABLE stg_order_payments FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  order_id,
  payment_sequential,
  payment_type,
  payment_installments,
  payment_value
);
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_customers_dataset.csv' INTO TABLE stg_customers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix,
  customer_city,
  customer_state
);
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_order_reviews_dataset.csv' INTO TABLE stg_reviews FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  review_id,
  order_id,
  review_score,
  review_comment_title,
  review_comment_message,
  @review_creation_date,
  @review_answer_timestamp
)
SET review_creation_date = NULLIF(@review_creation_date, ''),
  review_answer_timestamp = NULLIF(@review_answer_timestamp, '');
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_products_dataset.csv' INTO TABLE stg_products FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  product_id,
  product_category_name,
  product_name_lenght,
  product_description_lenght,
  product_photos_qty,
  product_weight_g,
  product_length_cm,
  product_height_cm,
  product_width_cm
);
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_sellers_dataset.csv' INTO TABLE stg_sellers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  seller_id,
  seller_zip_code_prefix,
  seller_city,
  seller_state
);
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/product_category_name_translation.csv' INTO TABLE stg_product_category_translation FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  product_category_name,
  product_category_name_english
);
LOAD DATA LOCAL INFILE '/Users/hzh/Desktop/就业/olist_analytics/archive/olist_geolocation_dataset.csv' INTO TABLE stg_geolocation FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (
  geolocation_zip_code_prefix,
  geolocation_lat,
  geolocation_lng,
  geolocation_city,
  geolocation_state
);