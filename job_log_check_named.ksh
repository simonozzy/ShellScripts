#!/bin/ksh
#/*********************************************************************************************
#  Name     : /opt/bi/code/bin/slim/scripts/job_log_check_named.ksh
#           : OR 
#           : /users/dsadm/bin/scripts/job_log_check_named.ksh
#  Purpose  : .shk shell script to extract the latest 
#  Usage    :  /opt/bi/code/bin/slim/scripts/job_log_check_named.ksh <job_name> [LOGSUM_ROWS] [PROJECT]
#
#  Modification History :
#  Date         User            Description
#  -------------------------------------------------------------------------------------------
#  02/12/2011   S Osborne       Created
#
#*********************************************************************************************/


DSJOB=${1}
# SEQUENCE=${1}
# DSJOB=`echo ${SEQUENCE} | cut -c5-50`
LOGSUM_ROWS_DEF=30  # default no. of rows to return from the dsjob -logsum command. ${2} overrides 

EMAIL_FLAG=N            # email the output to ${DISTR_LIST} ?

# (above two estimated to give the most recent 1-2 runs. crank these up to give more days )

#default PROJECT name to use is the environment one, else if parameter $3 is supplied use that.
if [[ -z ${3} ]]
then
   PROJECT=${PROJ_DEF}
else
   PROJECT=${3}
fi

#default LOGSUM_ROWS to use 30 entries, else if parameter $2 is supplied use that.
if [[ -z ${2} ]]
then
   LOGSUM_ROWS=${LOGSUM_ROWS_DEF}
else
   LOGSUM_ROWS=${2}
fi
LOGSUM_PRE_ROWS=$(($LOGSUM_ROWS * 7))

#default LOGDIR to use is from environment / .profile, else use a specified path - # out where appropriate.
if [[ -z ${LOGDIR} ]]
then
   LOGDIR=/users/q4wn5gc/scripts/logs # LOGDIR=/tmp
   # LOGDIR=/opt/bi/code/bin/slim/scripts/logs  
   # LOGDIR=/users/sosborne/scripts/logs # LOGDIR=/tmp
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

sleep 2

for JOB in ${DSJOB}
do
   echo ${JOB} ; sleep 2
   LOGFILE=${LOGDIR}/${JOB}.log
   echo LOGFILE=${LOGFILE} | tee  ${LOGFILE} # initiates logfile
   echo ${PROJECT} // ${DSJOB} // LOGSUM_ROWS=${LOGSUM_ROWS} // LOGSUM_PRE_ROWS=${LOGSUM_PRE_ROWS}  # | tee -a  ${LOGFILE} 
   # echo "\n Last ten jobs ######################### \n"             >  ${LOGFILE}
   echo  "\n job being reported here and it's logsum entries: ######################### \n"  >>  ${LOGFILE}
   echo ${JOB} ${PROJECT}       >>  ${LOGFILE}
   LOGSHORT=`basename ${LOGFILE}`
   #for LOGROW in `dsjob -logsum ${PROJECT} ${SEQUENCE} | tail -10 | egrep "BATCH|INFO|STARTED" | cut -d -f1`
   for LOGROW in `dsjob -logsum ${PROJECT} ${JOB} | tail -${LOGSUM_PRE_ROWS} | egrep "BATCH|INFO|STARTED|WARNING|FATAL" | awk '{print $1}' | tail -${LOGSUM_ROWS}`
   do
      echo "\n#######################################\n\n" >>  ${LOGFILE}
      dsjob -logdetail ${PROJECT} ${JOB} ${LOGROW}       2> /dev/null  >> ${LOGFILE}
   done
      echo "\n logsum high level timing-event summary: ######################### \n"  >>  ${LOGFILE}
      dsjob -logsum ${PROJECT} ${JOB} | tail -${LOGSUM_PRE_ROWS} | egrep -n "BATCH|XXINFO|STARTED|WARNING|FATAL" | tail -${LOGSUM_ROWS}       >>  ${LOGFILE}
      dsjob -report ${PROJECT} ${DSJOB}   2> /dev/null >>  ${LOGFILE}
      # dsjob -jobinfo  ${PROJECT} ${DSJOB} 2> /dev/null >>  ${LOGFILE}

      # uuencode ${LOGFILE} ${LOGFILE} | mailx -s "DS job log attached : ${LOGSHORT}" "${DISTR_LIST}"
      cat ${LOGFILE} | egrep -v "Empty string used"
      if [[ ${EMAIL_FLAG} = 'Y' ]] ; then cat ${LOGFILE}  | mailx -s "DS job log attached : ${LOGSHORT}" "${DISTR_LIST}" ; fi
done

echo "\n********* The last ten log files created by this script *********\n"
ls -lrt ${LOGDIR}/?*.log | tail
# ls -lrt `find . -name "*.log" -mtime -2 -print`
cd ${LOGDIR}
echo "\n********* Key info and performance stats summary in the last 1 day of log files *********\n"
egrep -in "STATUS REPORT|start time|elapsed time|has finished|SQL statement|  FROM |   WHERE" `find . -name "*.log" -mtime -1 -print 2>/dev/null` | egrep -v errorIndex 

echo "\n********* Possible ERROR STRINGS in last 1 day of log files *********\n"
egrep -in "critical|abort|terminated|check_process_id|error|permission|Failed|has finished" `find . -name "*.log" -mtime -1 -print 2>/dev/null` | egrep -v errorIndex

# rm -f ${LOGFILE}

exit
   
   # PROJECT=`grep ${SEQUENCE} /opt/bi/code/bin/slim/DSExec/logs/runjob.log | tail -1 | cut -d"=" -f11 | cut -d" " -f2`
   # PROJECT="MRL_VFH0_${ENVIRONMENT}" #  ${PROJ_DEF}


