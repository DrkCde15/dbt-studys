select
    country,
    count(*) as n_users
from {{ ref('stg_users') }}
group by 1
order by n_users desc
