


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


SUBST T: \\ad.ing.net\WPS\NL\P\UD\200032\WT83YU\Home\Temp
cd N:
## Get-ChildItem -File -Path S: -Filter *.* -Recurse | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-3)}  | Sort-Object LastWriteTime -Descending | Select Fullname,LastWriteTime   | Select-Object -First 20

Get-ChildItem -File -Path M: -Filter *.* -Recurse | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-10)}  | Sort-Object LastWriteTime -Descending | Select Fullname,LastWriteTime   | Select-Object -First 20

## Weekly manual backups:
xcopy /ECYRIFD H:\Temp\* N:\Misc\TempBackup\

Get-ChildItem -File -Path M: -Filter *.* -Recurse| ? {$_.LastWriteTime -gt (Get-Date).AddDays(-5)}  | Sort-Object LastWriteTime -Descending  | Select Fullname,LastWriteTime   | Select-Object -First 20 


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

--###

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
