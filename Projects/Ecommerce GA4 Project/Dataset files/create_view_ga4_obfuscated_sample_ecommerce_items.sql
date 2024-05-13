
SELECT
  concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) as primary_key
  , i.item_id
  , i.item_name
  , i.item_brand
  , i.item_variant
  , i.item_category
  , i.item_category2
  , i.item_category3
  , i.item_category4
  , i.item_category5
  , i.price_in_usd
  , i.price
  , i.quantity
  , i.item_revenue_in_usd
  , i.item_revenue
  , i.item_refund_in_usd
  , i.item_refund
  , i.coupon
  , i.affiliation
  , i.location_id
  , i.item_list_id
  , i.item_list_name
  , i.item_list_index
  , i.promotion_id
  , i.promotion_name
  , i.creative_name
  , i.creative_slot
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as ga
  , unnest(items) as i
