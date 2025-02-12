{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('product_category_translation') }}