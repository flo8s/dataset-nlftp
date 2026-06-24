{{ config(materialized='table') }}

SELECT * FROM ST_Read('data/school/P29-21.geojson')
