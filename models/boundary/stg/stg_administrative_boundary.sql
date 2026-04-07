SELECT
    N03_007 AS lg_code,
    LEFT(N03_007, 2) AS prefecture_code,
    N03_001 AS prefecture_name,
    N03_002 AS subprefecture_name,
    N03_003 AS county_name,
    N03_004 AS city_name,
    N03_005 AS ward_name,
    ST_MakeValid(geom) AS geometry
FROM {{ ref('raw_administrative_boundary') }}
WHERE geom IS NOT NULL
  AND N03_004 != '所属未定地'
