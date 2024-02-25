
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


-- Conversion Rate
-- Calculation: Number of purchases divided by the number of sessions.
SELECT
  countif(event_name = 'purchase') / count(distinct ep.value.int_value) as conversion_rate
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  , unnest(event_params) as ep
WHERE
  ep.key = 'ga_session_id';


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
LIMIT 10;



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
WITH conversion_funnel AS (
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



-- -----[   Metrics for Customer Behavior Analysis   ]-----


-- Average Session Duration
-- Calculation: Average duration of sessions.
WITH event_duration AS (
  SELECT
    concat(user_pseudo_id, cast(event_timestamp as string)) user_id_event_timestamp
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
),
session_duration AS (
  SELECT
    ga_session_id
    , sum(engagement_time_msec) / 1000 session_duration_seconds
  FROM
    event_duration
  GROUP BY
    ga_session_id
)
SELECT
  round(avg(session_duration_seconds)) avg_session_duration_seconds
FROM
  session_duration


-- Pages Per Session
-- Calculation: Average number of pages viewed per session.
WITH session_page_viewed AS (
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
  session_page_viewed



