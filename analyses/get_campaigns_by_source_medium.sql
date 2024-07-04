{% if not flags.FULL_REFRESH %}
    {% set partitions_to_query = ['current_date'] %}
    {% for i in range(var('static_incremental_days', 1)) %}
        {% set partitions_to_query = partitions_to_query.append('date_sub(current_date, interval ' + (i+1)|string + ' day)') %}
    {% endfor %}
{% endif %}

select
    source
    , medium
    , campaign
    count(*)
from {{ref('dim_ga4__sessions_daily')}}
where session_partition_date >= 2024-06-01
and campaign not in ('(other)', '(organic)', '(none)')
{% if not flags.FULL_REFRESH %}
    and session_partition_date in ({{ partitions_to_query | join(',') }})
{% endif %}