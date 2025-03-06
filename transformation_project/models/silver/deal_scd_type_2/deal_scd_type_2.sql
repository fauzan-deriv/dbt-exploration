-- gpt help me :D
{{
  config(
    materialized='incremental',
    unique_key='Deal',
    cluster_by='Deal',
    sort='Time',
    incremental_strategy='merge',
    merge_update_columns=['login', 'Action', 'dbt_valid_to']
  )
}}

WITH source AS (
    SELECT
        deal,
        login,
        Action,
        Time
    FROM
        {{ ref('deal_v2') }}
),

-- Conditionally define the existing CTE (only for incremental runs)
{% if is_incremental() %}
existing AS (
    SELECT
        deal,
        login,
        Action,
        Time,
        dbt_valid_from,
        dbt_valid_to
    FROM
        {{ this }}
),
{% endif %}

-- Identify new and changed records
updates AS (
    {% if is_incremental() %}
        SELECT
            s.deal,
            s.login,
            s.Action,
            s.Time
        FROM source s
        LEFT JOIN existing e ON s.deal = e.deal
        WHERE e.deal IS NULL   -- New Records
            OR (s.login != e.login OR s.Action != e.Action) -- Records that have changed
    {% else %}
        -- For the first run, just select all records from the source
        SELECT
            s.deal,
            s.login,
            s.Action,
            s.Time
        FROM source s
    {% endif %}
),

-- Get the previous records that require dbt_valid_to updates
{% if is_incremental() %}
updates_with_previous_records as (
  SELECT
    updates.*,
    existing.dbt_valid_to,
    existing.login as prev_login,
    existing.Action as prev_action
  FROM updates
  LEFT JOIN existing ON updates.deal = existing.deal
  WHERE updates.login != existing.login OR updates.Action != existing.Action
),
{% endif %}

-- Final select to construct the SCD Type 2
final AS (
    -- Insert New Record
    SELECT
        deal,
        login,
        Action,
        Time,
        CURRENT_TIMESTAMP() AS dbt_valid_from,
        CAST(NULL AS TIMESTAMP) AS dbt_valid_to,
        TRUE AS is_current
    FROM
        updates

  {% if is_incremental() %}
    UNION ALL

    -- Updating Previous Record
    SELECT
        deal,
        prev_login,
        prev_action,
        Time,
        dbt_valid_to,
        CURRENT_TIMESTAMP() AS dbt_valid_to,
        TRUE AS is_current
    FROM
        updates_with_previous_records
  {% endif %}
)

SELECT * FROM final
-- LIMIT 2000