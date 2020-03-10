USE db_consumer_panel;

# Create table to cluster household into groups: Low: under $5k - $19.9k, Medium: $20k - $49.9, High: above $50k
DROP TABLE IF EXISTS income_group;
CREATE  TABLE income_group
SELECT hh_id, IF(hh_income IN (3, 4, 6, 8, 10, 11), 'low', IF(hh_income IN (13, 15, 16, 17,18,19), 'Medium', 'High')) AS income_group FROM households;
SELECT income_group, COUNT(hh_id) AS 'the number of households in this group' FROM income_group
GROUP BY income_group;

# Create temporary table to get the expenditure on private label products in each trip
DROP TABLE IF EXISTS private_record;
CREATE TEMPORARY TABLE private_record
SELECT TC_id, SUM(total_price_paid_at_TC_prod_id) AS spend_on_private_per_trip FROM purchases
		WHERE prod_id = ANY(SELECT prod_id FROM products WHERE brand_at_prod_id =  'CTL BR')
        GROUP BY TC_id;

#      To get the average monthly expenditure of each income group
SELECT income_group.income_group, AVG(T.avg_monthly) AS avg_of_group FROM income_group
	INNER JOIN 
		(SELECT hh_id, AVG(sum_monthly) AS avg_monthly FROM 
			(SELECT A.hh_id, A.month, SUM(B.total_per_trip)AS sum_monthly FROM 
				(SELECT hh_id, date_format(TC_date, '%Y/%m') as month, TC_id FROM trips) A 
			INNER JOIN
				(SELECT TC_id, SUM(total_price_paid_at_TC_prod_id) AS total_per_trip FROM purchases
				GROUP BY TC_id) B
			ON A.TC_id = B.TC_id
			GROUP BY A.hh_id, A.month) C
		GROUP BY hh_id) T
	ON income_group.hh_id = T.hh_id
	GROUP BY income_group.income_group;

#       To compute the % share of private label products in the average monthly expenditure of each income group
SELECT income_group, CONCAT(ROUND(avg_group_expense_on_private/avg_of_group, 4)*100, '%') AS share_of_private_foe_each_group FROM
	(SELECT A.income_group, A.avg_of_group, B.avg_group_expense_on_private FROM 
		(SELECT income_group.income_group, AVG(T.avg_monthly) AS avg_of_group FROM income_group
		INNER JOIN 
			(SELECT hh_id, AVG(sum_monthly) AS avg_monthly FROM 
				(SELECT A.hh_id, A.month, SUM(B.total_per_trip)AS sum_monthly FROM 
					(SELECT hh_id, date_format(TC_date, '%Y/%m') as month, TC_id FROM trips) A 
				INNER JOIN
					(SELECT TC_id, SUM(total_price_paid_at_TC_prod_id) AS total_per_trip FROM purchases
					GROUP BY TC_id) B
				ON A.TC_id = B.TC_id
				GROUP BY A.hh_id, A.month) C
			GROUP BY hh_id) T
		ON income_group.hh_id = T.hh_id
		GROUP BY income_group.income_group) A
	INNER JOIN 
		(SELECT A.income_group, AVG(B.hh_expense_on_private) AS avg_group_expense_on_private FROM income_group A
		INNER JOIN 
		(SELECT hh_id, month, SUM(spend_on_private_per_trip) AS hh_expense_on_private FROM
			(SELECT  A.hh_id, date_format(A.TC_date, '%Y/%m') as month, B.spend_on_private_per_trip FROM trips A
			INNER JOIN private_record B
			ON A.TC_id = B.TC_id) M
			GROUP BY hh_id, month) B
		ON A.hh_id = B.hh_id
		GROUP BY income_group) B
	ON A.income_group = B.income_group) K;








