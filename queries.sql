SELECT * FROM fact_sales
SELECT  MIN(tenure_days) FROM dim_customers
SELECT * FROM dim_products_devices
SELECT * FROM fact_finance
UPDATE dim_customers
SET customer_segment=CASE WHEN tenure_days < 100 THEN 'New'
						   WHEN tenure_days >= 100 AND tenure_days <=150 THEN 'Returning'
						   WHEN tenure_days > 150 THEN 'Loyal'
						   ELSE 'unk' END;

ALTER TABLE dim_customers
RENAME TO dim_customers

UPDATE fact_finance
SET expected_payment_days =
	CASE WHEN device_price > 30000 THEN 365 ELSE 545 END ;
-- 1.a What is the conversion rate from application → approval → activation
SELECT COUNT(*) AS total_application,
				SUM(approved_flag) AS total_approved,
				SUM(loan_activated) AS total_activations,
			    ROUND( SUM(approved_flag)::numeric/COUNT(*),2) * 100 AS approval_rate,
				ROUND(SUM(loan_activated)::numeric/NULLIF(SUM(approved_flag),0)*100,2) AS acctivation_rate,
				ROUND(SUM(loan_activated)::numeric/COUNT(*) * 100,2) AS overall_conversation_rate
				FROM fact_finance
				

--  b. Conversion by Brand
SELECT device_brand, 
	   COUNT(*) AS total_applications,
	   SUM(approved_flag) AS total_approved,
	   SUM(loan_activated) AS total_activated,
	   ROUND(SUM(approved_flag) ::numeric/COUNT (*) * 100,2) AS approved_rate,
	   ROUND(SUM(loan_activated) ::numeric/NULLIF(SUM(approved_flag),0) * 100,2) AS activation_rate,
	   ROUND(SUM(loan_activated)/COUNT(*) * 100,2) AS overal_conversion
	   FROM fact_finance
	   GROUP BY device_brand

SELECT 
    c.customer_segment,
    COUNT(*) AS applications,
    ROUND(SUM(f.approved_flag)::numeric / COUNT(*) * 100, 2) AS approval_rate,
    ROUND(SUM(f.loan_activated)::numeric / COUNT(*) * 100, 2) AS conversion_rate
FROM fact_finance f
JOIN dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_segment;



SELECT 
    device_tier,
    COUNT(*) AS applications,
    ROUND(SUM(approved_flag)::numeric / COUNT(*) * 100, 2) AS approval_rate,
    ROUND(SUM(loan_activated)::numeric / COUNT(*) * 100, 2) AS conversion_rate
FROM fact_finance
GROUP BY device_tier
ORDER BY device_tier;
