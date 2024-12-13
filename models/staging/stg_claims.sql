SELECT
    claim_id,
    policy_id,
    claim_amount,
    claim_date,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ ref('raw_claims') }}