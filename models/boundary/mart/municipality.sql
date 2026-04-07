{{ config(materialized='table') }}

WITH dissolved AS (
    SELECT
        lg_code,
        prefecture_code,
        prefecture_name,
        county_name,
        city_name,
        ward_name,
        ST_Union_Agg(geometry) AS geometry
    FROM {{ ref('stg_administrative_boundary') }}
    GROUP BY lg_code, prefecture_code, prefecture_name, county_name, city_name, ward_name
),
dumped AS (
    SELECT lg_code, prefecture_code, prefecture_name, county_name, city_name, ward_name,
           UNNEST(ST_Dump(geometry)).geom AS geom
    FROM dissolved
),
-- 面積5万m²未満の小島を除去
filtered AS (
    SELECT * FROM dumped
    WHERE ST_Area(geom) > 0.000005
),
recollected AS (
    SELECT lg_code, prefecture_code, prefecture_name, county_name, city_name, ward_name,
           ST_Union_Agg(geom) AS geometry
    FROM filtered
    GROUP BY lg_code, prefecture_code, prefecture_name, county_name, city_name, ward_name
),
ordered AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY lg_code) AS rn
    FROM recollected
),
-- 全市区町村を一括で coverage simplify（隣接境界の一貫性を保持）
simplified AS (
    SELECT ST_CoverageSimplify(
        ARRAY_AGG(geometry ORDER BY lg_code), 0.002
    ) AS gc
    FROM recollected
),
parts AS (
    SELECT (UNNEST(ST_Dump(gc))).path[1] AS rn,
           (UNNEST(ST_Dump(gc))).geom AS geom
    FROM simplified
),
reagg AS (
    SELECT rn, ST_Union_Agg(geom) AS geometry
    FROM parts
    GROUP BY rn
)
SELECT o.lg_code, o.prefecture_code, o.prefecture_name,
       o.county_name, o.city_name, o.ward_name,
       r.geometry
FROM ordered o
JOIN reagg r ON o.rn = r.rn
