{{ config(materialized='table') }}

SELECT * FROM ST_Read('data/medical/P04-20.geojson')
