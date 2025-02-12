{{ config(materialized='view') }}

WITH items AS (
    SELECT *
    FROM {{ ref('stg_order_items') }}
),
products AS (
    SELECT product_id,
           product_category_name,
           product_weight_g,
           product_length_cm,
           product_height_cm,
           product_width_cm
    FROM {{ ref('stg_products') }}
),
sellers AS (
    SELECT seller_id, seller_city, seller_state
    FROM {{ ref('stg_sellers') }}
)

SELECT
    i.order_id,
    i.product_id,
    p.product_category_name,
    i.seller_id,
    s.seller_city,
    s.seller_state,
    i.price,
    i.freight_value
FROM items i
LEFT JOIN products p ON i.product_id = p.product_id
LEFT JOIN sellers s ON i.seller_id = s.seller_id;