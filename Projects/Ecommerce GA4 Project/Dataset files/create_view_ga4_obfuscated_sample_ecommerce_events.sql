
CREATE TEMP TABLE tbl_page_location as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string), event_bundle_sequence_id, event_name) as primary_key
    , ep.value.string_value as page_location
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'page_location'
);

CREATE TEMP TABLE tbl_page_title as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string), event_bundle_sequence_id, event_name) as primary_key
    , ep.value.string_value as page_title
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'page_title'
);

CREATE TEMP TABLE tbl_ga_session_id as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string), event_bundle_sequence_id, event_name) as primary_key
    , ep.value.int_value as ga_session_id
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id'
);

CREATE TEMP TABLE tbl_engagement_time_msec as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string), event_bundle_sequence_id, event_name) as primary_key
    , ep.value.int_value as engagement_time_msec
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'engagement_time_msec'
);

CREATE TEMP TABLE tbl_event_source as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string), event_bundle_sequence_id, event_name) as primary_key
    , ep.value.string_value as event_source
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'source'
);

CREATE TEMP TABLE tbl_event_medium as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string), event_bundle_sequence_id, event_name) as primary_key
    , ep.value.string_value as event_medium
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'medium'
);


SELECT
  concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) as primary_key
  , ga.event_date
  , ga.event_timestamp
  , ga.event_name
  , pl.page_location
  , pt.page_title
  , gsi.ga_session_id
  , etm.engagement_time_msec
  , es.event_source
  , em.event_medium
  , ga.event_bundle_sequence_id
  , ga.user_pseudo_id
  , ga.privacy_info.uses_transient_token
  , ga.user_first_touch_timestamp	
  , ga.user_ltv.revenue	
  , ga.user_ltv.currency	
  , ga.device.category	
  , ga.device.mobile_brand_name	
  , ga.device.mobile_model_name	
  , ga.device.mobile_marketing_name
  , ga.device.operating_system	
  , ga.device.operating_system_version
  , ga.device.language	
  , ga.device.is_limited_ad_tracking
  , ga.device.web_info.browser	
  , ga.device.web_info.browser_version	
  , ga.geo.continent	
  , ga.geo.sub_continent	
  , ga.geo.country	
  , ga.geo.region	
  , ga.geo.city	
  , ga.geo.metro
  , ga.traffic_source.medium	
  , ga.traffic_source.name	
  , ga.traffic_source.source	
  , ga.stream_id	platform
  , ga.ecommerce.total_item_quantity	
  , ga.ecommerce.purchase_revenue_in_usd
  , ga.ecommerce.unique_items	
  , ga.ecommerce.transaction_id
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as ga
  LEFT JOIN tbl_page_location as pl 
    on concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) = pl.primary_key
  LEFT JOIN tbl_page_title as pt 
    on concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) = pt.primary_key
  LEFT JOIN tbl_ga_session_id as gsi 
    on concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) = gsi.primary_key
  LEFT JOIN tbl_engagement_time_msec as etm 
    on concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) = etm.primary_key
  LEFT JOIN tbl_event_source as es 
    on concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) = es.primary_key
  LEFT JOIN tbl_event_medium as em 
    on concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) = em.primary_key

