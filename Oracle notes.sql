

-- CONNECT BY ROWNUM  stuff

SELECT
    min(TRUNC (SYSDATE + ROWNUM) )
,    max(TRUNC (SYSDATE + ROWNUM) )
,   count(*)
FROM DUAL CONNECT BY ROWNUM < (365 * 101) 
UNION
SELECT
    min(TRUNC (SYSDATE - ROWNUM +1 ) )
,    max(TRUNC (SYSDATE - ROWNUM + 1) )
,   count(*)
FROM DUAL CONNECT BY ROWNUM <= (365 * 22) ;	

select level, rownum from dual connect by rownum < 5 ;

-- connect by rownum explanation:
-- https://stackoverflow.com/questions/18572701/confusion-with-oracle-connect-by


-- connect by rownum usage examples
-- https://cpaterson.wordpress.com/tag/connect-by-clause-with-rownum/

--To start off with, we try and get the months of the year generated using the SQL below :

SELECT mnth, last_day(mnth) – mnth + 1 num_days, rnum
FROM
  (SELECT to_date(rownum, 'MM') mnth, rownum rnum
   FROM dual
   CONNECT BY rownum < 13)
;
   
--   This gives you the output shown below:
--“MNTH”                        “NUM_DAYS”        “RNUM”                      
--“01-JAN-10”                   “31”                          “1”                         
--“01-FEB-10”                    “28”                          “2”                         
--
--Basically we are getting 12 rows selected by the inner query and then using the to_date and last_day functions to generate the first day of each month in the year and a count of the number of days per month. 
--Now to get the days of any month, say January, we can use this query

SELECT rownum dy FROM dual CONNECT BY rownum < 32;

--(You can also use CONNECT BY rownum <= 31 above of course)
--The above query gives me 31 rows as required. So now, we’ve got the queries for the months of the year and the days of a month.  We will now put it all together and generate days for all the months in the year.

WITH month_view as
    (SELECT mnth, last_day(mnth) – mnth + 1 num_days, rnum
    FROM
      (SELECT to_date(rownum, ‘MM’) mnth, rownum rnum
       FROM dual
       CONNECT BY rownum < 13)),
day_view as
    (SELECT rownum dy
    FROM dual
    CONNECT BY rownum < 32)
SELECT a1.mnth + a2.dy – 1 current_day, a1.mnth, a1.num_days from month_view a1, day_view a2
where a1.num_days >= a2.dy;

--This gives you the required result (a subset is shown below)
--“CURRENT_DAY”                 “MNTH”                        “NUM_DAYS”                  
--“01-JAN-10 ”                        “01-JAN-10”                     “31”                        
--“02-JAN-10 ”                        “01-JAN-10”                     “31”                        
--“03-JAN-10 ”                        “01-JAN-10”                     “31”         

--- If you want to generate a range of values based on sysdate then you use a hierarchical query against the dual table, rather than having to refer to a real table:

select trunc(sysdate - 1) + (level - 1)/1440 as result
from dual
connect by level <= (sysdate - trunc(sysdate - 1))*1440
order by result;

-- RESULT - list of all minutes - useful!
-----------------
-- 2017-12-18 00:00:00
-- 2017-12-18 00:01:00


--How do you obtain the maximum possible date in Oracle?
--https://stackoverflow.com/questions/687510/how-do-you-obtain-the-maximum-possible-date-in-oracle
 
SELECT  TO_DATE('31.12.9999 23:59:59', 'dd.mm.yyyy hh24:mi:ss')
FROM    dual ;

--Note that minimal date is much more simple:

SELECT  TO_DATE(1, 'J')
FROM    dual ;

-- TO_TIMESTAMP format


SELECT TO_TIMESTAMP ('10-Sep-02 14:10:10.123000', 'DD-Mon-RR HH24:MI:SS.FF')
   FROM DUAL;
   
   
-- Use of WHERE CASE - different DS job source filter-  depending on the PM_LOAD_MODE  parameter 

SELECT *
 FROM #PM_SRCTBL_SCHEMA#.#PM_SRCTBL#
WHERE 1 =
    CASE WHEN ( '#PM_LOAD_MODE#' = 'INCREMENTAL'  OR '#PM_LOAD_MODE#' = 'INCREMENTAL_TABLE_ONLY' )
      AND AVAIL_FROM_TMS >= TO_TIMESTAMP('#PM_EXTRACT_DT#','YYYY-MM-DD') + INTERVAL '-#PM_DAYS_FROM#' DAY 
      AND AVAIL_FROM_TMS < TO_TIMESTAMP('#PM_EXTRACT_DT#' ,'YYYY-MM-DD')  
        THEN 1
	  WHEN '#PM_LOAD_MODE#' = 'ALL_VALID'  
      AND VLD_TO_TMS =  to_date('9999-12-31','YYYY-MM-DD') 
        THEN 1
      WHEN '#PM_LOAD_MODE#' = 'HISTORICAL'  
        THEN 1
      ELSE 0
    END ;


--############################################################

create or replace procedure xx (NO_OF_DAYS NUMBER)
authid current_user
is

/*---------------------------------------------------------------------------------------------
-- PURPOSE : 
-- USAGE: 
------------------------------------------------------------------------------------------------- */

BEGIN
declare
si_hw varchar2(555);
..
si_no_of_days number;
BEGIN
FOR rr IN (SELECT object_name  FROM USER_OBJECTS WHERE OBJECT_TYPE = 'TABLE' and object_name like '%_LND')
   LOOP
    DBMS_OUTPUT.PUT_LINE(' for loop entered: ' ||rr.object_name||'');
   FOR cc IN (SELECT partition_name, high_value FROM user_tab_partitions WHERE table_name = upper(rr.object_name))
   LOOP

       si_hw   := cc.high_value; -- get Hight_value
       si_hw_y := substr(si_hw, 11,4); --get year from high_value exp:2014
..
       si_no_of_days := NO_OF_DAYS ;

       si_hw_dmy := si_hw_d || '-' || si_hw_m || '-' ||si_hw_y;  --concatenate  year and month  and date  which we get from high_value
       si_hw_date := to_date(si_hw_dmy,'dd-mm-yyyy')+ si_no_of_days;            --convert it to date and add si_no_of_days days (partition kept for X [= si_no_of_days] days)

        IF sysdate > si_hw_date THEN   
			--EXECUTE IMMEDIATE ' ALTER TABLE '||'DM_FEC.'||rr.object_name||' DROP PARTITION ' || cc.partition_name ||' UPDATE INDEXES';
            DBMS_OUTPUT.PUT_LINE('The partition that WAS deleted is EXTRACT_DT high value ' || si_hw_dmy  || ', Named: ' ||cc.partition_name  );                 
        END IF;

    END LOOP;
 END LOOP;

END;

END;


-- F0035_RulesRuns&Failed.sql


--## Foo35 and test results   #####################


/* 
The process (very high level):
•	The IGC Rules (pertaining to a CDE and joined to a specific rule / DataStage job) are enriched and loaded into the F00XX_REP_DIM_RULES table
•	The other Dimensions are updated (also from the IGC) with things like Criticality etc. and linked to each rule (We set these up in the IGC rules, but they don’t form any part of our DataStage processes)
•	As can be seen in the data model, there are two Fact tables (results from when we run our DataStage jobs for each rule)
•	Our jobs count the records that have passed and failed the rules and one record per rule job is output to the main fact table with the results
•	A record is produced in the Failed fact table for every record that fails the rule
•	Before these fact records are produced, the job joins the fact to the rule, so that the surrogate key to the rule exists on the fact records. 
*/

-- 1) FCT_RULE_EXECUTIONS joined to DIM_RULES for job testing results

SELECT  r.data_rule_nm
,       e.num_records_met as met
,       e.num_records_notmet as notmet 
,       e.num_records_met + e.num_records_notmet as total 
,       to_char(e.exec_timestamp, 'HH:MI') as time_ran
,       r.bus_rule_nm
,       e.data_date_key
,       r.valid_flag
,       r.valid_from
--,        r.valid_to
,       e.date_key
,       e.ds_job_run_id as run_id 
-- shorter select statement below to see key columns only: 	
-- SELECT     r.data_rule_nm, e.num_records_met as met, e.num_records_notmet as notmet ,  r.bus_rule_nm 
FROM f0035_rep_fct_rule_executions e
INNER JOIN F0035_REP_DIM_RULES r
ON e.data_rule_id = r.data_rule_id
where r.data_rule_nm like 'WB_DL_DQ_XPAY_G%'  -- 'WB_DL_DQ_XPAY_G%' -- (for just GBS EU)
AND e.date_key >= 20220315  -- so we can only see recent runs
--AND  e.exec_timestamp >  (sysdate - 2/24) -- so we can only see recent runs
AND e.rule_exec_id in (SELECT max(rule_exec_id) FROM f0035_rep_fct_rule_executions WHERE date_key >= 20220101 GROUP BY data_rule_id )
--AND e.num_records_met > 0 -- to only see successful runs
order by r.data_rule_nm ASC, e.exec_timestamp DESC  
;

--,      ROUND(( e.num_records_notmet * 100 ) / ( e.num_records_met + e.num_records_notmet + 0.00001 ),2 ) PERCENTFAILED
--,      ROUND(( e.num_records_met * 100 ) / ( e.num_records_met + e.num_records_notmet + 0.00001 ),2 ) PERCENTPASSED

-- date function eg:
-- select to_char(to_date('2014-10-15 03:30:00 pm', 'YYYY-MM-DD HH:MI:SS pm') + 1/24, 'YYYY-MM-DD HH:MI:SS pm') from dual;

-- 2a) FCT_FAILED_RECORDS for job unit testing - all jobs should have some in DEV before promotion to ACC.

SELECT  
        r.data_rule_nm
,       f.failed_pk
,       f.exec_timestamp
,       f.date_key
,       r.valid_flag
,       r.valid_from
,       f.data_rule_id
--    r.valid_to,
--SELECT     r.data_rule_nm, r.bus_rule_nm, f.failed_pk 	
FROM    f0035_rep_fct_failed_records f
INNER JOIN F0035_REP_DIM_RULES r
ON f.data_rule_id = r.data_rule_id
where r.data_rule_nm like 'WB_DL_DQ_XPAY_G%' -- (for just GBS EU)
AND f.exec_timestamp >  (sysdate - 1/24) -- so we can only see recent runs
order by r.data_rule_nm ASC, f.exec_timestamp DESC -- r.data_rule_nm;
;


-- 3) F0035_REP_DIM_RULES - the slowly changing dimension "static data" table that contains the rules defined in IGC.  
/*   -- NB a few steps for IGC (PROD) rules to get into this DEV table: 
  1) Candy publish PRD rules so they sync to DEV
  2) In DS designer, bind the DS job rule stage to the appropriate IGC rule. 
  3) in DEV IGC: find the DS Job and then DR_complexcheck stage > under "implements rules" select the rule created in IGC .
    ie this is a "two-way" binding!! Done in DS as well as IGC - whats up with that?!
  4) run features/F0035/V00005 folder > F0035_v00005_SQ_Reporting_Load_MasterData DS job to copy from IGC to DEV F35 tables 
 */

SELECT data_rule_id 
,      exec_date 
,      prj_nm 
,      data_rule_nm 
,      data_rule_def_nm 
--,      data_rule_desc  -- NULL - same for other SoRs ? 
,      bus_rule_nm 
--,      bus_rule_desc -- SAME as data_rule_nm - always?
,      data_user 
,      crit_id 
,      valid_from   -- SAME as exec_date - always?
,      valid_to  
,      valid_flag 
FROM F0035_DATAQUALITY.F0035_REP_DIM_RULES
WHERE data_rule_nm like 'WB_DL_DQ_XPAY_G%' OR prj_nm like 'WB_%_TFBG%' -- (for GBS EU and Ti+)
order by exec_date DESC -- to show most recently added rules.
;






