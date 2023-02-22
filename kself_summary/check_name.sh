#!/bin/bash

TARGET=$1
ORIGIN=$2

check_name() {
  local target=$1
  local origin=$2
  local name=""
  local names=""
  local check=""

  [[ -z "$target" ]] && {
    echo "No target in parm 1"
    exit 1
  }

  [[ -z "$origin" ]] && {
    echo "No origin in parm 2"
    exit 1
  }

  names=$(cat "$origin" | cut -d ' ' -f 1 | cut -d ':' -f 2)

  for name in $names; do
    check=""
    check=$(cat "$target" | grep ^"$name")
    #echo "check name:$name in $target"
    if [[ -z "$check" ]]; then
      echo "$name in origin:$origin but not exist in $target"
    fi
  done
}

check_name "$TARGET" "$ORIGIN"
