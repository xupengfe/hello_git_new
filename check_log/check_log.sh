#!/bin/bash

APP=$1
KEYWORD=$2

# Parent process log
P_LOG="/root/p.log"

# Child process log or all log
O_LOG="/root/output.log"

check_log() {
  local i=1
  local check_p=""
  local check_o=""


  for ((i=1;;i++)); do
    check_p=""
    check_o=""
    echo "==========================="
    echo "The ${i} time test:"
    echo "(./"$APP" >$P_LOG) >& $O_LOG"
    (./"$APP" >$P_LOG) >& $O_LOG
    check_p=$(cat $P_LOG | grep -i "$KEYWORD")
    check_o=$(cat $O_LOG | grep -i "$KEYWORD")
    [[ -z "$check_p" ]] && {
      echo "Find $KEYWORD in $P_LOG!"
      exit 0
    }

    [[ -z "$check_o" ]] && {
      echo "Find $KEYWORD in $O_LOG!"
      exit 0
    }
    echo "No $KEYWORD find in $i round."
  done
}

check_log
