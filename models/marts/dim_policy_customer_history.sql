-- This model implements a Type 2 Slowly Changing Dimension for policy customer data
-- It tracks historical changes by maintaining multiple versions of each policy record
-- with valid_from and valid_to dates to show when each version was active

{{
    config(
        materialized='incremental',  
        unique_key=['policy_id', 'valid_from'], 
        on_schema_change='append_new_columns'    
    )
}}

-- all_versions CTE combines existing history with new changes
-- This is necessary for SCD Type 2 because we need to:
-- 1. Keep all historical records
-- 2. Add new records
-- 3. Update valid_to dates when records are superseded
WITH all_versions AS (
    {% if is_incremental() %}
    -- On incremental runs, we first select all existing historical records
    -- These records already have their valid_from dates set
    SELECT 
        policy_id,
        customer_id,
        customer_name,
        state,
        dob,
        policy_type,
        premium_amount,
        effective_date,
        valid_from,
        record_checksum
    FROM {{ this }}

    UNION ALL
    {% endif %}
    
    -- Select new or changed records from our source
    -- For these records, we use dbt_loaded_at as valid_from
    -- The incremental filter ensures we only process new records
    SELECT 
        policy_id,
        customer_id,
        customer_name,
        state,
        dob,
        policy_type,
        premium_amount,
        effective_date,
        dbt_loaded_at as valid_from,  -- When this version became active
        record_checksum               -- Used to detect changes
    FROM {{ ref('int_policy_customer') }}
    {% if is_incremental() %}
    WHERE dbt_loaded_at > (SELECT MAX(valid_from) FROM {{ this }})
    {% endif %}
)

-- Final SELECT sets up the SCD Type 2 time slices
-- For each policy, we look at all its versions in chronological order
SELECT 
    policy_id,
    customer_id,
    customer_name,
    state,
    dob,
    policy_type,
    premium_amount,
    effective_date,
    valid_from,
    -- valid_to is set to the valid_from date of the next record for this policy
    -- NULL valid_to indicates this is the current version
    LEAD(valid_from) OVER(PARTITION BY policy_id ORDER BY valid_from) as valid_to,
    record_checksum,
    -- is_current flag is TRUE for the latest version of each policy
    -- (the one with no valid_to date)
    CASE 
        WHEN LEAD(valid_from) OVER(PARTITION BY policy_id ORDER BY valid_from) IS NULL 
        THEN TRUE 
        ELSE FALSE 
    END as is_current
FROM all_versions