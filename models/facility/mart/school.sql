{{ config(materialized='table') }}

-- 学校の代表点（ポイント）
SELECT
    admin_code,
    school_code,
    school_class_code,
    school_class,
    school_name,
    address,
    administrator_code,
    administrator,
    school_status_code,
    school_status,
    geometry
FROM {{ ref('stg_school') }}
