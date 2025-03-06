SELECT
    Deal,
    Action,
    Login,
    Time,
    'estuary_mt5demo_p01_ts02' as srvid
FROM
    {{ source('estuary_mt5demo_p01_ts02', 'mt5_deals_2024') }}