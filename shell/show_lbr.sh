#!/bin/bash

LBR_FILE=$1
KDUMP=$2
SYSMAP=$3

OUTPUT="./result.txt"
ENDBR64="endbr64"
FUNC_ENTRY_INS=""
FUNC_ENTRY_INS_NAME=""
FUNC_NAME=""

usage() {
  echo "Usage: $0 <lbr-file> <kdump> <sysmap>"
  exit 1
}

find_endbr_ins() {
  local src=$1
  local kdump=$2
  local func_entry=""
  local endbr_entry=""
  local spec_func_entry=""
  local check_endbr=""

  func_entry=$(grep -B 1000 ^"$src" "$kdump" | grep -v "nopl" | grep -A1 nop | tail -n1)
  endbr_entry=$(grep -B 200 ^"$src" "$kdump" | grep "endbr64" | tail -n1)
  spec_func_entry=$(grep -B 1200 ^"$src" "$kdump" | grep -A1 "<" | tail -n1)
  [[ -z  "$func_entry" && -z "$spec_func_entry" ]] && {
    echo "Can't find function entry for $src!"
    exit 1
  }

  [[ -n "$spec_func_entry" ]] && {
    # Debug
    #echo "$spec_func_entry -> func_entry:$func_entry"
    func_entry="$spec_func_entry"
  }

  [[ -n "$endbr_entry" ]] && {
    # Debug
    #echo "$endbr_entry -> func_entry:$func_entry"
    func_entry="$endbr_entry"
  } 

  check_endbr=$(echo "$func_entry" | grep "$ENDBR64")
  if [[ -z "$check_endbr" ]]; then
    FUNC_ENTRY_INS_NAME=$(echo "$func_entry" | awk -F " " '{print $3,$4,$5}')
  else
    # shellcheck disable=SC2034
    FUNC_ENTRY_INS_NAME="$ENDBR64"
  fi

  FUNC_ENTRY_INS=$(echo "$func_entry" | awk -F " " '{print $1}' | cut -d ":" -f 1)
}

find_endbr_func_entry() {
  local ins=$1
  local sysmap=$2

  FUNC_NAME=$(grep "$ins" "$sysmap")
  FUNC_NAME="$FUNC_NAME($FUNC_ENTRY_INS_NAME)"
}

check_file() {
  local lbr=$1
  local kdump=$2
  local sysmap=$3
  local temp="temp.txt"
  local ins=""
  local src=""
  local des=""

  [[ -e "$lbr" ]] || usage
  [[ -e "$kdump" ]] || usage
  [[ -e "$sysmap" ]] || usage

  awk -F "|" '{print $2,$3,$4}' "$lbr"  | grep -v "^  " | grep -v "00000000" > "$temp"

  cat /dev/null > "$OUTPUT"

  while IFS= read -r line
  do
      # Solve every line content
      [[ "$line" == "LBR"* ]] && {
        echo "$line" >> "$OUTPUT"
        continue
      }
      src=$(echo "$line" | awk  '{print $2}' | awk -F "0x0000" '{print $2}')
      src="ffff""$src"
      ins=$(grep ^"$src" "$kdump")
      find_endbr_ins "$src" "$kdump"
      find_endbr_func_entry "$FUNC_ENTRY_INS" "$sysmap"
      line="$line | Src:$FUNC_NAME -> $ins"

      des=$(echo "$line" | awk  '{print $3}' | awk -F "0x0000" '{print $2}')
      des="ffff""$des"
      ins=$(grep ^"$des" "$kdump")
      find_endbr_ins "$src" "$kdump"
      find_endbr_func_entry "$FUNC_ENTRY_INS" "$sysmap"
      line="$line | Dest:$FUNC_NAME -> $ins"
      #echo "Read line: $line"

      echo "line:$line"
      echo "$line" >> "$OUTPUT"

  done < "$temp"

  echo "Done! Please check result in $OUTPUT"
}


check_file "$LBR_FILE" "$KDUMP" "$SYSMAP"

