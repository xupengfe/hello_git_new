#!/bin/bash
file_name=$1
parm=$2
current_path=""
check=""
code_path="/home/code/lkml/"
#code_path="/home/code/os.linux.intelnext.kernel/"

echo "cd $code_path"
cd "$code_path" || {
  echo "access $code_path failed"
  return 2
}

#check=$(echo "$file_name" | grep "/")
#if [[ -z "$check" ]]; then
  echo "./scripts/checkpatch.pl -f --strict --codespell $file_name"
  ./scripts/checkpatch.pl -f --strict --codespell "$file_name"
#else
#  current_path=$(pwd)
#  ./scripts/checkpatch.pl -f "$current_path/$file_name"
#fi

#if [[ "$parm" == 'a' ]]; then
#  echo "parm:a"
#  echo "./scripts/checkpatch.pl $file_name"
#  ./scripts/checkpatch.pl "$file_name"
#fi

case $parm in
  a)
    echo "./scripts/checkpatch.pl $file_name"
    ./scripts/checkpatch.pl "$file_name"
    ;;
  s)
    echo "./scripts/checkpatch.pl --strict --codespell $file_name"
    ./scripts/checkpatch.pl --strict --codespell "$file_name"
    ;;
  *)
    echo "invalid parm:$parm"
    ;;
esac
