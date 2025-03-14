with 

source as (

    select * from {{ source('staging', 'fhv_tripdata') }}

),

tripdata as (
    select
        dispatching_base_num,
        pickup_datetime,
        dropoff_datetime,
        {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pulocationid,
        {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dolocationid,
        sr_flag,
        affiliated_base_number
    from 
        source
    WHERE 
        dispatching_base_num is not null
)

select * from tripdata

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}