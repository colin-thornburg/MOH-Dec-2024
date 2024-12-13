SELECT
    {% for column in get_policy_columns() %}
    p.{{ column }}{% if not loop.last %},{% endif %}
    {% endfor %},
    c.name as customer_name,
    c.state,
    c.dob,
    p.dbt_loaded_at,
    MD5(CONCAT(
        COALESCE(c.name, ''),
        COALESCE(c.state, ''),
        COALESCE(p.policy_type, ''),
        CAST(p.premium_amount AS VARCHAR),
        CAST(p.effective_date AS VARCHAR)
        {% if 'new_column' in get_policy_columns() %}
        ,COALESCE(p.new_column, '')
        {% endif %}
    )) as record_checksum
FROM {{ ref('stg_policy_details') }} p
JOIN {{ ref('stg_customer_info') }} c
    ON p.customer_id = c.customer_id