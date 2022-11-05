#!/bin/ksh
###################################################################
# Script   : ${MY_HOME}/scripts/DSjob_run_batches.sh
# Purpose  : calls named DS sequences using Unix dsjob comand. 
#          :  
# Usage    : DSjob_run_batches.sh <job_string> <BUSINESS_DATE> [PROJECT]
#          : alias dsjs='echo "running: DSjob_run_batches.sh <BUSINESS_DATE> <job_string> [excl_string] ${PROJ_DEF} .." ; DSjob_run_batches.sh'
#          : #dsjs 20131001 LON_SLIM_RIMMS_ISCA_Recon_SLIMExtract 
#          : dsjs 20131014 CDRRecon_CDR "Gloss|MONACO"
# Modifications :
# Date         User               Description
#  -------------------------------------------------------------------------------------------
# 11/10/2013   Simon Osborne      Created

BUSINESS_DATE=${1}

#Default JOB_FILTER_STRING is *, else use ${2} if this parameter is supplied.
if [[ -z ${2} ]] ; then JOB_FILTER_STRING="." ; else    JOB_FILTER_STRING=${2} ; fi

#Default EXCLUDE_STRING is 'NOTHING' (no exlusions) , else use ${3} if this parameter is supplied. 
if [[ -z ${3} ]] ; then  EXCLUDE_STRING='NOTHING' ; else  EXCLUDE_STRING=${3} ; fi

#default RESET_FLAG name to use is "-Reset", else if parameter $4 is supplied as ANYTHING ELSE use "" ie no job reset.
if [[ -z ${4} ]] ; then RESET_FLAG="-Reset" ; else RESET_FLAG="" ; fi

#default PROJECT name to use is the environment one, else if parameter $5 is supplied use that.
if [[ -z ${5} ]] ; then PROJECT=${PROJ_DEF} ; else PROJECT=${5} ; fi
PROJECTNAME=${PROJECT}

BATCH_LIST_FILE=${MY_HOME}/scripts/ETL_batch_list.txt

#default LOGDIR to use is from environment / .profile, else use a specified path - # out where appropriate.
if [[ -z ${LOGDIR} ]]
then
   LOG_DIR=/users/q4wn5gc/scripts/logs # LOGDIR=/tmp
else
   LOGDIR_MSG="Using LOGDIR from environment / .profile = ${LOGDIR} " 
   LOG_DIR=${LOGDIR}
fi

RUNDATE=`date '+%Y_%m_%d'` 
export LOGDIR_MSG LOGDIR RUNDATE BATCH_LIST_FILE PROJECTNAME RESET_FLAG UAT_DESC JOB_FILTER_STRING EXCLUDE_STRING

function F_GENERIC_BATCH_STEPS {

echo "PROJ_CODE=${PROJ_CODE} RESET_FLAG=${RESET_FLAG} UAT_DESC=${UAT_DESC} "

UAT_DESC=${PROJ_CODE}_TESTING_$(uname -n)_${RUNDATE}

echo "${BATCH_LIST_FILE} subset of jobs to be run - ones with ${JOB_FILTER_STRING} in their name, exluding "${EXCLUDE_STRING}": "
cat ${BATCH_LIST_FILE} | grep "^${PROJ_CODE}" | egrep -i ${JOB_FILTER_STRING} | egrep -iv "^#|${EXCLUDE_STRING}" 

}

function F_SLIM_STEPS { 
   # NB: not using this for SLIM yet, just an idea and copy of CDR for now. 
   # The I-B manual TEMP_BATCH_LIST="${BATCH_LIST}" loop seems to work quite well. 
   # and for O-B, the SLIM_batch_run_Tidal.sh script call loop seems to work quite well for now. Though rememeber these :"3) OUTbound - Poller - (just 2, eGL and one LON rec )" 
cat ${BATCH_LIST_FILE} | grep "^${PROJ_CODE}" | egrep -i ${JOB_FILTER_STRING} | egrep -iv "^#|${EXCLUDE_STRING}" | while read LINE    
do
   BATCH_NAME=`echo "${LINE}" | cut -d"|" -f1 | tr -d ' '`
   SOURCE_SYSTEM=`echo "${LINE}"    | cut -d"|" -f2 | tr -d ' '`
   DS_SEQ=`echo "${LINE}"     | cut -d"|" -f3 | tr -d ' '`
   DS_SUB_JOB=`echo "${LINE}"     | cut -d"|" -f4 | tr -d ' '`
   echo `date '+%Y-%m-%d_%H:%M:%S :'` "Starting ${PROJ_CODE} ${DS_SEQ}" | tee "${LOG_DIR}/${DS_SEQ}.log"
   sleep 5
    ETL_DSJobExe.ksh /opt/etl/code/bin/common CDR_RECON ${DS_SEQ} "-param etlAuditSourceSystemName=${SOURCE_SYSTEM} -param Business_Date=${BUSINESS_DATE} -param Load_Frequency=D" "${RESET_FLAG}" 2>&1 > /dev/null 
    rc=$? ; echo RETURN_CODE=${rc} | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
    if [[ ${rc} -lt 3 ]]; then
       echo `date '+%Y-%m-%d_%H:%M:%S :'`   "Completed ${DS_SEQ} " | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
    else 
      echo `date '+%Y-%m-%d_%H:%M:%S :'` "FAILED on ${DS_SEQ}" | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
      ${SCRIPTS_1}/DSjob_error_check.ksh ${DS_SEQ}             | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
      if [ -n ${DS_SUB_JOB} ] ; then ${SCRIPTS_1}/DSjob_error_check.ksh ${DS_SUB_JOB} | tee -a  "${LOG_DIR}/${DS_SEQ}.log" ; fi
      # break ${rc} # only for dependancy batches
    fi
    tail -50 "${LOG_DIR}/${DS_SEQ}.log" >> "${LOG_DIR}/${UAT_DESC}.log" ; echo >> "${LOG_DIR}/${UAT_DESC}.log"
   chmod -f 777 "${LOG_DIR}/${DS_SEQ}.log" "${LOG_DIR}/${UAT_DESC}.log" # ; cat "${LOG_DIR}/${DS_SEQ}.log"
done
}

function F_CDR_RECON_STEPS {
cat ${BATCH_LIST_FILE} | grep "^${PROJ_CODE}" | egrep -i ${JOB_FILTER_STRING} | egrep -iv "^#|${EXCLUDE_STRING}" | while read LINE    
do
   BATCH_NAME=`echo "${LINE}" | cut -d"|" -f1 | tr -d ' '`
   SOURCE_SYSTEM=`echo "${LINE}"    | cut -d"|" -f2 | tr -d ' '`
   DS_SEQ=`echo "${LINE}"     | cut -d"|" -f3 | tr -d ' '`
   DS_SUB_JOB=`echo "${LINE}"     | cut -d"|" -f4 | tr -d ' '`
   echo `date '+%Y-%m-%d_%H:%M:%S :'` "Starting ${PROJ_CODE} ${DS_SEQ}" | tee "${LOG_DIR}/${DS_SEQ}.log"
   sleep 5
    ETL_DSJobExe.ksh /opt/etl/code/bin/common CDR_RECON ${DS_SEQ} "-param etlAuditSourceSystemName=${SOURCE_SYSTEM} -param Business_Date=${BUSINESS_DATE} -param Load_Frequency=D" "${RESET_FLAG}" 2>&1 > /dev/null 
    rc=$? ; echo RETURN_CODE=${rc} | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
    if [[ ${rc} -lt 3 ]]; then
       echo `date '+%Y-%m-%d_%H:%M:%S :'`   "Completed ${DS_SEQ} " | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
    else 
      echo `date '+%Y-%m-%d_%H:%M:%S :'` "FAILED on ${DS_SEQ}" | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
      ${SCRIPTS_1}/DSjob_error_check.ksh ${DS_SEQ}             | tee -a  "${LOG_DIR}/${DS_SEQ}.log"
      if [ -n ${DS_SUB_JOB} ] ; then ${SCRIPTS_1}/DSjob_error_check.ksh ${DS_SUB_JOB} | tee -a  "${LOG_DIR}/${DS_SEQ}.log" ; fi
      # break ${rc} # only for dependancy batches
    fi
    tail -50 "${LOG_DIR}/${DS_SEQ}.log" >> "${LOG_DIR}/${UAT_DESC}.log" ; echo >> "${LOG_DIR}/${UAT_DESC}.log"
   chmod -f 777 "${LOG_DIR}/${DS_SEQ}.log" "${LOG_DIR}/${UAT_DESC}.log" # ; cat "${LOG_DIR}/${DS_SEQ}.log"
done
}

# cat "${LOG_DIR}/${DS_SEQ}.log"  ; chmod -f 777 "${LOG_DIR}/${DS_SEQ}.log"

PROJ_PREFIX=`echo ${PROJ_DEF} | cut -d'_' -f1 | tr [:lower:] [:upper:]`
case ${PROJ_PREFIX} in
  SLIM) export PROJ_CODE='SLIM'       ;  F_GENERIC_BATCH_STEPS ;  F_SLIM_STEPS      ;; # for inbound jobs 
  CDR)  export PROJ_CODE='CDR_RECON'  ;  F_GENERIC_BATCH_STEPS ;  F_CDR_RECON_STEPS ;;
esac



exit



Call_CDR_RECON()
{ 
   BATCH_NAME=`echo "${LINE}" | cut -d"|" -f1`
   SOURCE_SYSTEM=`echo "${LINE}"    | cut -d"|" -f2`
   DS_SEQ=`echo "${LINE}"     | cut -d"|" -f3`
   echo `date '+%Y-%m-%d_%H:%M:%S :'` "Starting ${PROJ_CODE} ${DS_SEQ}" | tee ${LOG_DIR}/${DS_SEQ}.log
   sleep 5
    ETL_DSJobExe.ksh /opt/etl/code/bin/common CDR_RECON ${DS_SEQ} "-param etlAuditSourceSystemName=${SOURCE_SYSTEM} -param Business_Date=${BUSINESS_DATE} -param Load_Frequency=D" 2>&1 > /dev/null 
}


# LOGFILE=${LOG_DIR}/${JOB}.log
# EMAIL_FLAG=N            # email the output to ${DISTR_LIST} ?

#default DISTR_LIST to use is from environment / .profile, else use a specified path - # out where appropriate.
if [[ -z ${DISTR_LIST} ]]
then ; echo
   # DISTR_LIST='simon.osborne@rbccm.com'
   # DISTR_LIST='a.b@rbccm.com'
else ; echo
   # echo "Using DISTR_LIST from environment / .profile = ${DISTR_LIST} " 
fi


   # DS_SEQ_LOG_FILE=${LOG_DIR}/${DS_SEQ}.log

for BATCH in ${TEMP_BATCH_LIST}  ; do
   # only for dependancy batches :
   #COMPLETED_CHECK=`grep -wc "Completed ${BATCH}" ${LOG_DIR}/${UAT_DESC}.log` ; ISSUE_CHECK=`echo ${ISSUE_BATCH_LIST} | grep -wc "${BATCH}"` # ; echo ${BATCH} ${COMPLETED_CHECK} ${ISSUE_CHECK}
   #if [ ${COMPLETED_CHECK} -ne 0 ] || [ ${ISSUE_CHECK} -ne 0 ]  ; then echo "SKIPPING already RUN or ISSUE job: ${BATCH}" ; continue ; fi
   echo `date '+%Y-%m-%d_%H:%M:%S :'` "Starting ${BATCH}" | tee ${LOG_DIR}/${BATCH}.log
   sleep 5
#   dsjs ${BATCH} ; rc=$? # ; echo ${rc}
    # echo PROCESS_RUN_ID=${ID} -param BUS_DATE_START=${BUSINESS_DATE} ${PROJ_DEF} ${BATCH}
    ETL_DSJobExe.ksh /opt/etl/code/bin/common CDR_RECON ${SEQ} "-param etlAuditSourceSystemName=${SS_NAME} -param Business_Date=${BUSINESS_DATE} -param Load_Frequency=D"
    # dsjob -run -jobstatus -param PROCESS_RUN_ID=${ID} -param BUS_DATE_START=${BUSINESS_DATE} ${PROJ_DEF} ${BATCH} # -param LPG_ID=4 not needed for O/B?
    rc=$? ; echo RETURN_CODE=${rc}
    if [[ ${rc} -lt 3 ]]; then
       echo `date '+%Y-%m-%d_%H:%M:%S :'`   "Completed ${BATCH} " | tee -a  ${LOG_DIR}/${BATCH}.log
    else 
      echo `date '+%Y-%m-%d_%H:%M:%S :'` "FAILED on ${BATCH}" | tee -a  ${LOG_DIR}/${BATCH}.log
      ${SCRIPTS_1}/DSjob_error_check.ksh ${BATCH}             | tee -a  ${LOG_DIR}/${BATCH}.log
      # break ${rc}
    fi
    # cat ${LOG_DIR}/${BATCH}.log >> ${LOG_DIR}/${UAT_DESC}.log ; echo >> ${LOG_DIR}/${UAT_DESC}.log
done






   # echo BATCH_NAME=${BATCH_NAME} SYSTEM=${SOURCE_SYSTEM} DS_SEQ=${DS_SEQ}
   # Call_CDR_RECON


# PROCESS_RUN_ID=10001 ; ID=${PROCESS_RUN_ID} 
# BUS_DATE_START=${BUSINESS_DATE} ; BATCH_BUS_DATE=${BUSINESS_DATE}
# LPG_ID=4 
