{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('customers') }}