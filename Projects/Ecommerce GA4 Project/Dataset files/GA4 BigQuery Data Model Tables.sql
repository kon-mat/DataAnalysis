CREATE VIEW `local-ecommerce-401412`.ga4_sample_data.tbl_event_id_generated as
SELECT
  row_number() over () as event_id_generated_short
  , concat(ga.user_pseudo_id, cast(ga.event_timestamp as string), ga.event_bundle_sequence_id, ga.event_name) as event_id_generated_long
FROM 
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as ga
;


CREATE VIEW `local-ecommerce-401412`.ga4_sample_data.vw_event as
SELECT 
	eid.event_id_generated_short 
	, parse_date('%Y%m%d', eev.event_date) as event_date
	, eev.event_name
	, eev.page_title
	, eev.ga_session_id
	, eev.engagement_time_msec
	, eev.event_medium
	, eev.category
	, eev.country
	, eev.user_pseudo_id
FROM 
	`local-ecommerce-401412`.ga4_sample_data.tbl_ga4_obfuscated_sample_ecommerce_events as eev
	LEFT JOIN `local-ecommerce-401412`.ga4_sample_data.tbl_event_id_generated as eid
		on eev.primary_key = eid.event_id_generated_long 
;


CREATE VIEW `local-ecommerce-401412`.ga4_sample_data.vw_session as
(
	WITH unique_page_titles as (
		SELECT
			eev.ga_session_id
			, count(distinct eev.page_title) as unique_page_titles_count
	  	FROM
	    	`local-ecommerce-401412`.ga4_sample_data.tbl_ga4_obfuscated_sample_ecommerce_events as eev
		GROUP BY
			eev.ga_session_id
	)
	, session_landing_pages as (
		SELECT
			distinct eev.ga_session_id
			, first_value(eev.page_title) over (
				partition by eev.ga_session_id order by eev.event_timestamp
			) as session_landing_page
	  	FROM
	    	`local-ecommerce-401412`.ga4_sample_data.tbl_ga4_obfuscated_sample_ecommerce_events as eev
		GROUP BY
			eev.ga_session_id
			, eev.page_title
			, eev.event_timestamp
	)
	, session_by_user as (
		SELECT
			eev.ga_session_id
			, eev.user_pseudo_id
			, min(parse_date('%Y%m%d', eev.event_date)) as session_date
		FROM
			`local-ecommerce-401412`.ga4_sample_data.tbl_ga4_obfuscated_sample_ecommerce_events as eev
		GROUP BY
			ga_session_id
    		, eev.user_pseudo_id
	)
	, previous_session as (
		SELECT
			eev.ga_session_id
		    , eev.user_pseudo_id
    		, eev.session_date
    		, lag(eev.ga_session_id) over (partition by eev.user_pseudo_id order by eev.session_date) as prev_session_id
		FROM
			session_by_user as eev
	) 
	, visitor_type as (
		SELECT
			eev.ga_session_id
    		, case
    			when eev.prev_session_id is not null then "Returning Visitor"
    			else "New Visitor"
    		end as visitor_type
		FROM
			previous_session as eev
	)	
	
	SELECT 
		eev.ga_session_id
		, min(parse_date('%Y%m%d', eev.event_date)) as session_date
		, eev.user_pseudo_id
		, sum(eev.engagement_time_msec) as session_duration_msec
		, timestamp_millis(sum(eev.engagement_time_msec)) as session_duration
		, case
			when upt.unique_page_titles_count > 1 then false
			else true
		end as single_page_session
		, eev.continent
		, eev.sub_continent
		, eev.country
		, eev.region
		, eev.city
		, slp.session_landing_page
		, vt.visitor_type
	FROM 
		`local-ecommerce-401412`.ga4_sample_data.tbl_ga4_obfuscated_sample_ecommerce_events as eev
		LEFT JOIN `local-ecommerce-401412`.ga4_sample_data.tbl_event_id_generated as eid
			on eev.primary_key = eid.event_id_generated_long 
		LEFT JOIN unique_page_titles as upt
			on eev.ga_session_id = upt.ga_session_id
		LEFT JOIN session_landing_pages as slp
			on eev.ga_session_id = slp.ga_session_id
		LEFT JOIN visitor_type as vt
			on eev.ga_session_id = vt.ga_session_id
	GROUP BY 
		eev.ga_session_id
	    , eev.user_pseudo_id
	    , eev.continent
	    , eev.sub_continent
	    , eev.country
	    , eev.region
	    , eev.city
	    , upt.unique_page_titles_count
		, slp.session_landing_page	
		, vt.visitor_type
)
;


CREATE VIEW `local-ecommerce-401412`.ga4_sample_data.vw_event_item as
SELECT
	eid.event_id_generated_short 
	, eit.item_id
	, eit.item_name 
	, eit.item_brand 
	, eit.item_variant 
	, eit.item_category 
	, eit.price_in_usd 
	, eit.price 
	, eit.quantity 
	, eit.item_revenue_in_usd 
	, eit.item_revenue_in_usd / eit.quantity as single_item_revenue_in_usd
	, eit.promotion_id 
FROM 
	`local-ecommerce-401412`.ga4_sample_data.view_ga4_obfuscated_sample_ecommerce_items as eit
	LEFT JOIN `local-ecommerce-401412`.ga4_sample_data.tbl_event_id_generated as eid
		on eit.primary_key = eid.event_id_generated_long 


CREATE VIEW `local-ecommerce-401412`.ga4_sample_data.vw_user as
(
	WITH user_purchase as (
		SELECT 
			e.user_pseudo_id 
			, count(distinct e.ga_session_id) as purchase_count
		FROM 
			`local-ecommerce-401412`.ga4_sample_data.vw_event as e 
		WHERE
			e.event_name = "purchase"
		GROUP BY 
			e.user_pseudo_id 
			, e.event_name
	)
	SELECT 
		e.user_pseudo_id 
		, min(e.event_date) as first_activity_date
		, max(e.event_date) as last_activity_date
		, date_diff(
			max(e.event_date)
			, min(e.event_date)
			, day
		) as user_retention_days
		, sum(eit.price_in_usd) as customer_lifetime_value
		, up.purchase_count
	FROM 
		`local-ecommerce-401412`.ga4_sample_data.vw_event as e
		LEFT JOIN `local-ecommerce-401412`.ga4_sample_data.vw_event_item as eit
			on e.event_id_generated_short = eit.event_id_generated_short 
		LEFT JOIN user_purchase as up
			on e.user_pseudo_id = up.user_pseudo_id 
	GROUP BY 
		e.user_pseudo_id
		, up.purchase_count
)	
;	