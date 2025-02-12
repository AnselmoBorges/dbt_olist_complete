{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('orders') }}