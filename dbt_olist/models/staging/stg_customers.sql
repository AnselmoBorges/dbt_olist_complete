{{ config(materialized='table') }}

SELECT
    *
FROM {{ ref('customers') }}