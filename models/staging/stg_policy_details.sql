-- SELECT
--     policy_id,
--     customer_id,
--     policy_type,
--     premium_amount,
--     effective_date,
--     CURRENT_TIMESTAMP() as dbt_loaded_at
-- FROM {{ ref('raw_policy_details') }}

SELECT
    {% for column in get_policy_columns() %}
    {{ column }}{% if not loop.last %},{% endif %}
    {% endfor %},
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ ref('raw_policy_details') }}