{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('sellers') }}