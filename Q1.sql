CREATE DATABASE db_hc_assignment_2;
USE db_hc_assignment_2;

DELETE FROM monthly_report_by_plan_2019_10 WHERE Enrollment = '*';
DELETE FROM Enrollment WHERE Enrollment = '*';

drop table if exists Enrollment2;
CREATE TABLE Enrollment2 
SELECT * FROM Enrollment WHERE state IN ('TX', 'GA', 'AZ', 'WI', 'KY', 'UT', 'NE', 'RI', 'DC');

DELETE FROM Enrollment2 WHERE `Contract Number` LIKE 'S%';
DELETE FROM monthly_report_by_plan_2019_10 WHERE `Contract_Number` LIKE 'S%';

drop table if exists bigguy_enrollment_by_state;
CREATE temporary TABLE bigguy_enrollment_by_state
SELECT d.MajorInsuranceOrgName, c.state, SUM(c.total_enrollment) FROM 
	(SELECT Organization_Marketing_Name, state, SUM(Enrollment) AS total_enrollment FROM
		(SELECT a.Contract_Number, a.state, a.Enrollment, b.Organization_Marketing_Name FROM Enrollment2 a
		LEFT JOIN monthly_report_by_plan_2019_10 b
		ON a.Contract_Number = b.Contract_Number and a.`Plan ID` = b.`plan id` ) k
	GROUP BY Organization_Marketing_Name, state) c
LEFT JOIN majorinsuranceorgs d
ON c.Organization_Marketing_Name = d.Organization_Marketing_Name
GROUP BY state, MajorInsuranceOrgName;

SELECT state, MajorInsuranceOrgName, ROUND(`SUM(c.total_enrollment)`/total_enrollment_by_state, 4) AS market_share FROM
		(SELECT a.*, b.total_enrollment_by_state from bigguy_enrollment_by_state a
		left join (SELECT state, SUM(Enrollment) AS total_enrollment_by_state  FROM(
			SELECT a.Contract_Number, a.state, a.Enrollment, b.Organization_Marketing_Name FROM Enrollment2 a
			LEFT JOIN 
			monthly_report_by_plan_2019_10 b
			ON a.Contract_Number = b.Contract_Number and a.`Plan ID` = b.`plan id`) k
		GROUP BY state) b
		ON a.state = b.state)l
order by state, market_share DESC;

SELECT state, ROUND(SUM(sqr_share), 4) as HHI FROM 
(SELECT *, power(market_share, 2) AS sqr_share FROM
	(SELECT state, MajorInsuranceOrgName, ROUND(`SUM(c.total_enrollment)`/total_enrollment_by_state, 4) AS market_share FROM
		(SELECT a.*, b.total_enrollment_by_state from bigguy_enrollment_by_state a
		left join (SELECT state, SUM(Enrollment) AS total_enrollment_by_state  FROM(
			SELECT a.Contract_Number, a.state, a.Enrollment, b.Organization_Marketing_Name FROM Enrollment2 a
			LEFT JOIN 
			monthly_report_by_plan_2019_10 b
			ON a.Contract_Number = b.Contract_Number and a.`Plan ID` = b.`plan id`) k
		GROUP BY state) b
		ON a.state = b.state) L
	ORDER BY state, market_share DESC) l) f
group by state
ORDER BY HHI DESC;











