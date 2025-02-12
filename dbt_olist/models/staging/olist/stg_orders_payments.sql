{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('order_payments') }}