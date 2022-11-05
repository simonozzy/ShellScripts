#!/bin/ksh
# Script Name      : ETL_DSJobExe.ksh
# Description      : A generic script to execute a DataStage job. This script can be used for
#                    calling any DataStage job such as source to landing or landing to 
#                    stageing table job.
#                    This is done by passing the name of DataStage main job. Other common 
#                    required values such as 'work directory' or DataStage project is retrieved 
#                    from the ini file.
#
# Parameters       : <Location of ReadINI.pl and ETL.ini> <INI Section Name> <DataStage main sequence or job> [DataStage parameters string]
#
# Syntax Examples  : ETL_DSJobExe.ksh /opt/etl/code/bin/common RSS seq_RSS_LND_Load_FX_Rates 
#                    ETL_DSJobExe.ksh /opt/etl/code/bin/common RSS seq_RSS_GERD_All '-param LOAD_HISTORY=Y -param HISTORY_FROM_DATE=20110101 -param HISTORY_TO_DATE=20110201'
#                    ETL_DSJobExe.ksh /opt/etl/code/bin/common RSS seq_RSS_GERD_All '-param LOAD_HISTORY=Y -param HISTORY_FROM_DATE=20110101 -param HISTORY_TO_DATE=20110201' Reset
#
#
# Exit Codes       : 0 - Success
#                    Non zero on failure. A unique exit code has been used for each situation.
#
# Notes            : 1. The account that runs this script should have access to the location of ReadINI.pl and ETL.ini
#                    2. This scripts needs following entries in ETL.ini file under the section 
#                       that is passed as parameter:
#                       LogDir, WorkDir and DataStageProject 
#
# --------------------------------------------------------------------------------------------
# History
#
# Author           Date         Description
# Babak Fateh      2011-06-09   Initial release
# Babak Fateh      2011-11-21   Removing './' when calling ReadINI.pl and ETL.ini and adding
#                               the path as run-time parameter ($1)
# Joe Marchese     2012-10-15   Added logic to run the DSJobStats shell sript.  This script 
#                               captures job run time statistics.  Part of the Audit Standard.
# Joe Marchese     2012-10-30   Added logic to check for job reset.  If required, the script  
#                               resets the job, otherwise, it runs the job.  Also, changed the 
#                               ResettingJob routine name to CheckForResetJob.  Currently, the
#                               CheckForResetJob function is not called, as all DS jobs should
#                               have the reset option set in the sequence.  I.e.  all jobs are
#                               restartable at the point of failure.                          
# --------------------------------------------------------------------------------------------
DisplaySyntax()
{
    echo "Syntax: ${PROGRAM} <Location of ReadINI.pl and ETL.ini> <INI Section Name> <DataStage main sequence or job> [DataStage parameters string]"
}

CleanUp()
{
    rm -f ${TmpFile}
}

DispErrMsg()
{
    typeset RV DSJob

    RV=$1
    DSJob=$2

    echo "`${Time}` Error while executing [${DSJob}]! Return value: [${RV}]" >> $LogFile
}


DispDSOutput()
{
    typeset Title
    Title=$1

    echo "--------------------[${Title}]-------------------" >> $LogFile
    cat $TmpFile >> $LogFile
    echo "--------------------------------------------------------------" >> $LogFile
}

StopJob()
{
    typeset DSJob

    echo "\n`${Time}` Stopping the job if it is running ..." >> $LogFile

    DSJob="dsjob -jobinfo ${DataStageProject} ${DataStageMain}"

    ${DSJob} > $TmpFile 2>&1 
    RV=$?

    DispDSOutput "dsjob -jobinfo output"

    if [[ $RV -ne 0 ]]
    then
        DispErrMsg ${RV} ${DSJob}
        exit 9
    fi

    grep "Job Status" ${TmpFile} | grep -q 'RUNNING'
    RV=$?

    if [[ $RV -eq 0 ]]
    then
        echo "`${Time}` Stopping the job ..." >> $LogFile

        DSJob="dsjob -stop ${DataStageProject} ${DataStageMain}"

        ${DSJob} > $TmpFile 2>&1
        RV=$?

        if  [[ $RV -ne 0 ]]
        then
            DispErrMsg ${RV} ${DSJob}
            exit 10
        fi
    elif [[ $RV -eq 1 ]]
    then
        echo "`${Time}` Stopping is not required." >> $LogFile
    else
        echo "`${Time}` Error in 'grep'! Return value: [${RV}]" >> $LogFile
        exit 11
    fi
}

TrapRoutine()
{
    echo ""                                                                       >> $LogFile
    echo "===================================================================="   >> $LogFile
    echo "`${Time}` ${PROGRAM}: *** RECEIVED AN INTERRUPT. ***"                   >> $LogFile

    StopJob
    CleanUp

    echo "\n`${Time}` ${PROGRAM}: Quitting the process ..."                       >> $LogFile
    echo "===================================================================="   >> $LogFile
    exit 12
}

ForceResetJob()
{
    echo "ForceResetJob"

    typeset DSJob

    echo "`${Time}` Force Reset Job ..." >> $LogFile

    DSJob="dsjob -jobinfo ${DataStageProject} ${DataStageMain}"

    ${DSJob} > $TmpFile 2>&1 
    RV=$?

    echo "`${Time}` Resetting the status of the job ..." >> $LogFile

    DSJob="dsjob -run -wait -mode RESET  ${DataStageProject} ${DataStageMain}"

    ${DSJob} > $TmpFile 2>&1
    RV=$?

    if  [[ $RV -ne 0 ]]
    then
        DispErrMsg ${RV} ${DSJob}
        exit 14
    fi
}

CheckForResetJob()
{
    echo "CheckForResetJob"

    typeset DSJob

    echo "`${Time}` Checking if resetting is needed ..." >> $LogFile

    DSJob="dsjob -jobinfo ${DataStageProject} ${DataStageMain}"

    ${DSJob} > $TmpFile 2>&1 
    RV=$?

    DispDSOutput "dsjob -jobinfo output"

    if [[ $RV -ne 0 ]]
    then
        DispErrMsg ${RV} ${DSJob}
        exit 13
    fi

    grep -Eq "RUN FAILED \(3\)|STOPPED \(97\)" ${TmpFile}
    RV=$?

    if [[ $RV -eq 0 ]]
    then
        echo "`${Time}` Resetting the status of the job ..." >> $LogFile

        DSJob="dsjob -run -wait -mode RESET  ${DataStageProject} ${DataStageMain}"

        ${DSJob} > $TmpFile 2>&1
        RV=$?

        if  [[ $RV -ne 0 ]]
        then
            DispErrMsg ${RV} ${DSJob}
            exit 14
        fi
    elif [[ $RV -eq 1 ]]
    then
        echo "`${Time}` Resetting status of [${DataStageMain}] is not required." >> $LogFile
    else
        echo "`${Time}` Error in 'grep'! Return value: [${RV}]" >> $LogFile
        exit 15
    fi
}

ExecutingJob()
{
    echo "ExecutingJob"

    typeset DSJob

    echo "\n`${Time}` Running the DataStage job ..." >> $LogFile
    DSJob="dsjob -run -wait -jobstatus ${DSParams} ${DataStageProject} ${DataStageMain}"

    echo "`${Time}` Executing [${DSJob}] ..." >> $LogFile
    eval ${DSJob} > $TmpFile 2>&1
    RV=$?
 
    nohup ETL_DSJobStats.ksh ${DataStageProject} ${DataStageMain} & 

    if  [[ $RV -lt 3 ]]
    then
        echo "`${Time}` The DataStage job finished. Return value: [${RV}]" >> $LogFile
    else
        DispErrMsg ${RV} ${DSJob}
        DispDSOutput "dsjob -run output"
        exit 16
    fi
}

# -------------------------------------------------------------------------------------------------
# Program starts from here ...
#

# Setting the required variables:
PROGRAM=`basename $0`
LogTime="date +%Y-%m-%d@%H:%M:%S"
Time="date +%H:%M:%S"
DATE=`date +"%Y%m%d%H%M%S"`

if [[ $# -ne 3 && $# -ne 4 && $# -ne 5 ]]
then
   echo "$PROGRAM: Wrong number of parameters" 
   DisplaySyntax
   exit 1
fi

echo $1
echo $2
echo $3
echo $4
echo $5

INIPath=$1
INISection=$2
DataStageMain=$3
ForceReset=0

if [[ ! -z $4 ]]
then
    if [[ $4 == "Reset" ]]
       then 
           ForceReset=1
    else
        DSParams=$4
    fi
else
   DSParams=""
fi

if [[ ! -z $5 ]]
then
   if [[ $5 == "Reset" ]]
   then 
       ForceReset=1
   fi
fi
   
if [[ ! -x ${INIPath}/ReadINI.pl ]]
then
    echo "`${Time}` [${INIPath}/ReadINI.pl] does not exist or does not have execution permission!" 
    exit 2
fi

if [[ ! -f ${INIPath}/ETL.ini ]]
then
    echo "`${Time}` [${INIPath}/ETL.ini] does not exist!"
    exit 3
fi
 
GetIniEntry="${INIPath}/ReadINI.pl ${INIPath}/ETL.ini ${INISection} "


LogDir=`${GetIniEntry} LogDir`

if [[ -z ${LogDir} ]]
then
    echo "`${Time}` Can not get ini entry 'LogDir' in section '${INISection}'"
    exit 4
fi

if [[ ! -d ${LogDir} ]]
then
    echo "`${Time}` No such directory: [${LogDir}]!"
    exit 5
fi

LogFile=${LogDir}/${PROGRAM%%.*}_${DataStageMain}_${DATE}.log
echo "${PROGRAM}: Started `$LogTime`" > $LogFile


WorkDir=`${GetIniEntry} WorkDir`

if [[ -z ${WorkDir} ]]
then
    echo "`${Time}` Can not get ini entry 'WorkDir' in section '${INISection}'" >> $LogFile
    exit 6
fi

if [[ ! -d ${WorkDir} ]]
then
    echo "`${Time}` No such directory: [${WorkDir}]!"
    exit 7
fi

TmpFile=${WorkDir}/${PROGRAM%%.*}_$$.tmp

set -u

echo ""                                          >> $LogFile
echo "INI entries and passed arguments:"         >> $LogFile
echo "DataStage main job name         : ${DataStageMain}" >> $LogFile
if [[ ! -z ${DSParams} ]]
then
echo "Passed parameters to DataStage  : [${DSParams}]"  >> $LogFile
fi
echo "INI section                     : ${INISection}"    >> $LogFile
echo "Log directory                   : ${LogDir}"        >> $LogFile
echo "Work directory                  : ${WorkDir}"       >> $LogFile
echo ""                                          >> $LogFile

DataStageProject=`${GetIniEntry} DataStageProject`

if [[ -z ${DataStageProject} ]]
then
    echo "\n`${Time}` Can not get ini entry 'DataStageProject' in section '${INISection}'" >> $LogFile
    exit 8
fi

echo "DataStage project name : ${DataStageProject}\n" >> $LogFile

trap TrapRoutine INT QUIT TERM

if [[ ${ForceReset} -eq 1 ]]
then
   ForceResetJob
else 
    CheckForResetJob
fi

ExecutingJob
CleanUp

echo "\n${PROGRAM}: Finished `$LogTime`" >> $LogFile
exit 0
