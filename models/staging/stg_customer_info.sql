SELECT
    customer_id,
    name,
    state,
    dob,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ ref('raw_customer_info') }}