echo "./fleetbench-proto-native --benchmark_filter=all --benchmark_min_time=3 --benchmark_min_time=60"
./fleetbench-proto-native --benchmark_filter=all --benchmark_min_time=3 --benchmark_min_time=60

sleep 5

echo "./fleetbench-proto-shstk --benchmark_filter=all --benchmark_min_time=3 --benchmark_min_time=60"
./fleetbench-proto-shstk --benchmark_filter=all --benchmark_min_time=3 --benchmark_min_time=60
