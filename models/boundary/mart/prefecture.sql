{{ config(materialized='table') }}

SELECT
    prefecture_code,
    prefecture_name,
    ST_Union_Agg(geometry) AS geometry
FROM {{ ref('municipality') }}
GROUP BY prefecture_code, prefecture_name
