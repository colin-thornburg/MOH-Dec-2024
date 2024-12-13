SELECT
    p.policy_id,
    p.customer_id,
    c.name as customer_name,
    c.state,
    c.dob,
    p.policy_type,
    p.premium_amount,
    p.effective_date,
    p.dbt_loaded_at,
    -- Add checksum for change detection
    MD5(CONCAT(
        COALESCE(c.name, ''),
        COALESCE(c.state, ''),
        COALESCE(p.policy_type, ''),
        CAST(p.premium_amount AS VARCHAR),
        CAST(p.effective_date AS VARCHAR)
    )) as record_checksum
FROM {{ ref('stg_policy_details') }} p
JOIN {{ ref('stg_customer_info') }} c
    ON p.customer_id = c.customer_id