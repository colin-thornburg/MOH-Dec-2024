SELECT
    policy_id,
    customer_id,
    policy_type,
    premium_amount,
    effective_date,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ ref('raw_policy_details') }}