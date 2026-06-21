SELECT
    N02_001 AS railway_class_code,
    {{ railway_class_name('N02_001') }} AS railway_class,
    N02_002 AS operator_type_code,
    {{ operator_type_name('N02_002') }} AS operator_type,
    N02_003 AS line_name,
    N02_004 AS operator,
    N02_005 AS station_name,
    N02_005c AS station_code,
    N02_005g AS station_group_code,
    ST_MakeValid(geom) AS geometry
FROM {{ ref('raw_railway_station') }}
WHERE geom IS NOT NULL
