select
    u.id as user_id,
    u.name,
    u.country,
    count(o.order_id) as n_orders,
    coalesce(sum(o.amount), 0) as ltv
from {{ ref('stg_users') }} u
left join {{ ref('stg_orders') }} o on u.id = o.user_id
group by 1, 2, 3
order by ltv desc
