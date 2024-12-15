-- SELECT
--     policy_id,
--     customer_id,
--     policy_type,
--     premium_amount,
--     effective_date,
--     CURRENT_TIMESTAMP() as dbt_loaded_at

SELECT
    {% for column in get_policy_columns() %}
    {{ column }}{% if not loop.last %},{% endif %}
    {% endfor %},
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('raw_data', 'raw_policy_details') }}