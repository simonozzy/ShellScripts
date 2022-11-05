#!/bin/ksh
#/*********************************************************************************************
#  Name     : /opt/bi/code/bin/slim/scripts/job_log_check_latest.ksh
#  Purpose  : .shk shell script to extract the latest
#  Usage    :  /opt/bi/code/bin/slim/scripts/job_log_check_latest.ksh
#
#  Modification History :
#  Date         User            Description
#  -------------------------------------------------------------------------------------------
#  02/12/2011   S Osborne       Created
#
#*********************************************************************************************/

DISTR_LIST='simon.osborne@rbccm.com'

#default SEQUENCE name to use is most recently run one, else if parameter $1 is supplied use that.
if [[ -z ${1} ]]
then
   SEQUENCE=`tail -30 /opt/bi/code/bin/slim/DSExec/logs/runjob.log | grep -i "seq_" | tail -1 | cut -d"=" -f11 | cut -d" " -f3`
else
   SEQUENCE=${1}
fi

DSJOB=`echo ${SEQUENCE} | cut -c5-50`

PROJECT=`grep ${SEQUENCE} /opt/bi/code/bin/slim/DSExec/logs/runjob.log | tail -1 | cut -d"=" -f11 | cut -d" " -f2`
JOBTIME=`grep ${SEQUENCE} /opt/bi/code/bin/slim/DSExec/logs/runjob.log | tail -1 | cut -d" " -f2,3 | sed -e 's/ /_/g'`

echo ${PROJECT} ${SEQUENCE} ${DSJOB} ${JOBTIME}

sleep 3

for JOB in ${SEQUENCE} ${DSJOB}
do
   echo ${JOB} ; sleep 3
   LOGFILE=/opt/bi/code/bin/slim/scripts/logs/${JOB}.log
   echo  "\n Last ten jobs ######################### \n"             >  ${LOGFILE}
   tail -50 /opt/bi/code/bin/slim/DSExec/logs/runjob.log | grep -i "seq_" | tail -10 | cut -d" " -f2,3,30,31 >> ${LOGFILE}
   echo  "\n job being reported here: ######################### \n"  >>  ${LOGFILE}
   echo ${JOBTIME} ${JOB} ${PROJECT}       >>  ${LOGFILE}
   LOGSHORT=`basename ${LOGFILE}`
   #for LOGROW in `dsjob -logsum ${PROJECT} ${SEQUENCE} | tail -10 | egrep "BATCH|INFO|STARTED" | cut -d -f1`
   for LOGROW in `dsjob -logsum ${PROJECT} ${JOB} | tail -40 | egrep "BATCH|INFO|STARTED|WARNING|FATAL" | cut -c1-3`
   do
      echo  "\n#######################################\n\n" >>  ${LOGFILE}
      dsjob -logdetail ${PROJECT} ${JOB} ${LOGROW}          >> ${LOGFILE}
   done
      # uuencode ${LOGFILE} ${LOGFILE} | mailx -s "DS job log attached : ${LOGSHORT}" "${DISTR_LIST}"
      cat ${LOGFILE} # | mailx -s "DS job log attached : ${LOGSHORT}" "${DISTR_LIST}"
      # cat ${LOGFILE}  | mailx -s "DS job log attached : ${LOGSHORT}" "${DISTR_LIST}"
done

ls -lrt /opt/bi/code/bin/slim/scripts/logs/?*.log | tail
