SELECT
    customer_id,
    name,
    state,
    dob
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('raw_data', 'raw_customer_info') }}