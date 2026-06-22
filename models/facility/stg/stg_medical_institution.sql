SELECT
    P04_001 AS medical_class_code,
    {{ medical_class_name('P04_001') }} AS medical_class,
    P04_002 AS institution_name,
    P04_003 AS address,
    -- 診療科目は全角127文字超で P04_005・P04_006 に分割されるため連結して復元する
    NULLIF(
        COALESCE(P04_004, '') || COALESCE(P04_005, '') || COALESCE(P04_006, ''),
        ''
    ) AS departments,
    P04_007 AS establisher_type_code,
    {{ establisher_type_name('P04_007') }} AS establisher_type,
    P04_008 AS bed_count,
    {{ emergency_hospital_name('P04_009') }} AS emergency_hospital,
    {{ disaster_base_hospital_name('P04_010') }} AS disaster_base_hospital,
    ST_MakeValid(geom) AS geometry
FROM {{ ref('raw_medical_institution') }}
WHERE geom IS NOT NULL
