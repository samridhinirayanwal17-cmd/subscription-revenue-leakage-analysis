create table subscription_data( 
user_id varchar(100) ,
month varchar(50),
plan varchar(50),
base_price numeric,
discount_pct numeric,
revenue numeric,
payment_failed boolean 

);
drop table  if exists subscription_data ;

select * from subscription_data;
select count(*) from subscription_data;



 -- Query 1: Core insight — users flat, revenue declining
SELECT
	MONTH,
	SUM(REVENUE) AS TOTAL_REVENUE,
	COUNT(DISTINCT USER_ID) AS TOTAL_USERS
FROM
	SUBSCRIPTION_DATA
GROUP BY
	MONTH
ORDER BY
	MONTH;


-- Query 2: Plan-wise distribution shift over time
SELECT
	MONTH,
	PLAN,
	COUNT(DISTINCT USER_ID) AS TOTAL_USERS
FROM
	SUBSCRIPTION_DATA
GROUP BY
	PLAN,
	MONTH
ORDER BY
	PLAN,
	MONTH;


-- Query 3: Payment failure rate trend
SELECT
	MONTH,
	COUNT(*) AS TOTAL_TRSANSACTIONS,
	COUNT(
		CASE
			WHEN PAYMENT_FAILED = TRUE THEN 1
		END
	) AS FAILED_PAYMENT,
	ROUND(
		100.00 * COUNT(
			CASE
				WHEN PAYMENT_FAILED = TRUE THEN 1
			END
		) / COUNT(*),
		2
	) AS FAILED_RATE
FROM
	SUBSCRIPTION_DATA
GROUP BY
	MONTH
ORDER BY
	MONTH;

-- Query 4: Discount usage trend
SELECT
	MONTH,
	COUNT(
		CASE
			WHEN DISCOUNT_PCT > 0 THEN 1
		END
	) AS DISCOUNTED_USERS,
	ROUND(AVG(DISCOUNT_PCT), 2) AS AVG_DISCOUNT
FROM
	SUBSCRIPTION_DATA
GROUP BY
	MONTH
ORDER BY
	MONTH;

-- In the most recent month, which plan is contributing the most to revenue?"
SELECT
	PLAN,
	SUM(REVENUE) AS PLAN_REVENUE,
	ROUND(
		100.00 * SUM(REVENUE) / (
			SELECT
				SUM(REVENUE)
			FROM
				SUBSCRIPTION_DATA
			WHERE
				MONTH = '2026-01'
		),
		2
	) AS PCT_TOTAL
FROM
	SUBSCRIPTION_DATA
WHERE
	MONTH = '2026-01'
GROUP BY
	PLAN;

-- Query 6: THE WATERFALL QUERY — revenue bridge breakdown (January 2026)
SELECT
	SUM(BASE_PRICE) AS GROSS_POTENTIAL_REVENUE,
	SUM(
		CASE
			WHEN PAYMENT_FAILED THEN BASE_PRICE
			ELSE 0
		END
	) AS LOST_TO_FAILURES,
	SUM(
		CASE
			WHEN NOT PAYMENT_FAILED THEN BASE_PRICE * DISCOUNT_PCT / 100.0
			ELSE 0
		END
	) AS LOST_TO_DISCOUNTS,
	SUM(REVENUE) AS ACTUAL_REVENUE
FROM
	SUBSCRIPTION_DATA
WHERE
	MONTH = '2026-01';

	