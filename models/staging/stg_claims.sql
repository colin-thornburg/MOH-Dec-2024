SELECT
    claim_id,
    policy_id,
    claim_amount,
    claim_date,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('raw_data', 'raw_claims') }}