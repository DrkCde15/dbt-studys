select
    date_trunc('month', created_at::timestamp)::date as month,
    count(*) as n_users
from {{ ref('stg_users') }}
group by 1
order by 1
