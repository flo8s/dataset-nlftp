{{ config(materialized='table') }}

-- 医療機関の代表点（ポイント）
SELECT
    medical_class_code,
    medical_class,
    institution_name,
    address,
    departments,
    establisher_type_code,
    establisher_type,
    bed_count,
    emergency_hospital,
    disaster_base_hospital,
    geometry
FROM {{ ref('stg_medical_institution') }}
