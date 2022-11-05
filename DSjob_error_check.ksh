#!/bin/ksh
###################################################################
# Script   : ${SCRIPTS_1}/DSjob_error_check.ksh
# Purpose  : calls named DS sequence using Unix dsjob comand.  
#          :  
# Usage    : job_log_check_named.ksh <job_name> [PROJECT]
#          :  
# Modifications :
# Date         User               Description
#  -------------------------------------------------------------------------------------------
# 15/06/2013   Simon Osborne      Created

JOBNAME=${1}
EMAIL_FLAG=N            # email the output to ${DISTR_LIST} ?

#default PROJECT name to use is the environment one, else if parameter $2 is supplied use that.
if [[ -z ${2} ]]
then
   PROJECT=${PROJ_DEF}
else
   PROJECT=${2}
fi
PROJECTNAME=${PROJECT}

#default LOGDIR to use is from environment / .profile, else use a specified path - # out where appropriate.
if [[ -z ${LOGDIR} ]]
then
   LOGDIR=/users/q4wn5gc/scripts/logs # LOGDIR=/tmp
   # LOGDIR=/opt/bi/code/bin/slim/scripts/logs  
else
   LOGDIR_MSG="Using LOGDIR from environment / .profile = ${LOGDIR} " 
fi

#default DISTR_LIST to use is from environment / .profile, else use a specified path - # out where appropriate.
if [[ -z ${DISTR_LIST} ]]
then
   DISTR_LIST='simon.osborne@rbccm.com'
   # DISTR_LIST='a.b@rbccm.com'
else
   echo "Using DISTR_LIST from environment / .profile = ${DISTR_LIST} " 
fi

# 8.5
#DSJOB=/ibm/InformationServer/Server/DSEngine/bin/dsjob
#DSEXEC_DIR=/opt/etl/code/bin/slim/DSExec
# OR 7.5
# DSJOB=/app/ascential/Ascential/DataStage/DSEngine/bin/dsjob
# DSEXEC_DIR=/opt/bi/code/bin/slim/DSExec/scripts

LOGFILE=${LOGDIR}/${JOB}.log

# SLIM_LOG=${DSEXEC_DIR}/logs/runjob.log
#SLIM_LOG=/data/etl/NAS/ZAS0/SLIM/logs/$JOBNAME.log  

# echo "START RUN PROCESS: `date` \n" >> $SLIM_LOG

usage ()
{
   echo Usage:
   echo "      " runjob.ksh \<PROJECT_NAME\> \<PROCESS_NAME\>
   echo
   echo "      " PROJECT_NAME - Usually in the form SLIM-\<environment\>
   echo "      " PROCESS_NAME - Must be the name of an existing defined process.
   echo
}

if [ $# -ne 1 ]
then 
   usage
   exit 1
fi


##############################
## Batch_Error_logging()   #
##############################
#Batch_Error_logging()
#{

# 1) Firstly, the calling sequence errors:
DS_JOB=${JOBNAME}
# DS_SEQ_LOG_FILE=${SLIM_LOG}

echo ${PROJECTNAME} ${JOBNAME} ${DS_JOB} ${SLIM_LOG} ${START_ID} ${ALL_IDS}

echo "######    Calling Sequence/Job: ##  ${JOBNAME} ## - any warning and fatal messages: ######" >> ${LOGFILE}

START_ID=`dsjob  -logsum -type STARTED ${PROJECTNAME} ${DS_JOB} | gawk 'ORS=(FNR%2)?FS:RS' | grep Starting | tail -1 | awk '{print $1 }'`
WARN_IDS=`dsjob  -logsum -type WARNING ${PROJECTNAME} ${DS_JOB} | grep WARNING | awk '{print $1 }'`
FATAL_IDS=`dsjob -logsum -type FATAL   ${PROJECTNAME} ${DS_JOB} | grep FATAL | awk '{print $1 }'`
# INFO_IDS=`dsjob  -logsum -type INFO    ${PROJECTNAME} ${DS_JOB} | grep "(JobControl.+status = 3.+Aborted)|Unhandled abort|(some_other_pattern)" | awk '{print $1 }'` 

ALL_IDS=`echo "${WARN_IDS} ${FATAL_IDS} ${INFO_IDS}"` # 

# echo ${PROJECTNAME} ${JOBNAME} ${DS_JOB} ${SLIM_LOG} ${START_ID} ${ALL_IDS}
# echo ${JOBNAME} ${DS_JOB} ${FAILED_JOB} ${ALL_IDS}

for TEST_ID in ${ALL_IDS}
 do
   if [[ "${TEST_ID}" -gt "${START_ID}" ]]
   then
      WARN_DTL=`dsjob -logdetail ${PROJ_DEF} ${DS_JOB} ${TEST_ID}`  2>&1 > /dev/null 
      echo ${WARN_DTL}                                               >> ${LOGFILE}
   fi
 done

# 2) SECONDLY, the called / child job errors, that may have failed:
dsjob -logsum -type INFO ${PROJECTNAME} ${DS_JOB} | egrep "(JobControl.+status = 3.+Aborted)|Unhandled abort"
FAILED_JOB=`dsjob -logsum -type INFO ${PROJECTNAME} ${DS_JOB} | egrep "(JobControl.+status = 3.+Aborted)|Unhandled abort" | awk '{print $4 }'` 
echo ${JOBNAME} ${DS_JOB} ${FAILED_JOB} ${ALL_IDS}

#Default DS_JOB name is assuming "seq_"job_name naming convention used, else use ${FAILED_JOB} if one is found in above line
if [[ -z ${FAILED_JOB} ]] 
   then DS_JOB=`echo ${JOBNAME} | cut -c5-50`  # 
else    
   DS_JOB=${FAILED_JOB} 
fi

echo "" >> ${LOGFILE}
echo "######    Called/child Job #### ${JOBNAME}:${DS_JOB} ## - any warning and fatal messages: ######"  >> ${LOGFILE}

START_ID=`dsjob  -logsum -type STARTED ${PROJECTNAME} ${DS_JOB} | gawk 'ORS=(FNR%2)?FS:RS' | grep Starting | tail -1 | awk '{print $1 }'`
WARN_IDS=`dsjob  -logsum -type WARNING ${PROJECTNAME} ${DS_JOB} | grep WARNING | awk '{print $1 }'`
FATAL_IDS=`dsjob -logsum -type FATAL   ${PROJECTNAME} ${DS_JOB} | grep FATAL | awk '{print $1 }'`
# INFO_IDS=`dsjob  -logsum -type INFO    ${PROJECTNAME} ${DS_JOB} | grep "(JobControl.+status = 3.+Aborted)|Unhandled abort|(some_other_pattern)" | awk '{print $1 }'` 

ALL_IDS=`echo "${WARN_IDS} ${FATAL_IDS} ${INFO_IDS}"` # 
echo ${JOBNAME} ${DS_JOB} ${FAILED_JOB} ${ALL_IDS}

for TEST_ID in ${ALL_IDS}
 do
   if [[ "${TEST_ID}" -gt "${START_ID}" ]]
   then
      WARN_DTL=`dsjob -logdetail ${PROJ_DEF} ${DS_JOB} ${TEST_ID}`  2>&1 > /dev/null 
      echo ${WARN_DTL}                                               >> ${LOGFILE}
   fi
 done

cat ${LOGFILE}

# cat ${LOGFILE} >> ${DSEXEC_DIR}/logs/runjob.log
# if [[ ${EMAIL_FLAG} = 'Y' ]] ; then cat ${LOGFILE}  | mailx -s "DS job log attached : ${LOGSHORT}" "${DISTR_LIST}" ; fi

# }

# Batch_Error_logging ${JOBNAME}


