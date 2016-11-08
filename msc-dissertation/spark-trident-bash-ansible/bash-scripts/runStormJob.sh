#!/usr/bin/env bash

SCRIPT_DIR=`dirname $0`
EXPERIMENT_LOGS_DIR=${SCRIPT_DIR}/stats/storm_run
mkdir -p ${EXPERIMENT_LOGS_DIR}

DATE=`date +%Y%m%d-%H%M%S`

echo "started `date +%Y%m%d-%H%M%S`" >> ${EXPERIMENT_LOGS_DIR}/storm_run.log
echo "Received parameters : $1 $2 $3 $4......" >> ${EXPERIMENT_LOGS_DIR}/storm_run.log

#Build the code
echo "Installing code..."
CODEBASE_HOME=/home/${USER}/priyanka/projects/programs
cd $CODEBASE_HOME/codebase/storm/storm-trident-benchmark
mvn clean
sleep 2
mvn  install
sleep 5

setupOption=$1
rate=$2
topicName=stormTopic${setupOption}
#Set fetch size approx equal to data rate to increase throughput
fetchSize=$rate
#fetchSize=1048576

message_size=normal

if [ "$3" == "large" ]; then
  message_size=large
fi

workload_type=wordcount

if [ "$4" == "wordgrep" ]; then
  workload_type=wordgrep
fi

TOPOLOGY_NAME=${message_size}_${workload_type}_${setupOption}

#Run the datafeed
echo "Starting the data feed..."
cd $CODEBASE_HOME/benchmark_application

${SCRIPT_DIR}/runDatafeed_Attached.sh $message_size $rate $topicName 1500 & #Run datafeed for 25 minutes

echo "Storm job will be submitted after 5 minutes..."
sleep 300


LOG_DIR=${EXPERIMENT_LOGS_DIR}/${message_size}/${workload_type}/${setupOption}
LOGFILE_NAME=storm_log_${TOPOLOGY_NAME}_$DATE.txt


CLASS_NAME=TridentKafkaWordCount

if [ "${workload_type}" == "wordgrep" ];
then
  CLASS_NAME=TridentKafkaGrep
fi

PROGRAM_NAME=org.apache.storm.starter.trident.$CLASS_NAME

mkdir -p ${LOG_DIR}
touch ${LOG_DIR}/$LOGFILE_NAME

APP_JAR=${CODEBASE_HOME}/codebase/storm/storm-trident-benchmark/target/storm-trident-benchmark-0.0.1-SNAPSHOT-jar-with-dependencies.jar

echo "Submitting Storm job..."
echo "Started=================================================================================" >> ${LOG_DIR}/$LOGFILE_NAME
echo "Running==================================================================================" >> ${LOG_DIR}/$LOGFILE_NAME
echo "Started at $DATE ======================================" >> ${LOG_DIR}/$LOGFILE_NAME
echo "Parameters : Kafka consumer fetch.size=$rate running topology with name: $TOPOLOGY_NAME for topic : $topicName" >> ${LOG_DIR}/$LOGFILE_NAME

storm jar $APP_JAR $PROGRAM_NAME localhost:2181 localhost:9092 $TOPOLOGY_NAME $fetchSize $topicName >> ${LOG_DIR}/$LOGFILE_NAME &

echo "Job Submitted : $TOPOLOGY_NAME ==> `date +%Y%m%d-%H%M%S`" >> ${LOG_DIR}/$LOGFILE_NAME
echo "Capturing Storm UI 15 minutes after `date +%Y%m%d-%H%M%S`"
echo "Starting CPU stats in 4 minutes 50 seconds...after `date +%Y%m%d-%H%M%S`"

SAR_CPU_LOGFILE_NAME=sar_cpu_log_${TOPOLOGY_NAME}_$DATE.txt
SAR_MEMORY_LOGFILE_NAME=sar_memory_${TOPOLOGY_NAME}_$DATE.txt

sleep 290

echo "Starting sar with log $SAR_CPU_LOGFILE_NAME $SAR_MEMORY_LOGFILE_NAME in ${LOG_DIR} "

sar -u 5 120 >> ${LOG_DIR}/$SAR_CPU_LOGFILE_NAME & 
sar -r 5 120 >> ${LOG_DIR}/$SAR_MEMORY_LOGFILE_NAME &

stormDist=$CODEBASE_HOME/storm/data/supervisor/stormdist

sleep 630 #We give Storm Topology 5 minutes warm up and capture after 15 minutes

topologyId=`ls -ltr $stormDist | awk '{print $9}' | tr -d '\n'`
topologyNameStorm=`echo $topologyId | cut -d- -f1-2`

echo "Found Topology ID : $topologyId and Name: $topologyNameStorm" >> ${LOG_DIR}/$LOGFILE_NAME

url=http://localhost:8080/topology.html?id=${topologyId}

echo "Capturing URL $url now..."

imageName=${LOG_DIR}/storm_run_${TOPOLOGY_NAME}_$DATE.png

echo "Taking screenshot of Storm UI Topology stats at $url to file --> $imageName"

$PHANTOMJS_HOME/bin/phantomjs captureStormUI.js $url $imageName

#echo "Copying image to ${LOG_DIR}..."
#cp $imageName ./${LOG_DIR}/

sleep 2

echo "Finished $TOPOLOGY_NAME ==> `date +%Y%m%d-%H%M%S`"  >> ${LOG_DIR}/$LOGFILE_NAME
echo "========================================================================="  >> ${EXPERIMENT_LOGS_DIR}/storm_run.log
echo "Killing the Topology using storm kill $topologyNameStorm -w 5....."

sleep 5

storm kill $topologyNameStorm -w 5

echo "Checking if Datafeed is finished.."

ps -ef | grep runDatafeed | grep -v grep

echo "Let it finish or kill it before continuing with next run.."
echo "Finished `date +%Y%m%d-%H%M%S`" >> ${EXPERIMENT_LOGS_DIR}/storm_run.log
