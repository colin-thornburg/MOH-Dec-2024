SELECT
    {% for column in get_policy_columns() %}
    {{ column }}{% if not loop.last %},{% endif %}
    {% endfor %},
    CURRENT_TIMESTAMP() as dbt_loaded_at
FROM {{ source('raw_data', 'raw_policy_details') }}