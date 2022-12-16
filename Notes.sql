

-- ###  regex notes in Notepad++:
To replace a carriage return using the "extended" option, replace this:
\r\n

Add the -- to the start of this string: -- 7) 
	->  F:(\d+\)) R: --\1  
	-> F:^(.+ENTITY_CODE.+)) R: --\1  [comment out all lines containing "ENTITY_CODE"]
	where \1 = whatevers in the first set of () 
	
Convert this string ton the below two lines:  AR_ING_OPRL_UNIT_M "(  
   -- 0X) AR_ING_OPRL_UNIT_M	 
     CREATE VIEW AR_ING_OPRL_UNIT_M	 AS (
	F: ^(.+)"\(  R: \n-- 0X\) \1 \nCREATE VIEW \1 AS \(
	

-- Add _LND just before the second dot of each line - genius:
F: ^(.+)\.(.+)\.(.+)$
R: \1\.\2_LND.\3

-- ### Powershell bits
SUBST T: \\..\WT83YU\Home\Temp
cd N:
## Get-ChildItem -File -Path S: -Filter *.* -Recurse | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-3)}  | Sort-Object LastWriteTime -Descending | Select Fullname,LastWriteTime   | Select-Object -First 20

Get-ChildItem -File -Path M: -Filter *.* -Recurse | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-10)}  | Sort-Object LastWriteTime -Descending | Select Fullname,LastWriteTime   | Select-Object -First 20

--## Weekly manual backups:
xcopy /ECYRIFD H:\Temp\* N:\Misc\TempBackup\

-- SUBST drive mapping and windows setup on login:
C:\Users\..\Documents\Misc\Apps\launch.bat

Get-ChildItem -File -Path M: -Filter *.* -Recurse| ? {$_.LastWriteTime -gt (Get-Date).AddDays(-5)}  | Sort-Object LastWriteTime -Descending  | Select Fullname,LastWriteTime   | Select-Object -First 20 

--count files:
(ls | Measure-Object -line).Lines

--obtain a line count of all your txt files:
type *.txt | Measure-Object -line

--If you want to count all words in all text files in a directory:
Get-ChildItem <INPUT_FOLDER_PATH> -Recurse -Filter *.txt | Get-Content | measure -Word -Line - Character

-- #### tech / app notes

-- EXCEL: 
column grouping: select column A, and then hold Shift + Alt + Right arrow 

-- KQL for Teams / SP / Outlook / WinExp searching: 
sent: 2021-09-14..2021-09-15
-- eg.: to build a KQL query in Query Builder from Search Result Sources under Site Collection Administration. The output of the results must be only office related files (Doc, Docx, PPT, PPTX, XLS, XLSX) OR PDF OR MP4 Or Folders.
 {SearchBoxQuery} ((FileExtension:mp4 OR FileExtension:doc OR FileExtension:docx OR FileExtension:xls OR FileExtension:xlsx OR FileExtension:ppt OR FileExtension:pptx OR FileExtension:pdf) AND (IsDocument:"True" OR contentclass:"STS_ListItem")) OR ContentType="Folder"   
 
-- Outlook shortcuts
Add a bulleted list - select and then Ctrl+Shift+L
Or Type * (asterisk) to start a bulleted list or 1. to start a numbered list, and then press Spacebar.

-- ### Shell bits - DS and Hive / beeline

DS_JOB_LIST="
JOB_1          \
..
"                                  

for BATCH in ${DS_JOB_LIST}  ; do
   echo `date '+%Y-%m-%d_%H:%M:%S :'` "Starting ${BATCH}" | tee ${LOG_DIR}/${BATCH}.log
   sleep 2
    dsjob -run -mode RESET -wait -jobstatus ${PROJ_DEF} ${BATCH}
	dsjob -run -wait -jobstatus -param PM_LOAD_MODE=${PM_LOAD_MODE} -param PM_SRCTBL_SCHEMA=${PM_SRCTBL_SCHEMA} -param PM_EXTRACT_DT=${PM_EXTRACT_DT} -param PM_DAYS_FROM=${PM_DAYS_FROM} ${PROJ_DEF} ${BATCH}
    rc=$? ; echo RETURN_CODE=${rc}
    if [[ ${rc} -lt 3 ]]; then
       echo `date '+%Y-%m-%d_%H:%M:%S :'`   "Completed ${BATCH} " | tee -a  ${LOG_DIR}/${BATCH}.log
    else 
      echo `date '+%Y-%m-%d_%H:%M:%S :'` "FAILED on ${BATCH}" | tee -a  ${LOG_DIR}/${BATCH}.log
    fi
    # cat ${LOG_DIR}/${BATCH}.log >> ${LOG_DIR}/${UAT_DESC}.log ; echo >> ${LOG_DIR}/${UAT_DESC}.log
done

--### HIVE bits #################################

hive --showHeader=false --outputformat=csv2 -e "use xx_stg_owner; show tables;" | egrep -v "_temp|_ext|WARN"  | egrep -i "EVNT_STP_HST|PRTY_RL" >> all_tables_main.txt

cat all_tables_main.txt | cut -d "_" -f1 | sort -u --# gives below SORLIST after manual refinement

SORLIST="flink_|xirm_"
hive --showHeader=false --outputformat=csv2 --silent=true -e "SELECT t.table_name FROM INFORMATION_SCHEMA.TABLES t WHERE t.table_schema = 'xx_stg_owner_d' " > d_all_tables.txt

hive --showHeader=false --outputformat=csv2 --silent=true -e "use gdil_stg_owner; show tables;" | egrep -v "_temp|_ext|WARN" | egrep "gbs_|flink_|gams_|gdd_|wb|_lx" > all_tables_main.txt

hive -i ~/sql/config.sql --silent=true

FILTER="COVER|CUST|_ASSETS|_AVL|_AGR|_CST|_LIMIT|_OBTBL|_PRD_" ; EXCLUDE="deal_lbt|_lndr"
SORLIST="flinkxx_ gams_"
FILTER2="EVNT_STP_HST|PRTY_RL" 
EXCLUDE="_v2|_v3|_v4" ; FILTER="_v1"

for SOR in ${SORLIST}
do
>tablesDDL_${SOR}.txt
cat all_tables_main.txt | egrep "${SOR}" | egrep -i "${FILTER}"  | egrep -i "${FILTER2}" | egrep -vi "${EXCLUDE}" | while read LINE
do
echo ${LINE}
hive --showHeader=false --outputformat=csv2 --silent=true -e"use xx_stg_owner; show create table ${LINE}" >>tablesDDL_${SOR}.txt
echo \; >>tablesDDL_${SOR}.txt
echo '' >>tablesDDL_${SOR}.txt
done
sed -e 's/_v1//gi' -e 's/HDPACC1\/GDIL\/GDIL_STG_OWNER/HDPTST4\/GDIL\/GDIL_STG_OWNER_D/g' -e 's/CREATE EXTERNAL TABLE/CREATE EXTERNAL TABLE IF NOT EXISTS/g' tablesDDL_${SOR}.txt > tablesDDL_${SOR}.sql
done

--### system object tables

SELECT t.table_name  
FROM INFORMATION_SCHEMA.TABLES t
WHERE t.table_schema = 'gdil_stg_owner'
--AND TABLE_NAME NOT LIKE '%_temp' AND TABLE_NAME NOT LIKE '%_ext'
AND TABLE_NAME LIKE '%_v1'
--AND TABLE_NAME LIKE '%_TI%'
 limit 500;
 
SELECT table_name
,      column_name
,      replace(data_type,",",";") 
,      is_nullable
,      ordinal_position
,      numeric_precision 
,      numeric_scale
FROM information_schema.columns 
WHERE table_schema = 'gdil_stg_owner'
AND TABLE_NAME NOT LIKE '%_temp' AND TABLE_NAME NOT LIKE '%_ext'
AND TABLE_NAME LIKE '%_v1'
--AND (TABLE_NAME LIKE 'tip_%' OR TABLE_NAME LIKE 'tfs_%' )
ORDER BY table_name, ordinal_position
;

-- Test table created on T$ Hive - insert various special characters: #################################
 
INSERT INTO cbd_testing_regex (test_string)
VALUES 
('EXIT LIST'), ('-FWD-REG'), (' SpaceBefore'), ('SpaceAfter '), ('$SpecBefore'), ('-12344'), ('SpecAfter$'), ('SpecAfter'), ('SpecAfter'), ('CyrillicЛ'), ('ШCyrillic'), ('TabAfter	'), ('INSOLVENTA&'), ('13-OP-B-S3'), ('12_345_')
;

SELECT test_string FROM cbd_testing_regex ;

-- test various regex permutations to see pass (1) fail (0)
-- similar data could be inserted for date testing

Select test_string 
, CASE when test_string  RLIKE '[0-9]|[a-z]|[A-Z]+$'    THEN 1 Else 0 end as test_1_bad 
-- ignore not useful
, CASE when test_string  RLIKE '^([0-9]|[a-z]|[A-Z])*$' THEN 1 Else 0 end as test_2 
-- allow only [0-9]|[a-z] but also allowing _ $ -  as well as Cyrillic ! 
, CASE when test_string  RLIKE '[^\u0000-\u009F]+'     THEN 1 Else 0 end as test_3
-- allow only 0-9]|[a-z] but also allowing _ $ -  as well as Cyrillic ! 
, CASE when test_string  RLIKE '[^\x20-\x7E]|[^\xA1-\xFF]+'         THEN 1 Else 0 end as test_4
-- trying to code for Mark's " only visible Cyrillic characters" 
-- looking good, though not sure why _ is failing here
, CASE when test_string  RLIKE '[^\x20-\x7f]+\ *(?:[^\x01-\xFF]| )*'  THEN 1 Else 0 end as test_5
-- something I found online which is similar to test_4 
-- looking good, though not sure why _ is failing here
from gdil_stg_owner_d.cbd_testing_regex
;

-- Regex in DS / SQL 
Here is why we need the ^(*)$ bits :
https://stackoverflow.com/a/4440310

ie. In DS this works for
Whole ROW must only contain numbers:
^[0-9]*$
And this would work for
Whole row must not contain any numbers :
^([^0-9]*)$
- similar to hidden requirement but with different []

^([^\uFFF0-\uFFFF\u0000-\u001f\uFFFD]*)$

tested here https://regexr.com/6nnq2


