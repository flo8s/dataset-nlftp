{{ config(materialized='table') }}

-- 駅の軌道区間ラインの重心を駅の代表点（ポイント）とする
SELECT
    railway_class_code,
    railway_class,
    operator_type_code,
    operator_type,
    line_name,
    operator,
    station_name,
    station_code,
    station_group_code,
    ST_Centroid(geometry) AS geometry
FROM {{ ref('stg_railway_station') }}
