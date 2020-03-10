CREATE database db_hc_assignment_3;

USE db_hc_assignment_3;
alter table inpatient16 add primary key (uniq);

delete from inpatient16 where mdc = ' ';

drop table if exists tab1;
CREATE TABLE tab1
SELECT 
	UNIQ,
    MDC, 
    INTAGE, 
    SEX, 
    CHRGS, 
    IF(PPAY = 1, 'MEDICARE', IF(PPAY = 2, 'MEDICAID', 'Commercial Payers')) AS insurance 
FROM inpatient16 WHERE PPAY IN (1,2,6,7);

with aa as (
select b. MDC_CAT_NAME, a.insurance, ROUND(SUM(a.chrgs)/1000000, 0) AS total_charge_$Million FROM tab1 AS a
LEFT JOIN mdc_desc AS b
ON a.MDC = b.MDC
WHERE insurance = 'MEDICARE'
GROUP BY a.MDC, insurance
ORDER BY a.MDC, insurance), 
bb as (
select b. MDC_CAT_NAME, a.insurance, ROUND(SUM(a.chrgs)/1000000, 0) AS total_charge_$Million FROM tab1 AS a
LEFT JOIN mdc_desc AS b
ON a.MDC = b.MDC
WHERE insurance = 'MEDICAID'
GROUP BY a.MDC, insurance
ORDER BY a.MDC, insurance), 
cc as (
select b. MDC_CAT_NAME, a.insurance, ROUND(SUM(a.chrgs)/1000000, 0) AS total_charge_$Million FROM tab1 AS a
LEFT JOIN mdc_desc AS b
ON a.MDC = b.MDC
WHERE insurance = 'Commercial Payers'
GROUP BY a.MDC, insurance
ORDER BY a.MDC, insurance)
SELECT aa.MDC_CAT_NAME AS MDC_category, aa.total_charge_$Million AS 'Medicare ($million)', bb.total_charge_$Million AS 'Medicaid ($million)', cc.total_charge_$Million AS 'Commercial Payers ($million)'
FROM aa 
LEFT JOIN bb on aa.MDC_CAT_NAME = bb.MDC_CAT_NAME
LEFT JOIN cc on aa.MDC_CAT_NAME = cc.MDC_CAT_NAME;


# age analysis
with dd as(
SELECT b.AGE_GRP_DESC, COUNT(a.INTAGE) as total_per_age, a.insurance FROM tab1 as a
LEFT JOIN age as b
ON a.INTAGE = b.INTAGE
WHERE insurance = 'MEDICARE'
GROUP BY a.intage),
ee as(
SELECT b.AGE_GRP_DESC, COUNT(a.INTAGE) as total_per_age, a.insurance FROM tab1 as a
LEFT JOIN age as b
ON a.INTAGE = b.INTAGE
WHERE insurance = 'MEDICAID'
GROUP BY a.intage),
ff as (
SELECT b.AGE_GRP_DESC, COUNT(a.INTAGE) as total_per_age, a.insurance FROM tab1 as a
LEFT JOIN age as b
ON a.INTAGE = b.INTAGE
WHERE insurance = 'Commercial Payers'
GROUP BY a.intage)
SELECT dd.AGE_GRP_DESC, dd. total_per_age as Medicare, ee.total_per_age as Medicaid, ff.total_per_age as 'Commercial Payers'
FROM dd
LEFT JOIN ee ON dd.AGE_GRP_DESC = ee.AGE_GRP_DESC
LEFT JOIN ff ON dd.AGE_GRP_DESC = ff.AGE_GRP_DESC
ORDER BY AGE_GRP_DESC;

# gender analysis
with gg as(
select sex, COUNT(sex) as total_per_sex, insurance FROM tab1
WHERE insurance = 'MEDICARE'
GROUP BY sex),
hh as (
select sex, COUNT(sex) as total_per_sex, insurance FROM tab1
WHERE insurance = 'MEDICAID'
GROUP BY sex),
jj as (
select sex, COUNT(sex) as total_per_sex, insurance FROM tab1
WHERE insurance = 'Commercial Payers'
GROUP BY sex)
SELECT if(gg.sex = 1, 'male', if(gg.sex = 2, 'female', 'unknown') )as gender, gg.total_per_sex AS Medicare, hh.total_per_sex AS Medicaid, jj.total_per_sex AS 'Commercial Payers'
FROM gg
LEFT JOIN hh ON gg.sex = hh.sex
LEFT JOIN jj ON gg.sex = jj.sex;




