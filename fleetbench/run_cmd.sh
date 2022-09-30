#!/bin/bash
#Default
mkdir -p RunLogs

readelf -n ./fleetbench-proto-native
for i in {1..10}
do
        echo "======Default run #$i====="
        sync; echo 3> /proc/sys/vm/drop_caches
        numactl -C 1 -m 0 ./fleetbench-proto-native --benchmark_filter=all --benchmark_min_time=3 --benchmark_min_time=60  2>&1 | tee RunLogs/FleetBench_proto_Def_Run$i.log
        sleep 5
done

sleep 30

readelf -n ./fleetbench-proto-shstk
for i in {1..10}
do
        echo "======SHSTK run #$i====="
        sync; echo 3> /proc/sys/vm/drop_caches
        numactl -C 1 -m 0 ./fleetbench-proto-shstk --benchmark_filter=all --benchmark_min_time=3 --benchmark_min_time=60  2>&1 | tee RunLogs/FleetBench_proto_shstk_Run$i.log
        sleep 5
done

