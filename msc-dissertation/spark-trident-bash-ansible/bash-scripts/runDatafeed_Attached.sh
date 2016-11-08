#!/usr/bin/env bash
#This script is used to simulate a real-time data stream for experimental study
#This script generates data with fixed data rate and sends it to Apache Kafka producer
SCRIPT_DIR=`dirname $0`
DATA_FILE=${SCRIPT_DIR}/datafiles/normal_input.txt
if [ "$1" == "large" ];
then DATA_FILE=${SCRIPT_DIR}/datafiles/large_input.txt
fi
echo "================================================================================================" >> ${SCRIPT_DIR}/stats/datafeed_logs.txt

dataFeedDuration=$4 #Run datafeed for these many seconds

echo "Running Datafeed setUp - $1 rate = $2 and topic $3 at $(date +%Y%m%d-%H%M%S) for $dataFeedDuration seconds"

endTime=$(( $(date +%s) + dataFeedDuration )) # Calculate end time

echo "Running Datafeed setUp - $1 rate = $2 and topic $3 at $(date +%Y%m%d-%H%M%S) ETF is after $dataFeedDuration seconds" >> ${SCRIPT_DIR}/stats/datafeed_logs.txt

while [ $(date +%s) -lt $endTime ];
do
        tail -c $2 $DATA_FILE | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic $3 --producer.config $KAFKA_HOME/config/producer.properties &
        sleep 0.5
done

echo "Finished running Datafeed setUp - $1 rate = $2 and topic $3 at $(date +%Y%m%d-%H%M%S)" >> ${SCRIPT_DIR}/stats/datafeed_logs.txt

echo "================================================================================================" >> ${SCRIPT_DIR}/stats/datafeed_logs.txt

