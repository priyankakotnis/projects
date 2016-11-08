#!/usr/bin/env bash
tput setf 2
tput bold
SCRIPT_DIR=`dirname $0`
message_size=normal
if [ "$2" == "large" ]; then
message_size=large
fi

case "$1" in
"1")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 10 & 
;;
"2") 
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 100 &
;;
"3") 
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 1024 &
;;
"4") 
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 10240 &
;;
"5") 
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 102400 &
;;
"6") 
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 1048576 &
;;
"7") 
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordcount -r 10485760 &
;;
"8") 
echo "Running option $1";
echo "Aborted!!! Spark configuration needs to be tuned for higher message sizes."
;;
"9") 
echo "Running option $1";
echo "Aborted!!! Spark configuration needs to be tuned for higher message sizes."
;;
"11")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 10 &
;;
"12")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 100 &
;;
"13")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 1024 &
;;
"14")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 10240 &
;;
"15")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 102400 &
;;
"16")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 1048576 &
;;
"17")
echo "Running option $1";
${SCRIPT_DIR}/runSparkJob.sh -o $1 -d $message_size -t wordgrep -r 10485760 &
;;
esac
tput sgr0