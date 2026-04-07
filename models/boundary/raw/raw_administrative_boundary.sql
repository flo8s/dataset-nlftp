{{ config(materialized='table') }}

SELECT * FROM ST_Read('data/administrative_boundary/N03-20250101.shp')
