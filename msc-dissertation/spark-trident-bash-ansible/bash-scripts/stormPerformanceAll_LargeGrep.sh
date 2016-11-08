#!/usr/bin/env bash
tput setf 2
tput bold

#STATUS_FILE=gs://resonant-amulet-142021.appspot.com/
SCRIPT_DIR=`dirname $0`
SET_UP=LargeGrep
LOG_FILE=storm_test_status.txt
touch ${LOG_FILE}

runTest() {
  echo "Started run $1 $2 -  `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
  ${SCRIPT_DIR}/stormExperiment.sh $1 $2 &
  sleep 2100
  echo "Finished run $1 $2 -  `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
  #gsutil cp ${LOG_FILE} $STATUS_FILE
}

cleanStartKafka() {
  echo "Restarting Kafka" >> ${LOG_FILE}
  ${SCRIPT_DIR}/server_admin_utilities/shutdownKafka.sh
  sleep 5
  ${SCRIPT_DIR}/server_admin_utilities/startKafka.sh &
  sleep 15
  ${SCRIPT_DIR}/kafka_utilities/createKafkaTopic.sh storm
  echo "Restarts done...resuming" >> ${LOG_FILE}
  echo "Free memory `free -m`" >> ${LOG_FILE}
  #gsutil cp ${LOG_FILE} $STATUS_FILE
}

echo "Please note this will take approximately 1.5-3 hours."
echo "You may check the status of experimentperiodically in status file ${LOG_FILE} or Storm Web UI."
echo "===================================================================================" >> ${LOG_FILE}
echo "Started running StormExperiment Set-up $SET_UP - at `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
#gsutil cp ${LOG_FILE} $STATUS_FILE
runTest 13 large
runTest 14 large
runTest 15 large
cleanStartKafka
runTest 16 large
cleanStartKafka
runTest 17 large
echo "Finished running StormExperiment Set-up $SET_UP - at `date +%Y%m%d-%H%M%S`" >> ${LOG_FILE}
echo "===================================================================================" >> ${LOG_FILE}
#gsutil cp ${LOG_FILE} $STATUS_FILE
tput sgr0