#!/bin/bash

# This script will load the target CPU to 100% via dd and resume in 5s

CPU_ID=$1
PID_LOAD=""
PID_CAT=""

[[ -z "$CPU_ID" ]] && CPU_ID=1

echo "CPU:$CPU_ID"

echo "taskset -c $CPU_ID dd if=/dev/zero of=/dev/null &"
taskset -c $CPU_ID dd if=/dev/zero of=/dev/null &

# cat: write error: No space left on device for a while, don't use
#taskset -c $CPU_ID cat /dev/urandom > /dev/null 1>/dev/nulli &

LOAD_INFO=$(ps -ef | grep cpu100 | grep sh)

PID_LOAD=$(ps -ef | grep cpu100 | grep sh | awk -F " " '{print $2}')
PID_CAT=$(ps -ef | grep dd | grep if | grep zero | grep of | grep dev | awk -F " " '{print $2}')

echo "LOAD_ALL:$LOAD_INFO"
echo ""
echo "PID_LOAD:$PID_LOAD, PID_CAT:$PID_CAT"

echo "sleep 5"
sleep 5
echo "kill -9 $PID_CAT"
kill -9 "$PID_CAT"
