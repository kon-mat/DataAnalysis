
-- -----[   Metrics for Revenue Analysis   ]-----


-- Total Revenue
-- Calculation: Sum of purchase_revenue_in_usd from the ecommerce record.
SELECT 
  sum(ecommerce.purchase_revenue_in_usd) as total_revenue
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  event_name = 'purchase';


-- Revenue by Product Category
-- Calculation: Sum of purchase revenue grouped by item_category.
SELECT 
  case
    when i.item_category is null or i.item_category = '(not set)' or i.item_category = ''
      then 'Category not set'
    else i.item_category
  end as item_category
  , sum(ecommerce.purchase_revenue_in_usd) as revenue_by_category
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(items) as i
WHERE 
  event_name = 'purchase'
GROUP BY 
  item_category;


-- Average Order Value (AOV)
-- Calculation: Total revenue divided by the number of orders.
SELECT 
  sum(ecommerce.purchase_revenue_in_usd) / count(distinct ecommerce.transaction_id) as average_order_value
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  event_name = 'purchase';


-- Revenue Trend Over Time
-- Calculation: Total revenue aggregated by date.
SELECT 
  parse_date('%Y%m%d', event_date) as event_date
  , sum(ecommerce.purchase_revenue_in_usd) as daily_revenue
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  event_name = 'purchase'
GROUP BY 
  event_date
ORDER BY
  event_date;


-- Revenue by Traffic Source
-- Calculation: Total revenue attributed to different traffic sources.
SELECT 
  traffic_source.name as source
  , sum(ecommerce.purchase_revenue_in_usd) as revenue_by_source
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  event_name = 'purchase'
GROUP BY
  source;


-- Revenue by Device Category
-- Calculation: Total revenue attributed to different device categories.
SELECT 
  device.category as device_category
  , sum(ecommerce.purchase_revenue_in_usd) as revenue_by_device
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  event_name = 'purchase'
GROUP BY 
  device_category;


-- Top Selling Products by Revenue
-- Calculation: Products ranked by purchase revenue.
SELECT 
  i.item_name
  , sum(ecommerce.purchase_revenue_in_usd) as revenue_by_item
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(items) as i
WHERE 
  event_name = 'purchase'
GROUP BY 
  i.item_name
ORDER BY 
  revenue_by_item desc
LIMIT 
  10;



-- -----[   Metrics for Conversion Rate Analysis   ]-----


-- Sessions Count
-- Calculation: Count of distinct sessions.
SELECT
  count(distinct ep.value.int_value) as sessions_count
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id';


-- Total Conversions
-- Calculation: Count of distinct conversion events.
SELECT 
  count(distinct ecommerce.transaction_id) as total_conversions
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE 
  event_name = 'purchase';


-- Conversion Rate
-- Calculation: Number of purchases divided by the number of sessions.
SELECT
  countif(event_name = 'purchase') / count(distinct ep.value.int_value) as conversion_rate
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id';


-- Conversion Rate by Traffic Source
-- Calculation: Conversion rate grouped by traffic source.
SELECT
  traffic_source.name as source
  , countif(event_name = 'purchase') / count(distinct ep.value.int_value) as conversion_rate
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id'
GROUP BY 
  source;


-- Conversion Funnel Analysis
-- Calculation: Percentage of users who complete each stage of the conversion funnel.
WITH conversion_funnel as (
  SELECT
    count(distinct case when event_name = 'session_start' then ep.value.int_value end) as sessions_count
    , count(distinct case when event_name = 'view_item' then ep.value.int_value end) as product_views_count
    , count(distinct case when event_name = 'add_to_cart' then ep.value.int_value end) as add_to_cart_count
    , count(distinct case when event_name = 'begin_checkout' then ep.value.int_value end) as begin_checkout_count
    , count(distinct case when event_name = 'purchase' then ep.value.int_value end) as purchases_count
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
)
SELECT
  sessions_count
  , product_views_count
  , add_to_cart_count
  , begin_checkout_count
  , purchases_count
  , (product_views_count / sessions_count) * 100 AS product_views_rate
  , (add_to_cart_count / product_views_count) * 100 AS add_to_cart_rate
  , (begin_checkout_count / product_views_count) * 100 AS begin_checkout_rate
  , (purchases_count / add_to_cart_count) * 100 AS purchase_rate
FROM 
  conversion_funnel;


-- Average Session Duration
-- Calculation: Average duration of sessions.
WITH event_duration as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string)) as user_id_event_timestamp
    , max(if(ep.key = 'ga_session_id', ep.value.int_value, null)) as ga_session_id
    , sum(if(ep.key = 'engagement_time_msec', ep.value.int_value, null)) as engagement_time_msec
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id' 
    or ep.key = 'engagement_time_msec'
  GROUP BY
    user_id_event_timestamp
)
, session_duration as (
  SELECT
    ga_session_id
    , sum(engagement_time_msec) / 1000 as session_duration_seconds
  FROM
    event_duration
  GROUP BY
    ga_session_id
)
SELECT
  round(avg(session_duration_seconds)) as avg_session_duration_seconds
FROM
  session_duration;


-- Pages Per Session
-- Calculation: Average number of pages viewed per session.
WITH session_page_viewed as (
  SELECT
    ep.value.int_value as ga_session_id
    , count(event_name) as page_viewed
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id' 
    and event_name = 'page_view'
  GROUP BY
    ga_session_id
)
SELECT
  round(avg(page_viewed)) as avg_pages_per_session
FROM
  session_page_viewed;


-- Bounce Rate
-- Calculation: Percentage of single-page sessions.
WITH sessions_with_hits as (
  SELECT
    ep.value.int_value as ga_session_id
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id'
    and event_name = 'page_view'
  GROUP BY
    ga_session_id
  HAVING
    count(*) = 1
)
, sessions_count as (
  SELECT
    count(distinct ep.value.int_value) as sessions_count
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id'
)
SELECT
  count(distinct swh.ga_session_id) / max(sc.sessions_count) * 100 as bounce_rate
FROM
  sessions_with_hits as swh
  CROSS JOIN sessions_count as sc;


-- Top Viewed Pages
-- Calculation: Most frequently visited landing pages.
SELECT
  ep.value.string_value as page_title
  , count(*) as page_visits
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'page_title'
  and event_name = 'page_view'
GROUP BY
  page_title
ORDER BY
  page_visits desc
LIMIT 
  10;


-- User Retention Rate
-- Calculation: Percentage of users who return to the platform over time.
WITH user_activity as (
  SELECT
    user_pseudo_id
    , min(parse_date('%Y%m%d', event_date)) as first_activity_date
    , max(parse_date('%Y%m%d', event_date)) as last_activity_date
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY
    user_pseudo_id
)
SELECT
  countif(date_diff(last_activity_date, first_activity_date, day) >= 7)
  / count(distinct user_pseudo_id) * 100 as user_retention_rate
FROM
  user_activity;



-- -----[   Metrics for Traffic Sources Analysis   ]-----


-- Total Sessions by Source/Medium
-- Calculation: Count of sessions grouped by traffic source and medium.
SELECT
  traffic_source.name as source
  , traffic_source.medium as medium
  , count(distinct ep.value.int_value) as sessions_count
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id'
GROUP BY
  source
  , medium;


-- New vs. Returning Visitors
-- Calculation: Count of new and returning visitors.
WITH user_visit_count as (
  SELECT
    user_pseudo_id
    , count(distinct ep.value.int_value) as visit_count
    , case
      when count(distinct ep.value.int_value) = 1 then 'New Visitor'
      else 'Returning Visitor'
    end as visitor_type
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id'
    and event_name = 'first_visit'
  GROUP BY
    user_pseudo_id
)
SELECT
  uvc.visitor_type
  , count(*) as visitor_count
FROM
  user_visit_count as uvc
GROUP BY
  uvc.visitor_type;


-- Traffic Source Trends Over Time
-- Calculation: Count of sessions over time grouped by traffic source.
SELECT
  traffic_source.name as source
  , parse_date('%Y%m%d', event_date) as date
  , count(distinct ep.value.int_value) as sessions_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  event_name = 'session_start'
  and ep.key = 'ga_session_id'
GROUP BY
  source
  , date
ORDER BY
  date;



-- -----[   Metrics for Product Performance Analysis   ]-----


-- Total Sales by Product
-- Calculation: Count of distinct transactions per product.
SELECT
  items.item_id as product_id
  , items.item_name as product_name
  , count(distinct ecommerce.transaction_id) as total_sales
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(items) as items
WHERE
  event_name = 'purchase'
GROUP BY
  product_id
  , product_name;



-- -----[   Metrics for Customer Retention Analysis   ]-----


-- User Retention Rate Over Time
-- Calculation: Percentage of users who return to the platform over time.
WITH user_activity as (
  SELECT
    user_pseudo_id
    , min(parse_date('%Y%m%d', event_date)) as first_activity_date
    , max(parse_date('%Y%m%d', event_date)) as last_activity_date
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY
    user_pseudo_id
)
SELECT
  last_activity_date as date
  , countif(date_diff(last_activity_date, first_activity_date, day) >= 7)
  / count(distinct user_pseudo_id) * 100 as user_retention_rate
FROM
  user_activity
GROUP BY
  date
ORDER BY
  date;


-- Churn Rate
-- Calculation: Percentage of users who haven't engaged with the platform for a defined period (current_date() as 2021-01-31)
WITH last_activity as (
  SELECT
    user_pseudo_id
    , max(parse_date('%Y%m%d', event_date)) as last_activity_date
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY
    user_pseudo_id
)
SELECT
  countif(date_diff(parse_date('%Y%m%d', '20210131'), last_activity_date, day) >= 30)
  / count(distinct user_pseudo_id) * 100 as churn_rate
FROM
  last_activity;


-- Repeat Purchase Rate
-- Calculation: Percentage of users who have made more than one purchase.
WITH purchase_counts as (
  SELECT
    user_pseudo_id
    , count(distinct ecommerce.transaction_id) as purchase_count
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    event_name = 'purchase'
  GROUP BY
    user_pseudo_id
)
SELECT
  countif(purchase_count > 1)
  / count(distinct user_pseudo_id) * 100 as repeat_purchase_rate
FROM
  purchase_counts;



-- -----[   Metrics for Geographical Analysis   ]-----


-- Total Sessions by Geo
-- Calculation: Count of sessions grouped by geo.
SELECT
  geo.continent
  , geo.sub_continent
  , geo.country
  , geo.region
  , geo.city
  , count(distinct ep.value.int_value) as sessions_count
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id'
GROUP BY
  geo.continent
  , geo.sub_continent
  , geo.country
  , geo.region
  , geo.city;


-- Total Revenue by Geo
-- Calculation: Sum of revenue generated by users from each geo.
SELECT
  geo.continent
  , geo.sub_continent
  , geo.country
  , geo.region
  , geo.city
  , sum(ecommerce.purchase_revenue_in_usd) as total_revenue
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  event_name = 'purchase'
GROUP BY
  geo.continent
  , geo.sub_continent
  , geo.country
  , geo.region
  , geo.city;


-- Session Duration by Geo
-- Calculation: Duration of sessions by geo.
WITH event_duration as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string)) as user_id_event_timestamp
    , geo.continent
    , geo.sub_continent
    , geo.country
    , geo.region
    , geo.city
    , max(if(ep.key = 'ga_session_id', ep.value.int_value, null)) as ga_session_id
    , sum(if(ep.key = 'engagement_time_msec', ep.value.int_value, null)) as engagement_time_msec
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id' 
    or ep.key = 'engagement_time_msec'
  GROUP BY
    user_id_event_timestamp
    , geo.continent
    , geo.sub_continent
    , geo.country
    , geo.region
    , geo.city
)
, session_duration as (
  SELECT
    ga_session_id
    , continent
    , sub_continent
    , country
    , region
    , city
    , sum(engagement_time_msec) / 1000 as session_duration_seconds
  FROM
    event_duration
  GROUP BY
    ga_session_id
    , continent
    , sub_continent
    , country
    , region
    , city
)
SELECT
  ga_session_id
  , continent
  , sub_continent
  , country
  , region
  , city
  , session_duration_seconds
FROM
  session_duration;


-- New vs. Returning Visitors by Geo
-- Calculation: Count of new and returning visitors grouped by geo.
WITH user_visit_count as (
  SELECT
    user_pseudo_id
    , geo.continent
    , geo.sub_continent
    , geo.country
    , geo.region
    , geo.city
    , count(distinct ep.value.int_value) as visit_count
    , case
      when count(distinct ep.value.int_value) = 1 then 'New Visitor'
      else 'Returning Visitor'
    end as visitor_type
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id'
    and event_name = 'first_visit'
  GROUP BY
    user_pseudo_id
    , geo.continent
    , geo.sub_continent
    , geo.country
    , geo.region
    , geo.city
)
SELECT
  uvc.visitor_type
  , uvc.continent
  , uvc.sub_continent
  , uvc.country
  , uvc.region
  , uvc.city
  , count(*) as visitor_count
FROM
  user_visit_count as uvc
GROUP BY
  uvc.visitor_type
  , uvc.continent
  , uvc.sub_continent
  , uvc.country
  , uvc.region
  , uvc.city;


-- Conversion Rate by Country
-- Calculation: Percentage of sessions that resulted in a conversion, grouped by country.
SELECT
  geo.continent
  , geo.sub_continent
  , geo.country
  , geo.region
  , geo.city
  , countif(event_name = 'purchase') as purchase_count
  , count(distinct ep.value.int_value) as session_count
  , countif(event_name = 'purchase') / count(distinct ep.value.int_value) as conversion_rate
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id'
GROUP BY
  geo.continent
  , geo.sub_continent
  , geo.country
  , geo.region
  , geo.city;



-- -----[   Metrics for Device and Platform Analysis   ]-----


-- Total Sessions by Device Category
-- Calculation: Count of sessions grouped by device category.
SELECT
  device.category as device_category
  , count(distinct ep.value.int_value) as sessions_count
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id'
GROUP BY
  device_category;


-- Session Duration by Device Category
-- Calculation: Duration of sessions by device category.
WITH event_duration as (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string)) as user_id_event_timestamp
    , device.category as device_category
    , max(if(ep.key = 'ga_session_id', ep.value.int_value, null)) as ga_session_id
    , sum(if(ep.key = 'engagement_time_msec', ep.value.int_value, null)) as engagement_time_msec
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id' 
    or ep.key = 'engagement_time_msec'
  GROUP BY
    user_id_event_timestamp
    , device_category
)
, session_duration as (
  SELECT
    ga_session_id
    , device_category
    , sum(engagement_time_msec) / 1000 as session_duration_seconds
  FROM
    event_duration
  GROUP BY
    ga_session_id
    , device_category
)
SELECT
  device_category
  , avg(session_duration_seconds) as avg_session_duration_seconds
FROM
  session_duration
GROUP BY
  device_category;


-- New vs. Returning Visitors by Device Category
-- Calculation: Count of new and returning visitors grouped by device category.
WITH user_visit_count as (
  SELECT
    user_pseudo_id
    , device.category as device_category
    , count(distinct ep.value.int_value) as visit_count
    , case
      when count(distinct ep.value.int_value) = 1 then 'New Visitor'
      else 'Returning Visitor'
    end as visitor_type
  FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    , unnest(event_params) as ep
  WHERE
    ep.key = 'ga_session_id'
    and event_name = 'first_visit'
  GROUP BY
    user_pseudo_id
    , device_category
)
SELECT
  uvc.visitor_type
  , uvc.device_category
  , count(*) as visitor_count
FROM
  user_visit_count as uvc
GROUP BY
  uvc.visitor_type
  , uvc.device_category;


-- Conversion Rate by Device Category
-- Calculation: Percentage of sessions that resulted in a conversion, grouped by device category.
SELECT
  device.category as device_category
  , countif(event_name = 'purchase') as purchase_count
  , count(distinct ep.value.int_value) as session_count
  , countif(event_name = 'purchase') / count(distinct ep.value.int_value) as conversion_rate
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id'
GROUP BY
  device_category;
