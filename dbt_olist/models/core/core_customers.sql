{{ config(materialized='view') }}

WITH customers AS (
    SELECT *
    FROM {{ ref('stg_customers') }}
),
geolocation AS (
    SELECT geolocation_zip_code_prefix,
           geolocation_lat,
           geolocation_lng,
           geolocation_city,
           geolocation_state
    FROM {{ ref('stg_geolocation') }}
)

SELECT
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    g.geolocation_lat,
    g.geolocation_lng
FROM customers c
LEFT JOIN geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;