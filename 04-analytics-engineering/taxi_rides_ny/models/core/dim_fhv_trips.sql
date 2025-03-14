{{
    config(
        materialized= 'table'
    )
}}

WITH tripdata AS (
    SELECT
        'fhv' AS service_type,
        *
    FROM
        {{ ref('stg_fhv_tripdata') }}
),

dim_zones AS (
    SELECT
        * 
    from 
        {{ ref('dim_zones') }}
    where 
        borough != 'Unknown'
)
SELECT
    tripdata.dispatching_base_num, 
    tripdata.pickup_datetime, 
    tripdata.dropOff_datetime,
    EXTRACT(YEAR FROM tripdata.pickup_datetime) AS year,
    EXTRACT(MONTH FROM tripdata.pickup_datetime) AS month,
    tripdata.PUlocationID, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    tripdata.DOlocationID, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    tripdata.SR_Flag,
    tripdata.Affiliated_base_number
from 
    tripdata
INNER join 
    dim_zones as pickup_zone
        on tripdata.PUlocationID = pickup_zone.locationid
INNER join
     dim_zones as dropoff_zone
        on tripdata.DOlocationID = dropoff_zone.locationid
