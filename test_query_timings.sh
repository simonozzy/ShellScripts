#!/bin/bash
###################################################################################################
#  test.sh   - for draft script creation
#  USAGE:  sh ./test.sh
# https://stackoverflow.com/questions/16908084/bash-script-to-calculate-time-elapsed

# SQL_LIST
# for SQL in ${SQL_LIST} do SQL=  echo ${LINE}

DEF_DB=gdil_stg_owner_d
# SQL_1="use ${DEF_DB}; SELECT t.table_name FROM INFORMATION_SCHEMA.TABLES t WHERE t.table_schema = 'gdil_stg_owner_d'; "
#SQL_2="show tables;"
SQL_1="SELECT count(*) FROM GBS_ACBX WHERE ODS_BUSINESS_DATE='20220203000000' ;"

SQL_2="SELECT 'GBS_ACBX' as table_name, count(1) as row_count, count(DISTINCT ods_business_date ) as days_count, min(ods_business_date) as date_min, max(ods_business_date) as date_max, round(count(1) / count(DISTINCT ods_business_date )) as avg_per_day FROM GBS_ACBX \
UNION SELECT 'GBS_ACID' as table_name, count(1) as row_count, count(DISTINCT ods_business_date ) as days_count, min(ods_business_date) as date_min, max(ods_business_date) as date_max, round(count(1) / count(DISTINCT ods_business_date )) as avg_per_day FROM GBS_ACID \
UNION SELECT 'GBS_AENT' as table_name, count(1) as row_count, count(DISTINCT ods_business_date ) as days_count, min(ods_business_date) as date_min, max(ods_business_date) as date_max, round(count(1) / count(DISTINCT ods_business_date )) as avg_per_day FROM GBS_AENT \
"

SECONDS=0
echo SQL_1: ${SQL_1}
hive --showHeader=false --outputformat=csv2 --silent=true -e "use ${DEF_DB}; ${SQL_1}"  > SQL_1_OUT.csv 2>/dev/null 
SECONDS_1="$((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"
echo SQL_1 Should take around 20s and just now it took: ${SECONDS_1}

SECONDS=0
# echo SQL_2: ${SQL_2}
hive --showHeader=false --outputformat=csv2 --silent=true -e "use ${DEF_DB}; ${SQL_2}" > SQL_2_OUT.csv 2>/dev/null
SECONDS_2="$((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"
echo SQL_2 Should take around 20s and just now it took: ${SECONDS_2}

SECONDS=0
echo SQL_3 is from file: CDE_samples.sql
hive --showHeader=false --outputformat=csv2 --silent=true -f ./CDE_samples.sql > SQL_3_OUT.csv 2>/dev/null
SECONDS_3="$((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"

echo SQL_1 Should take around 20s and just now it took: ${SECONDS_1}
echo SQL_2 Should take around 20s and just now it took: ${SECONDS_2}
echo SQL_3 Should take around 3m 20s and just now it took: ${SECONDS_3}


exit

###########################
 
echo "$((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s" 

## Or the Function way:
secs_to_human() {
    echo "$(( ${1} / 3600 ))h $(( (${1} / 60) % 60 ))m $(( ${1} % 60 ))s"
}

secs_to_human $SECONDS

https://unix.stackexchange.com/questions/267536/why-we-need-to-have-21-in-dev-null-21?rq=1

The numbers are file descriptors and only the first three (starting with zero) have a standardized meaning:

0 - stdin
1 - stdout
2 - stderr

So each of these numbers in your command refer to a file descriptor. You can either redirect a file descriptor to a file with > or redirect it to another file descriptor with >&



