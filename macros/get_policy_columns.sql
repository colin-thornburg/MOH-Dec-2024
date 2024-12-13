{% macro get_policy_columns() %}
    {% set columns = [
        "policy_id",
        "customer_id",
        "policy_type",
        "premium_amount",
        "effective_date",
        "my_new_column"
    ] %}
    {{ return(columns) }}
{% endmacro %}