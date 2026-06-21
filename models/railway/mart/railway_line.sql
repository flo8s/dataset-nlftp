{{ config(materialized='table') }}

-- 路線区間を路線（事業者・路線名・区分）単位に集約したマルチラインジオメトリ
SELECT
    railway_class_code,
    railway_class,
    operator_type_code,
    operator_type,
    line_name,
    operator,
    ST_Union_Agg(geometry) AS geometry
FROM {{ ref('stg_railway_section') }}
GROUP BY
    railway_class_code,
    railway_class,
    operator_type_code,
    operator_type,
    line_name,
    operator
