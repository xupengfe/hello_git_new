#!/bin/bash

SLIBLINGS="/tmp/sliblings"

cpu_num=$(grep -c processor /proc/cpuinfo)
all_cpus=$(echo $(seq 0 $((cpu_num - 1))))
all_cpus=" $all_cpus "
echo "|$all_cpus|"
echo "$all_cpus" > $SLIBLINGS

echo "cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list"
atom=$(cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list \
      | grep "-" \
      | awk -F "-" '{print $NF}')
server=$(cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list \
        | grep "," \
        | awk -F "," '{print $NF}')
remove_list=" $atom $server "

for remove_cpu in $remove_list; do
  sed -i s/" $remove_cpu "/' '/g $SLIBLINGS
done

CPU_LIST=$(cat $SLIBLINGS)
echo "LIST:$CPU_LIST"
