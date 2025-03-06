{% set mt5_servers = ['estuary_mt5demo_p01_ts02', 'streamkap_mt5demo', 'streamkap'] %}  -- Add all your database names here
SELECT * FROM (
(SELECT
    CAST(Deal AS INT64) AS Deal,
    Action,
    Login,
    'estuary_mt5demo_p01_ts02' as srvid
FROM
    `data-tribe-sandbox-438709.estuary_mt5demo_p01_ts02.mt5_deals_2024`
LIMIT 10)

{% for mt5_server in mt5_servers[1:] %}  -- Start from the second database (since we already hardcoded the first one) %}
UNION ALL

(SELECT
    Deal,
    Action,
    Login,
    '{{ mt5_server }}' as srvid
FROM
    `data-tribe-sandbox-438709.{{ mt5_server }}.mt5_deals_2024`
LIMIT 10)
{% endfor %}
)
-- above is how we do it using jinja template to do dynamically