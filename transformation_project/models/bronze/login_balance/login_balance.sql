select distinct login, balance
from {{ source('streamkap_mt5demo', 'mt5_accounts') }}
limit 10