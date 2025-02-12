{{ config(materialized='view') }}

SELECT
    *
FROM {{ ref('geolocation') }}