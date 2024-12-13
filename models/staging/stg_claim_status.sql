SELECT
    claim_id,
    status,
    updated_date,
    adjuster_id,
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ ref('raw_claim_status') }}