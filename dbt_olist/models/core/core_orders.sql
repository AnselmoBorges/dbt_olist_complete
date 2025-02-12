{{ config(materialized='view') }}

WITH orders AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),
payments AS (
    SELECT order_id, payment_type, payment_value, payment_installments
    FROM {{ ref('stg_order_payments') }}
),
reviews AS (
    SELECT order_id, review_score
    FROM {{ ref('stg_order_reviews') }}
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    p.payment_type,
    p.payment_value,
    p.payment_installments,
    r.review_score
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id;