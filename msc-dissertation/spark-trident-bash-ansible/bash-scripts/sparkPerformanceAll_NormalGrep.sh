#!/usr/bin/env bash
tput setf 2
tput bold

#STATUS_FILE=gs://resonant-amulet-142021.appspot.com/
SCRIPT_DIR=`dirname $0`
SET_UP=NormalGrep
LOG_FILE=spark_test_status.txt
touch ${LOG_FILE}

runTest() {
  echo "Started run $1 $2 -  `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
  ${SCRIPT_DIR}/sparkExperiment.sh $1 $2 &
  sleep 1500
  echo "Finished run $1 $2 -  `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
  #gsutil cp ${LOG_FILE} $STATUS_FILE
}

cleanStartKafka() {
  echo "Restarting Kafka" >> ${LOG_FILE}
  ${SCRIPT_DIR}/server_admin_utilities/shutdownKafka.sh
  sleep 5
  ${SCRIPT_DIR}/server_admin_utilities/startKafka.sh &
  sleep 15
  ${SCRIPT_DIR}/kafka_utilities/createKafkaTopic.sh spark
  echo "Restarts done...resuming" >> ${LOG_FILE}
  echo "Free memory `free -m`" >> ${LOG_FILE}
  #gsutil cp ${LOG_FILE} $STATUS_FILE
}

echo "Please note this will take approximately 1.5-3 hours."
echo "You may check the status of experiment periodically in status file ${LOG_FILE} or Spark Web UI."
echo "===================================================================================" >> ${LOG_FILE}
echo "Started running SparkExperiment Set-up $SET_UP - at `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
#gsutil cp ${LOG_FILE} $STATUS_FILE
runTest 11 normal
runTest 12 normal
runTest 13 normal
runTest 14 normal
runTest 15 normal
cleanStartKafka
runTest 16 normal
runTest 17 normal
echo "Finished running SparkExperiment Set-up $SET_UP - at `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
echo "===================================================================================" >> ${LOG_FILE}
#gsutil cp ${LOG_FILE} $STATUS_FILE
tput sgr0