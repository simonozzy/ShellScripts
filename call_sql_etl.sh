#!/bin/ksh
#/*********************************************************************************************
#  Name     : ~/scripts/call_sql_etl.sh
#  Purpose  : generic shell script to call a .sql file, run the qery and displcay and email (in the email body) the output.
#  Usage    :  call_sql.sh  test input_1
#           :  eg. call_sql.sh latest_development "simon.osborne@rbccm.com" 
#           :  cron eg.) 30 07 * * 1-5 /home/ukrr_pm/scripts/call_sql.sh latest_development "simon.osborne@rbccm.com" 
#  Modification History :
#  Date         User            Description
#  -------------------------------------------------------------------------------------------
#  17/12/2004   S Osborne       Created
#
#*********************************************************************************************/

#. ~ukrr_pm/.profile

# Declare variables :
SQL_INPUT=`echo ${1} | cut -d'.' -f1`

# Default SYBASE_SERVER is LDNEUR otherwise use ${2} if it is supplied.
if [ -z ${2} ] ; then SYBASE_SERVER=${SN} ; else SYBASE_SERVER=${2} ; fi

DISTR_LIST="${3}"

SQL_DIR=~ukrr_pm/scripts/sql 
SQL_FILE=${SQL_DIR}/${SQL_INPUT}.sql
LOG_FILE=~ukrr_pm/log/${SQL_INPUT}.out
> ${LOG_FILE}

# RUNDATE=`date '+%Y-%m-%d %H:%M:%S'` 

SUBJECT="${SQL_INPUT} Report - run on ${SYBASE_SERVER}"
#DISTR_LIST='simon.osborne@rbccm.com' ; # CC_LIST='UKRR-support@rbccm.com'
SENDER='UKRR-support@rbccm.com'

echo 'Usage       :  alias SQL_INPUT // SYBASE_SERVER // DISTR_LIST' 
echo 'Usage eg    :  alias   latest_development // LDNEUR //  simon.osborne@rbccm.com' 
echo "Usage actual:  csql ${1} // ${SYBASE_SERVER} // ${3}" 

# cd ${SQL_DIR}

SERVER_PREFIX=`echo ${SYBASE_SERVER} | cut -c 1-6`

# if [ ${SYBASE_SERVER} = 'LDNEUR' -o ${SYBASE_SERVER} = 'LDNEURDEV' -o ${SYBASE_SERVER} = 'LDNEURDEV_DS' -o ${SYBASE_SERVER} = 'LDNEURBRP' ] ;  then
if [ ${SERVER_PREFIX} = 'LDNEUR' -o ${SERVER_PREFIX} = 'LNPEUR' -o ${SERVER_PREFIX} = 'LNUEUR' -o ${SERVER_PREFIX} = 'LNDEUR' ] ;  then
PW=`cat ~ukrr_pm/.pw`
   UN=`cat ~/.un`
elif [ ${SYBASE_SERVER} = 'XXXX' ] ;  then
   PW=`cat ~ukrr_pm/.pw`
   UN=`cat ~/.un`
else
   case ${SYBASE_SERVER} in
        VTORINFEMG1) UN=bo_report_i ; PW=`cat ~/.PLDNINF10_pw`                    ;;
        PLDNINF10)   UN=bo_report_i ; PW=`cat ~/.PLDNINF10_pw`                    ;;
        TORCTS)      UN=ukrr        ; PW=`cat ~/.pw2`                             ;;       # GCLT
        TORCID)      UN=ukrr        ; PW=`cat ~/.pw2`                             ;;       # CCMS
        LDNINFGCP)   UN=ukrr        ; PW=`cat ~/.pw2`                             ;;       # CCMS
   esac
fi

# SN=`cat ~/.sn` // DB=ukrr_mart //  UN=`cat ~/.un` // PW=`cat ~/.pw`
DB=ukrr_ctrl

if [ ${SYBASE_SERVER} != LDNEUR ] ; then echo "Server Name : ${SYBASE_SERVER} // User Name : ${UN} // PW : ??  "  ; fi
# echo -U${UN} -S${SN} -D${DB} -i ${SQL_FILE} -o ${LOG_FILE}

isql -U${UN} -S${SYBASE_SERVER} -i ${SQL_FILE} -o ${LOG_FILE} -w00000000000000000000000000002000 -P${PW}  # -D${DB}
# isql -I ~/interfaces_local -U${UN} -S${SYBASE_SERVER} -i ${SQL_FILE} -o ${LOG_FILE} -w00000000000000000000000000002000 -P${PW}  -D${DB}

echo "\nThe log file, or the at least the first 200 lines :\n"
head -200 ${LOG_FILE} 

if [ -n "${DISTR_LIST}" ] 
then 
   cat ${LOG_FILE} | mutt  -s "${SUBJECT}" "${DISTR_LIST}"
fi

# cat ${LOG_FILE} | mailx -s "${SUBJECT}" -r "${SENDER}" -c "${CC_LIST}" "${DISTR_LIST}"
