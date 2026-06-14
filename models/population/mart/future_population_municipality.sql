{{ config(materialized='table') }}

-- 市区町村別の将来推計人口。地価データ等との結合・散布図用。
-- メッシュの SHICODE が複数市区町村にまたがる場合（"_" 連結）は、
-- そのメッシュの人口を該当市区町村へ均等按分して集計する。
-- 政令指定都市は区単位のコード（例: 札幌市中央区 = 01101）で集計される。
WITH split AS (
    SELECT
        UNNEST(STRING_SPLIT(city_code, '_')) AS city_code,
        LEN(STRING_SPLIT(city_code, '_')) AS n_parts,
        population_2020,
        population_2025,
        population_2030,
        population_2035,
        population_2040,
        population_2045,
        population_2050,
        population_2055,
        population_2060,
        population_2065,
        population_2070,
        elderly_2025,
        elderly_2050
    FROM {{ ref('stg_future_population_mesh') }}
),

aggregated AS (
    SELECT
        city_code,
        SUM(population_2020 / n_parts) AS population_2020,
        SUM(population_2025 / n_parts) AS population_2025,
        SUM(population_2030 / n_parts) AS population_2030,
        SUM(population_2035 / n_parts) AS population_2035,
        SUM(population_2040 / n_parts) AS population_2040,
        SUM(population_2045 / n_parts) AS population_2045,
        SUM(population_2050 / n_parts) AS population_2050,
        SUM(population_2055 / n_parts) AS population_2055,
        SUM(population_2060 / n_parts) AS population_2060,
        SUM(population_2065 / n_parts) AS population_2065,
        SUM(population_2070 / n_parts) AS population_2070,
        SUM(elderly_2025 / n_parts) AS elderly_2025,
        SUM(elderly_2050 / n_parts) AS elderly_2050
    FROM split
    GROUP BY city_code
),

names AS (
    SELECT DISTINCT
        lg_code,
        prefecture_name,
        county_name,
        city_name,
        ward_name
    FROM {{ ref('stg_administrative_boundary') }}
)

SELECT
    a.city_code,
    LEFT(a.city_code, 2) AS prefecture_code,
    n.prefecture_name,
    n.county_name,
    n.city_name,
    n.ward_name,
    ROUND(a.population_2020) AS population_2020,
    ROUND(a.population_2025) AS population_2025,
    ROUND(a.population_2030) AS population_2030,
    ROUND(a.population_2035) AS population_2035,
    ROUND(a.population_2040) AS population_2040,
    ROUND(a.population_2045) AS population_2045,
    ROUND(a.population_2050) AS population_2050,
    ROUND(a.population_2055) AS population_2055,
    ROUND(a.population_2060) AS population_2060,
    ROUND(a.population_2065) AS population_2065,
    ROUND(a.population_2070) AS population_2070,
    ROUND(100.0 * (a.population_2035 - a.population_2025) / NULLIF(a.population_2025, 0), 1)
        AS growth_rate_2025_2035,
    ROUND(100.0 * (a.population_2050 - a.population_2025) / NULLIF(a.population_2025, 0), 1)
        AS growth_rate_2025_2050,
    ROUND(100.0 * a.elderly_2025 / NULLIF(a.population_2025, 0), 1) AS elderly_ratio_2025,
    ROUND(100.0 * a.elderly_2050 / NULLIF(a.population_2050, 0), 1) AS elderly_ratio_2050
FROM aggregated AS a
LEFT JOIN names AS n ON a.city_code = n.lg_code
