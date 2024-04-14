{% set partitions_to_replace = ['current_date'] %}
{% for i in range(var('static_incremental_days')) %}
    {% set partitions_to_replace = partitions_to_replace.append('date_sub(current_date, interval ' + (i+1)|string + ' day)') %}
{% endfor %}
{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'insert_overwrite',
        tags = ["incremental"],
        partition_by={
            "field": "event_date_dt",
            "data_type": "date",
            "granularity": "day"
        },
        partitions = partitions_to_replace
    )
}}

select 
    event_date_dt 
    , event_timestamp 
    , event_name 
    , event_value_in_usd 
    , user_id 
    , client_key 
    , session_key 
    , session_partition_key 
    , event_key 
    , privacy_info_analytics_storage
    , privacy_info_ads_storage
    , privacy_info_uses_transient_token 
    , device_category 
    , device_web_info_browser 
    , geo_country 
    , geo_region 
    , geo_city 
    , stream_id 
    , page_title 
    , page_location 
    , page_referrer 
    , original_page_location 
    , original_page_referrer
    , form_destination 
    , form_length
from {{ ref('stg_ga4__event_form_start') }}
{% if is_incremental() %}
    where event_date_dt in ({{ partitions_to_replace | join(',') }})
{% endif %}