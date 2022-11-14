#!/bin/bash

APP=$1
KEYWORD=$2

# Parent process log
P_LOG="/root/p.log"

# Child process log or all log
O_LOG="/root/output.log"

CHECK_LOG="/root/checklog.txt"

check_log() {
  local i=1
  local check_p=""
  local check_o=""

  echo "Clean $P_LOG $O_LOG first before test!"
  cat /dev/null > $P_LOG
  cat /dev/null > $O_LOG

  for ((i=1;;i++)); do
    check_p=""
    check_o=""
    echo "===========================" | tee $CHECK_LOG
    echo "The ${i} time test:" | tee $CHECK_LOG

    echo "$APP >$P_LOG >& $O_LOG" | tee $CHECK_LOG
    "$APP" >$P_LOG >& $O_LOG
    check_p=$(cat $P_LOG | grep -i "$KEYWORD")
    check_o=$(cat $O_LOG | grep -i "$KEYWORD")
    [[ -z "$check_p" ]] || {
      echo "Find $KEYWORD in $P_LOG!" | tee $CHECK_LOG
      echo "Please check $CHECK_LOG"
      exit 0
    }

    [[ -z "$check_o" ]] || {
      echo "Find $KEYWORD in $O_LOG!" | tee $CHECK_LOG
      echo "Please check $CHECK_LOG"
      exit 0
    }
    echo "No $KEYWORD find in $i round." | tee $CHECK_LOG
  done
}

check_log
