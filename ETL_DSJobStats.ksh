#  Script ETL_DSJobStats.ksh is located in /opt/etl/code/bin/common
#
#  ${DataStageProject} ${DataStageMain}
#
DSPATH=/ibm/InformationServer/Server/DSEngine
 $DSPATH/dsenv;
PATH=/ibm/InformationServer/Server/DSEngine/bin:$PATH;

DataStageProject=$1
DataStageMain=$2

DSRootDir=/data/etl/NAS/ZAS0/AUDIT/in

DSJobID=`date +"%Y%m%d%H%M%S%s"`
DSJobAuditDate=`date +"%Y%m%d"`


#  create directory

cd $DSRootDir

umask 002

mkdir $DSJobAuditDate  > /dev/null 2>&1

cd $DSJobAuditDate

mkdir $DataStageProject > /dev/null 2>&1

cd $DataStageProject

mkdir Audit.$DataStageMain.$DSJobID  > /dev/null 2>&1


# change to directory

cd Audit.$DataStageMain.$DSJobID

echo "saving info to "
pwd

#
echo "dsjob -logdetail $DataStageProject $DataStageMain > log_detail_j1.txt"
dsjob -logdetail $DataStageProject $DataStageMain > log_detail_j1.txt
dsjob -report $DataStageProject $DataStageMain DETAIL >> log_detail_j1.txt



egrep "finished" log_detail_j1.txt  | grep "status=1" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq.lst
egrep "finished" log_detail_j1.txt  | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq.lst
egrep "finished" log_detail_j1.txt  | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq.lst


egrep "finished" log_detail_j1.txt  | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst
egrep "finished" log_detail_j1.txt  | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst

Nextl2=`wc -l sub_seq.lst | sed 's/sub_seq.lst//g' | sed 's/ //g'`

if [[ ! $Nextl2 = 0 ]]
 then 

	echo "level2="
	echo $Nextl2

	for iItem in `cat sub_seq.lst | sort | uniq` ; do
	echo $iItem
	dsjob -logdetail $DataStageProject $iItem >> log_detail_l2.txt
	dsjob -report $DataStageProject $iItem DETAIL >> log_detail_l2.txt
	done


	egrep "finished" log_detail_l2.txt | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst
	egrep "finished" log_detail_l2.txt | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst

	egrep "finished" log_detail_l2.txt  | grep "status=1" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l2.lst
	egrep "finished" log_detail_l2.txt  | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l2.lst
	egrep "finished" log_detail_l2.txt  | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l2.lst


	Nextl3=`wc -l sub_seq_l2.lst | sed 's/sub_seq_l2.lst//g' | sed 's/ //g'`
	echo $Nextl3
	  if [[ ! "$Nextl3" = "0" ]]; then
		echo "Next Level required will be created!"

		for iItem in `cat sub_seq_l2.lst | sort | uniq` ; do
			echo $iItem
			dsjob -logdetail $DataStageProject $iItem >> log_detail_l3.txt
			dsjob -report $DataStageProject $iItem DETAIL >> log_detail_l3.txt
		done


		egrep "finished" log_detail_l3.txt | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst
		egrep "finished" log_detail_l3.txt | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst

		egrep "finished" log_detail_l3.txt  | grep "status=1" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l3.lst
		egrep "finished" log_detail_l3.txt  | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l3.lst
		egrep "finished" log_detail_l3.txt  | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l3.lst


		Nextl4=`wc -l sub_seq_l3.lst | sed 's/sub_seq_l3.lst//g' | sed 's/ //g'`
		echo $Nextl4
		if [[ ! "$Nextl4" = "0" ]]; then
			echo "Next Level required will be created!"

			for iItem in `cat sub_seq_l3.lst | sort | uniq` ; do
				echo $iItem
				dsjob -logdetail $DataStageProject $iItem >> log_detail_l4.txt
				dsjob -report $DataStageProject $iItem DETAIL >> log_detail_l4.txt
			done

			egrep "finished" log_detail_l4.txt | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst
			egrep "finished" log_detail_l4.txt | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst

			egrep "finished" log_detail_l4.txt  | grep "status=1" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l4.lst
			egrep "finished" log_detail_l4.txt  | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l4.lst
			egrep "finished" log_detail_l4.txt  | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l4.lst

			Nextl5=`wc -l sub_seq_l4.lst | sed 's/sub_seq_l4.lst//g' | sed 's/ //g'`
			echo $Nextl5
			if [[ ! "$Nextl5" = "0" ]]; then
				echo "Next Level required will be created!"

				for iItem in `cat sub_seq_l4.lst | sort | uniq` ; do
					echo $iItem
					dsjob -logdetail $DataStageProject $iItem >> log_detail_l5.txt
					dsjob -report $DataStageProject $iItem DETAIL >> log_detail_l5.txt
				done

				egrep "finished" log_detail_l5.txt | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst
				egrep "finished" log_detail_l5.txt | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'    >> warnings_errors.lst

				egrep "finished" log_detail_l5.txt  | grep "status=1" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l5.lst
				egrep "finished" log_detail_l5.txt  | grep "status=2" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l5.lst
				egrep "finished" log_detail_l5.txt  | grep "status=3" | cut -d ' ' -f4 | sed 's/)//g'   >> sub_seq_l5.lst

				Nextl6=`wc -l sub_seq_l5.lst | sed 's/sub_seq_l5.lst//g' | sed 's/ //g'`
				echo $Nextl6
				if [[ ! "$Nextl6" = "0" ]]; then
					echo "Next Level required will be created!"
							echo "XXXXXXXXXXXXXXXXXXXXX Script needs adjustment max levels exceeded!"

				fi
			fi

		fi
	fi
fi



#  gather errors and warnings

Nextwe=`wc -l warnings_errors.lst | sed 's/warnings_errors.lst//g' | sed 's/ //g'`
echo "errors and warnings =" 
echo $Nextwe
if [[ ! "$Nextwe" = "0" ]]; then

for iItem in `cat warnings_errors.lst` ; do
  echo $iItem
  dsjob -logdetail $DataStageProject $iItem >> log_errors_warnings.txt
done

fi

touch stats.done

echo "completed ETL_DSJobStats.ksh"
