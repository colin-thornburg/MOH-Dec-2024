SELECT
    claim_id,
    status,
    updated_date,
    adjuster_id,
    CURRENT_TIMESTAMP() as dbt_loaded_at
from {{ source('raw_data', 'raw_claim_status') }}