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
${SCRIPT_DIR}/runStormJob.sh $1 10 $message_size wordcount &
;;
"2") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 100 $message_size wordcount &
;;
"3") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 1024 $message_size wordcount &
;;
"4") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 10240 $message_size wordcount &
;;
"5") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 102400 $message_size wordcount &
;;
"6") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 1048576 $message_size wordcount &
;;
"7") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 10485760 $message_size wordcount &
;;
"8") 
echo "Running option $1";
echo "Aborted!!! Storm configuration needs to be tuned for higher message sizes."
;;
"9") 
echo "Running option $1";
echo "Aborted!!! Storm configuration needs to be tuned for higher message sizes."
;;
"11")
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 10 $message_size wordgrep &
;;
"12") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 100 $message_size wordgrep &
;;
"13") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 1024 $message_size wordgrep &
;;
"14") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 10240 $message_size wordgrep &
;;
"15") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 102400 $message_size wordgrep &
;;
"16") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 1048576 $message_size wordgrep &
;;
"17") 
echo "Running option $1";
${SCRIPT_DIR}/runStormJob.sh $1 10485760 $message_size wordgrep &
;;
esac
tput sgr0
