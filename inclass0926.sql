USE db_countries;


DROP TABLE IF EXISTS intl;
CREATE TEMPORARY TABLE intl
		SELECT *, str_to_date(date, '%Y-%m-%d') AS date_correct
        FROM intl_football;

# 		Q1: prob distribution of games by day of the week by country
        
describe intl;
DROP table if exists homegames, awaygames;
CREATE TEMPORARY TABLE homegames
		SELECT COUNT(*) AS count, DAYNAME(date_correct) AS weekday, home_team AS team
        FROM intl
        GROUP BY team, weekday;

CREATE TEMPORARY TABLE awaygames
		SELECT COUNT(*) AS count, DAYNAME(date_correct) AS weekday, away_team AS team
        FROM intl
        GROUP BY team, weekday;

DROP TABLE IF EXISTS  totalgames;
CREATE temporary TABLE totalgames
SELECT SUM(a.count) AS total_eachday, a.weekday, a.team FROM
        (SELECT * FROM homegames
        UNION ALL
        SELECT * FROM awaygames) a
GROUP BY team, weekday;

SELECT * FROM TOTALGAMES; 

DROP TABLE IF EXISTS  sums;
CREATE temporary TABLE sums
SELECT SUM(total_eachday) AS total, team FROM totalgames
GROUP BY team;

DROP TABLE IF EXISTS FINAL;
CREATE temporary TABLE FINAL
SELECT a.total_eachday, a.weekday, a.team, b.total FROM totalgames a
INNER JOIN
sums b
ON a.team = b.team;

SELECT concat(
TRUNCATE (total_eachday/total * 100, 2),              
'%'
) AS 'prob_distribution', weekday, team FROM FINAL;
      



        