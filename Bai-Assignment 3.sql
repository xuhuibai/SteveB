
### To TA and Xavi,
### Because the issue of losing data(in the most updated file posted on 15 Sept.) is still unresolved on my Mac after trying all possible ways to fix, 
### all the results below are based on the dataset having 184 available rows (not 227). 
### Therefore, some of the results may differ from your answers. Sorry for the inconvenience. 


USE db_countries;

#1. What countries have a total GDP per capita above the mean?  61 rows returned
SELECT Country FROM countries_of_the_world 
WHERE GDP > (SELECT avg(GDP) FROM countries_of_the_world);

#2. How many countries are above the mean on each region in Area, GDP and another variable decided by yourself?

#in area   8 rows returned
SELECT region, count(a.country) AS No_of_area_over_mean FROM (
		SELECT country, area, region FROM countries_of_the_world WHERE area > (SELECT avg(Area) FROM countries_of_the_world)
        ) a GROUP BY region;

#in GDP  9 rows returned
SELECT region, count(a.country) AS No_of_GDP_over_mean FROM (
		SELECT country, region, GDP FROM countries_of_the_world WHERE GDP > (SELECT avg(GDP) FROM countries_of_the_world)
        ) a GROUP BY region;
        
#in Birthrate  7 rows returned
SELECT region, count(a.country) AS No_of_birthrate_over_mean FROM (
		SELECT country, birthrate, region FROM countries_of_the_world WHERE birthrate > (SELECT avg(Birthrate) FROM countries_of_the_world)
        ) a GROUP BY region;


#3. How many regions have more than 65% of their countries with a GDP per capita above 6000?

# 5

DROP TABLE IF exists new_tbl1, new_tbl2, new_tbl3;
CREATE TEMPORARY TABLE new_tbl1 
		SELECT count(country) AS OVER6000, region FROM countries_of_the_world WHERE GDP  > 6000 GROUP BY region;
CREATE TEMPORARY TABLE new_tbl2
		SELECT count(Country) AS country_number, Region from countries_of_the_world group by region;
CREATE TEMPORARY TABLE new_tbl3
		SELECT new_tbl1.OVER6000, new_tbl1.region, new_tbl2.country_number FROM new_tbl1 INNER JOIN new_tbl2 ON new_tbl1.region = new_tbl2.region;
SELECT count(Region) from new_tbl3 where over6000/country_number > 0.65;
    
#4. List all the countries with a GDP that is less than 40% of the mean GDP per capita across all the countries.
# 73 rows returned
SELECT Country FROM countries_of_the_world 
WHERE GDP < 0.4* (SELECT AVG(GDP) FROM countries_of_the_world);

#5. List all the countries with a GDP per capita that is between 40% and 60% the mean GDP per capita across all the countries.
#21 rows returned
SELECT Country FROM countries_of_the_world 
WHERE GDP > 0.4* (SELECT AVG(GDP) FROM countries_of_the_world) AND GDP < 0.6* (SELECT AVG(GDP) FROM countries_of_the_world);

#6. Which letter is the most popular first letter among all the countries? (i.e. what is the letter that starts the largest number of countries?)
# S 
SELECT A.First_Letter, count(*) FROM (
	SELECT Country, REGEXP_SUBSTR( Country, '[A-Z]') AS 'First_Letter' 
    FROM countries_of_the_world) AS A 
    GROUP BY A.First_Letter
    ORDER BY count(*) DESC
    LIMIT 1;
    
    
#7. What are the countries with a coast to area ratio in the top 50?
#50 rows returned
DROP TABLE IF EXISTS tbl1, tbl2, tbl3, tbl4, tbl5;
CREATE temporary table tbl1
SELECT country, coastline, area, coastline/area as coast_to_area_ratio FROM countries_of_the_world
        ORDER BY coast_to_area_ratio DESC
        LIMIT 50;
SELECT * FROM tbl1;

#a. From these countries, how many of them belong to the bottom 30 countries by GDP per capita?
# 2
CREATE temporary table tbl2
SELECT country, GDP from countries_of_the_world
ORDER BY GDP
LIMIT 30;
CREATE temporary TABLE tbl3
SELECT tbl1.country, tbl2.GDP from tbl1 inner join tbl2 on tbl1.country=tbl2.country;
SELECT COUNT(*) FROM tbl3;

#b. From these countries, how many of them belong to the top 30 countries by GDP per capita?
# 9
CREATE temporary table tbl4
SELECT country, GDP from countries_of_the_world
ORDER BY GDP DESC
LIMIT 30;
CREATE temporary TABLE tbl5
SELECT tbl1.country, tbl4.GDP from tbl1 inner join tbl4 on tbl1.country=tbl4.country;
SELECT COUNT(*) FROM tbl5;

#8. Is the average Agriculture, Industry, Service distribution of the top 20 richest countries different than the one of the lowest 20?
#Yes they are different between rich and poor countries.
DROP TABLE IF EXISTS tb1, tb2;
CREATE temporary table tb1
SELECT country, Agriculture, Industry, Service, GDP from countries_of_the_world
ORDER BY GDP DESC
LIMIT 20;
SELECT AVG(Agriculture) AS Rich_Agri, AVG(Industry) AS Rich_Industry, AVG(service) AS Rich_Service from tb1; 

CREATE temporary table tb2
SELECT country, Agriculture, Industry, Service, GDP from countries_of_the_world
ORDER BY GDP 
LIMIT 20;

SELECT AVG(tb1.Agriculture) AS Rich_Agri, AVG(tb1.Industry) AS Rich_Industry, AVG( tb1.service) AS Rich_Service, 
AVG(tb2.Agriculture) AS Poor_Agri, AVG(tb2.Industry) AS Poor_Industry, AVG(tb2.service) AS Poor_Service from tb1, tb2;


#9, How much higher is the average literacy level in the 20% percentile of the richest countries relative to the poorest 20% countries? 
# 37.5496
DROP TABLE IF EXISTS A1, A2;
CREATE TEMPORARY TABLE A1
			SELECT AVG(a.Literacy) AS rich_Literacy FROM (
            SELECT Literacy, PERCENT_RANK() OVER (ORDER BY GDP) percentile_rank FROM countries_of_the_world
            ) a 
            WHERE percentile_rank > 0.8;
CREATE TEMPORARY TABLE A2
            SELECT AVG(b.Literacy) AS poor_Literacy FROM (
            SELECT Literacy, PERCENT_RANK() OVER (ORDER BY GDP) percentile_rank FROM countries_of_the_world
            ) b
            WHERE percentile_rank < 0.2;
SELECT A1.rich_Literacy-A2.poor_Literacy AS Literacy_Gap FROM A1, A2;


#10. From all the countries with a coast ratio at least 50% lower than the mean, which % of them stay in Africa?
# 30.2469

DROP TABLE IF EXISTS table1, table2, table3;

CREATE TEMPORARY TABLE table1
			SELECT  COUNT(country) AS Total FROM(
            SELECT country, coastline/area as coast_to_area_ratio FROM countries_of_the_world) a 
            WHERE coast_to_area_ratio <= (
            SELECT 0.5*avg(coastline/area) FROM countries_of_the_world
            );

CREATE TEMPORARY TABLE table2
			SELECT COUNT(country) AS AF_num FROM(
            SELECT country, coastline/area as coast_to_area_ratio, region FROM countries_of_the_world) a 
            WHERE coast_to_area_ratio <= (
            SELECT 0.5*avg(coastline/area) FROM countries_of_the_world
            ) AND region REGEXP 'AFRICA' ;

SELECT AF_num * 100 / Total AS '% of stay in Africa' FROM table1, table2;
        
#a. How many of them start with the letter C?
# For all countries with a coast ratio at least 50% lower than the mean, 15 start with the letter C
# For all countries in AFRICA with a coast ratio at least 50% lower than the mean, 8 start with the letter C
SELECT  COUNT(country) AS Initial_C FROM(
            SELECT country, coastline/area as coast_to_area_ratio FROM countries_of_the_world) a 
            WHERE coast_to_area_ratio <= (
            SELECT 0.5*avg(coastline/area) FROM countries_of_the_world
            ) AND country REGEXP '^C';

SELECT COUNT(country) AS Initial_C_AF FROM(
            SELECT country, coastline/area AS coast_to_area_ratio, region FROM countries_of_the_world) a 
            WHERE coast_to_area_ratio <= (
            SELECT 0.5*avg(coastline/area) FROM countries_of_the_world
            ) AND country REGEXP '^C' AND region REGEXP 'Africa';
            
		