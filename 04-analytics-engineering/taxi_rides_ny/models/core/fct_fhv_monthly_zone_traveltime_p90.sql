{{
    config(
        materialized= 'table'
    )
}}

WITH trip_duration_calculated AS (
    SELECT
        *,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration
    FROM
        {{ ref('dim_fhv_trips') }}
),

percentiles AS (
    SELECT
        *,
        PERCENTILE_CONT(trip_duration, 0.90) OVER (PARTITION BY year, month, pulocationid, dolocationid) AS p90
    FROM
        trip_duration_calculated
)

SELECT * FROM percentiles
