#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# It's for kself-test output log summary.

readonly SUMMARY="summary"
readonly RESULT="results"
readonly FEATURE="features"
readonly CASE="cases"
readonly COMMENT="comments"
readonly SUMMARY_CSV="kselftest_summary.csv"

KSELF_LOG=$1
KSELF_LIST=$2

usage() {
  cat <<__EOF
  usage: ./${0##*/} kselftest_output.log kselftest-list.txt[optional]
  kselftest_output.log: kselftest output log file
  kselftest-list.txt: kselftest cases list file
  -h  show This
__EOF
  exit 1
}

check_case_num() {
  local log_cases_num=""
  local list_cases_num=""

  [[ -n "$KSELF_LOG" ]] || usage
  [[ -e "$KSELF_LOG" ]] || usage
  if [[ -e "$KSELF_LIST" ]]; then
    # Remove "Binary file (standard input) matches"
    log_cases_num=$(cat "$KSELF_LOG" \
                  | grep "ok" \
                  | grep -v "^#" \
                  | grep -v "Binary" \
                  | wc -l)
    list_cases_num=$(cat "$KSELF_LIST" | grep ":" | wc -l)
  else
    echo "[WARN] No  kselftest-list.txt file, will not check cases num."
    return 0
  fi

  if [[ "$log_cases_num" -eq "$list_cases_num" ]]; then
    echo "Num of log cases:$log_cases_num is same as list_cases:$list_cases_num"
  else
    echo "Num of log cases:$log_cases_num is not same list_num:$list_cases_num"
    exit 1
  fi
}

summarize_kself_log() {
  local results=""
  local result=""
  local feature=""
  local case=""
  local ca=""
  local comment=""
  local num=""
  local max_num=""
  local line=""

  cat "$KSELF_LOG" | grep "ok" | grep -v "^#" | grep -v "Binary" > "$SUMMARY"
  cat "$SUMMARY" | awk -F " selftests:" '{print $1}' > $RESULT
  cat "$SUMMARY" | awk -F ": " '{print $2}' > $FEATURE
  cat "$SUMMARY" | awk -F ": " '{print $3}' | cut -d '#' -f 1 > $CASE
  cat "$SUMMARY" | awk -F ": " '{print $3}' | awk -F "#" '{print $2}' > $COMMENT
  echo "kselftest-list,result,feature,case,comments" > $SUMMARY_CSV

  max_num=$(cat $RESULT | wc -l)
  for ((num=1; num<=max_num; num++)); do
    line=""
    results=""
    result=""
    feature=""
    case=""
    ca=""
    comment=""
    results=$(sed -n "${num}p" $RESULT)
    result=$(echo ${results% *})
    feature=$(sed -n "${num}p" $FEATURE)
    case=$(sed -n "${num}p" $CASE)
    ca=$(echo "$case" | sed 's/[ \t]*$//g')
    comment=$(sed -n "${num}p" $COMMENT)

    line="${feature}:${ca},${result},${feature},${ca},${comment}"
    echo "$line" >> "$SUMMARY_CSV"
  done

  echo "$SUMMARY_CSV is done."
}

check_case_num
summarize_kself_log
