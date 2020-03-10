USE db_hc_assignment_3;

SELECT * FROM inpatient16 WHERE UNIQ = 507033  ;

SELECT Uniq, REVCODE, REVUNITS as units, REVCHRGS as charge, REVCHRGS/REVUNITS as price, REVCODE_DESC FROM rev_record, rev_code
WHERE rev_record.REVCODE = rev_code.rev_code;