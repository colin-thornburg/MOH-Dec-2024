-- models/marts/dim_policy_customer_history.sql
{{
    config(
        materialized='incremental',
        unique_key=['policy_id', 'valid_from']
    )
}}

WITH all_versions AS (
    {% if is_incremental() %}
    -- Include existing records
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
    
    -- Add new records
    SELECT 
        policy_id,
        customer_id,
        customer_name,
        state,
        dob,
        policy_type,
        premium_amount,
        effective_date,
        dbt_loaded_at as valid_from,
        record_checksum
    FROM {{ ref('int_policy_customer') }}
    {% if is_incremental() %}
    WHERE dbt_loaded_at > (SELECT MAX(valid_from) FROM {{ this }})
    {% endif %}
)

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
    LEAD(valid_from) OVER(PARTITION BY policy_id ORDER BY valid_from) as valid_to,
    record_checksum,
    CASE 
        WHEN LEAD(valid_from) OVER(PARTITION BY policy_id ORDER BY valid_from) IS NULL 
        THEN TRUE 
        ELSE FALSE 
    END as is_current
FROM all_versions