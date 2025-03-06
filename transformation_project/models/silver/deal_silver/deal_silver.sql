{{ config(
    materialized="incremental",
    unique_key="Deal",
    cluster_by = "Deal",
    incremental_strategy="merge",
    partition_by={
      "field": "Time",
      "data_type": "timestamp",
      "granularity": "day"
    },
)}}


SELECT
    *
FROM
    {{ ref('deal_v2') }}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  -- (If event_time is NULL or the table is truncated, the condition will always be true and load all records)
where (Time) >= (select COALESCE(max(Time), CAST((CURRENT_DATE - 365) AS TIMESTAMP)) from {{ this }} )

{% endif %}

LIMIT 200
