{{ config(materialized='table') }}

SELECT * FROM ST_Read('data/railway/N02-24_Station.shp')
