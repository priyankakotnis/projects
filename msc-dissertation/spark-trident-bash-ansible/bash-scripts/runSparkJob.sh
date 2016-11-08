#!/usr/bin/env bash
#This script builds and runs Apache Spark benchmark program as per specified parameters
SCRIPT_DIR=`dirname $0`
EXPERIMENT_LOGS_DIR=${SCRIPT_DIR}/stats/spark_run
mkdir -p ${EXPERIMENT_LOGS_DIR}
echo "started `date +%Y%m%d-%H%M%S`" >> ${EXPERIMENT_LOGS_DIR}/spark_run.log
#Build the code
echo "Installing code..."
CODEBASE_HOME=/home/${USER}/priyanka/projects/programs
cd $CODEBASE_HOME/codebase/spark/spark-streaming-benchmark
mvn clean
sleep 2
mvn  install

setupOption=1
data_rate=10
message_size=normal
workload_type=wordcount
DEPENDENCIES=`ls -fm $CODEBASE_HOME/codebase/common/spark-dependency-jars/* | tr -d '\n'`
DATE=`date +%Y%m%d-%H%M%S`
EX_MEM="spark.executor.memory=1G" 
EX_CPU="spark.executor.cores=4"

echo "Checking for user specified options...."
while getopts ":c:m:o:d:t:r:" opt; do
  case $opt in
    c) EX_CPU="spark.executor.cores=$OPTARG"
    ;;
    m) EX_MEM="spark.executor.memory=$OPTARG"
    ;;
    o) setupOption=$OPTARG
    ;;
    d) message_size=$OPTARG
    ;;
    t) workload_type=$OPTARG
    ;;
    r) data_rate=$OPTARG	
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done
CLASS_NAME=org.apache.spark.examples.streaming.JavaDirectKafkaWordCount
if [ $workload_type == "wordgrep"  ]; then
	CLASS_NAME=org.apache.spark.examples.streaming.JavaDirectKafkaWordGrep
fi


topicName=sparkTopic$setupOption
appName=${message_size}_${workload_type}_${setupOption}
LOGFILE_NAME=spark_run_${appName}_$DATE.txt

#Run the datafeed
echo "Starting the data feed at `date +%Y%m%d-%H%M%S`"
cd $CODEBASE_HOME/benchmark_application

${SCRIPT_DIR}/runDatafeed_Attached.sh $message_size $data_rate $topicName 900 & #Run datafeed for 15 minutes

echo "Spark job will be submitted after 2 minutes..."

sleep 120

MASTER_URL=spark://${HOSTNAME}:7077
APP_JAR=${CODEBASE_HOME}/codebase/spark/spark-streaming-benchmark/target/spark-streaming-benchmark-0.0.1-SNAPSHOT.jar
SPARK_RUN_LOG_DIR=${EXPERIMENT_LOGS_DIR}/${message_size}/${workload_type}/${setupOption}
mkdir -p ${SPARK_RUN_LOG_DIR}
touch ${SPARK_RUN_LOG_DIR}/$LOGFILE_NAME

#Submit Spark Streaming Job
echo "Running Set-up option $setupOption - $message_size - $workload_type - with Executor cores : $EX_CPU and memory : $EX_MEM and topicName is $topicName"
echo "Started=================================================================================" >> ${SPARK_RUN_LOG_DIR}/$LOGFILE_NAME
echo "Adding dependencies $DEPENDENCIES" >> ${SPARK_RUN_LOG_DIR}/$LOGFILE_NAME
echo "Running=================================================================================="
echo "Started $DATE with Executor cores : $EX_CPU and memory : $EX_MEM ======================================" >> ${SPARK_RUN_LOG_DIR}/$LOGFILE_NAME
echo "Running job with broker-->localhost:9092 for Topic--> sparkTopic$setupOption with Kafka Spark receiver max rate-->2000 messages"
echo "If you wish to change these settings please update the script."

$SPARK_HOME/bin/spark-submit --name "${appName}"  --verbose --master ${MASTER_URL} --conf $EX_MEM --conf $EX_CPU --jars $DEPENDENCIES --class $CLASS_NAME ${APP_JAR} localhost:9092 $topicName 2000 >> ${SPARK_RUN_LOG_DIR}/$LOGFILE_NAME 2>&1  &

echo "Spark application ${appName} submitted"

#Start the performance metrics collection
SAR_CPU_LOGFILE_NAME=sar_cpu_log_${appName}_$DATE.txt
SAR_MEMORY_LOGFILE_NAME=sar_mem_log_${appName}_$DATE.txt
sar -u 5 122  >> ${SPARK_RUN_LOG_DIR}/$SAR_CPU_LOGFILE_NAME &
sar -r 5 122  >> ${SPARK_RUN_LOG_DIR}/$SAR_MEMORY_LOGFILE_NAME &
sleep 610

#Capture Spark Web UI metrics' screenshot
imageName=${SPARK_RUN_LOG_DIR}/spark_${appName}_$DATE.png
echo "Taking screenshot of SparkUI file --> $imageName"
$PHANTOMJS_HOME/bin/phantomjs captureSparkUI.js $imageName
#echo "Copying image to ${SPARK_RUN_LOG_DIR}..."
#cp $imageName ${SPARK_RUN_LOG_DIR}/
sleep 2

echo "Finished......Please kill the job from Spark UI if it is running before proceeding to next run..."
echo "Finished `date +%Y%m%d-%H%M%S`" >> ${EXPERIMENT_LOGS_DIR}/spark_run.log
#Additional code below to upload the results on Google Cloud Storage
#Upload the results to Google Cloud Storage
#echo "Uploading the results to Google Cloud bucket..."
#echo "Copy command - gsutil cp -r ${SPARK_RUN_LOG_DIR} gs://resonant-amulet-142021.appspot.com/${DATE}"
#gsutil cp ${SPARK_RUN_LOG_DIR}/*.* gs://resonant-amulet-142021.appspot.com/${DATE}
echo "Checking if Datafeed is finished.."

ps -ef | grep runDatafeed | grep -v grep

echo "Let it finish or kill it before continuing with next run.."
echo "Done..!"