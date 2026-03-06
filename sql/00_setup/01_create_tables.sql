CREATE DATABASE IF NOT EXISTS db_olist;
USE db_olist;
DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders (
  order_id VARCHAR(40) NOT NULL,
  customer_id VARCHAR(40) NOT NULL,
  order_status VARCHAR(20) NOT NULL,
  order_purchase_timestamp DATETIME NULL,
  order_approved_at DATETIME NULL,
  order_delivered_carrier_date DATETIME NULL,
  order_delivered_customer_date DATETIME NULL,
  order_estimated_delivery_date DATETIME NULL,
  PRIMARY KEY (order_id)
);
DROP TABLE IF EXISTS stg_order_items;
CREATE TABLE stg_order_items (
  order_id VARCHAR(40) NOT NULL,
  order_item_id INT NOT NULL,
  product_id VARCHAR(40) NOT NULL,
  seller_id VARCHAR(40) NOT NULL,
  shipping_limit_date DATETIME NULL,
  price DECIMAL(12, 2) NULL,
  freight_value DECIMAL(12, 2) NULL,
  PRIMARY KEY (order_id, order_item_id)
);
DROP TABLE IF EXISTS stg_order_payments;
CREATE TABLE stg_order_payments (
  order_id VARCHAR(40) NOT NULL,
  payment_sequential INT NOT NULL,
  payment_type VARCHAR(20) NULL,
  payment_installments INT NULL,
  payment_value DECIMAL(12, 2) NULL,
  PRIMARY KEY (order_id, payment_sequential)
);
DROP TABLE IF EXISTS stg_customers;
CREATE TABLE stg_customers (
  customer_id VARCHAR(40) NOT NULL,
  customer_unique_id VARCHAR(40) NOT NULL,
  customer_zip_code_prefix INT NULL,
  customer_city VARCHAR(60) NULL,
  customer_state VARCHAR(2) NULL,
  PRIMARY KEY (customer_id)
);
DROP TABLE IF EXISTS stg_reviews;
CREATE TABLE stg_reviews (
  review_id VARCHAR(40) NOT NULL,
  order_id VARCHAR(40) NOT NULL,
  review_score INT NULL,
  review_comment_title TEXT NULL,
  review_comment_message TEXT NULL,
  review_creation_date DATETIME NULL,
  review_answer_timestamp DATETIME NULL,
  PRIMARY KEY (review_id),
  KEY idx_reviews_order_id (order_id)
);
DROP TABLE IF EXISTS stg_products;
CREATE TABLE stg_products (
  product_id VARCHAR(40) NOT NULL,
  product_category_name VARCHAR(60) NULL,
  product_name_lenght INT NULL,
  product_description_lenght INT NULL,
  product_photos_qty INT NULL,
  product_weight_g INT NULL,
  product_length_cm INT NULL,
  product_height_cm INT NULL,
  product_width_cm INT NULL,
  PRIMARY KEY (product_id)
);
DROP TABLE IF EXISTS stg_sellers;
CREATE TABLE stg_sellers (
  seller_id VARCHAR(40) NOT NULL,
  seller_zip_code_prefix INT NULL,
  seller_city VARCHAR(60) NULL,
  seller_state VARCHAR(2) NULL,
  PRIMARY KEY (seller_id)
);
DROP TABLE IF EXISTS stg_product_category_translation;
CREATE TABLE stg_product_category_translation (
  product_category_name VARCHAR(60) NOT NULL,
  product_category_name_english VARCHAR(60) NULL,
  PRIMARY KEY (product_category_name)
);
DROP TABLE IF EXISTS stg_geolocation;
CREATE TABLE stg_geolocation (
  geolocation_zip_code_prefix INT NULL,
  geolocation_lat DECIMAL(10, 6) NULL,
  geolocation_lng DECIMAL(10, 6) NULL,
  geolocation_city VARCHAR(60) NULL,
  geolocation_state VARCHAR(2) NULL
);