{{ config(materialized='view') }}

WITH products AS (
    SELECT *
    FROM {{ ref('stg_products') }}
),
translation AS (
    SELECT product_category_name,
           product_category_name_english
    FROM {{ ref('stg_product_category_translation') }}
)

SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN translation t
    ON p.product_category_name = t.product_category_name;