{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('payments') }}