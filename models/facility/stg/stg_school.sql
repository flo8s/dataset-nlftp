SELECT
    P29_001 AS admin_code,
    P29_002 AS school_code,
    P29_003 AS school_class_code,
    {{ school_class_name('P29_003') }} AS school_class,
    P29_004 AS school_name,
    P29_005 AS address,
    P29_006 AS administrator_code,
    {{ administrator_name('P29_006') }} AS administrator,
    P29_007 AS school_status_code,
    {{ school_status_name('P29_007') }} AS school_status,
    ST_MakeValid(geom) AS geometry
FROM {{ ref('raw_school') }}
WHERE geom IS NOT NULL
