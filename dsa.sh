#!/bin/bash

DSA_CONFIG_PATH=/sys/bus/dsa/devices
DSA_BIND_PATH=/sys/bus/dsa/drivers/dsa/bind
DSA_UNBIND_PATH=/sys/bus/dsa/drivers/dsa/unbind
DSA_PCI_DEVICE="0000:00:03.0"
DSA_TEST_ITERATIONS=20

# DSA0 config

# set engine 0 to group 0
echo "echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.0/group_id"
echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.0/group_id

# setup group 0
echo "echo 0 > $DSA_CONFIG_PATH/dsa0/wq0.0/group_id"
echo 0 > $DSA_CONFIG_PATH/dsa0/wq0.0/group_id

echo "echo dedicated > $DSA_CONFIG_PATH/dsa0/wq0.0/mode"
echo dedicated > $DSA_CONFIG_PATH/dsa0/wq0.0/mode

echo "echo 10 > $DSA_CONFIG_PATH/dsa0/wq0.0/priority"
echo 10 > $DSA_CONFIG_PATH/dsa0/wq0.0/priority
echo "echo 16 > $DSA_CONFIG_PATH/dsa0/wq0.0/size"
echo 16 > $DSA_CONFIG_PATH/dsa0/wq0.0/size
echo "echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.0/group_id"
echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.0/group_id
echo "echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.1/group_id"
echo 0 > $DSA_CONFIG_PATH/dsa0/engine0.1/group_id
echo "echo kernel > $DSA_CONFIG_PATH/dsa0/wq0.0/type"
echo "kernel" > $DSA_CONFIG_PATH/dsa0/wq0.0/type
echo "echo dmaengine > $DSA_CONFIG_PATH/dsa0/wq0.0/name"
echo "dmaengine" > $DSA_CONFIG_PATH/dsa0/wq0.0/name
echo "echo 15 > $DSA_CONFIG_PATH/dsa0/wq0.0/threshold"
echo "15" > $DSA_CONFIG_PATH/dsa0/wq0.0/threshold
echo "Engines for group 0"
echo "cat $DSA_CONFIG_PATH/dsa0/group0.0/engines"
cat $DSA_CONFIG_PATH/dsa0/group0.0/engines
echo "Work queues for group 0"
echo "cat $DSA_CONFIG_PATH/dsa0/group0.0/work_queues"
cat $DSA_CONFIG_PATH/dsa0/group0.0/work_queues

echo "enable dsa0"
echo "echo dsa0 > $DSA_BIND_PATH"
echo dsa0 > $DSA_BIND_PATH

echo "enable wq0.0"
echo "echo wq0.0 > $DSA_BIND_PATH"
echo wq0.0 > $DSA_BIND_PATH

echo "Next modprobe dmatest !!!!!!"
sleep 5

echo "modprobe dmatest"
modprobe dmatest
echo "Run DMA test"
echo "echo $DSA_TEST_ITERATIONS > /sys/module/dmatest/parameters/iterations"
echo $DSA_TEST_ITERATIONS > /sys/module/dmatest/parameters/iterations
echo "echo 0 > /sys/module/dmatest/parameters/verbose"
echo 0 > /sys/module/dmatest/parameters/verbose
echo "echo 0 > /sys/module/dmatest/parameters/force_src_shared"
echo 0 > /sys/module/dmatest/parameters/force_src_shared
echo "echo 0 > /sys/module/dmatest/parameters/force_dst_shared"
echo 0 > /sys/module/dmatest/parameters/force_dst_shared
echo "echo 0 > /sys/module/dmatest/parameters/polled"
echo 0 > /sys/module/dmatest/parameters/polled
echo "echo 1 > /sys/module/dmatest/parameters/norandom"
echo 1 > /sys/module/dmatest/parameters/norandom
echo "echo 0 > /sys/module/dmatest/parameters/noverify"
echo 0 > /sys/module/dmatest/parameters/noverify
echo "echo 12 > /sys/module/dmatest/parameters/alignment"
echo 12 > /sys/module/dmatest/parameters/alignment
echo "echo $DSA_PCI_DEVICE > /sys/module/dmatest/parameters/device"
echo $DSA_PCI_DEVICE > /sys/module/dmatest/parameters/device
echo "echo '' > /sys/module/dmatest/parameters/channel"
echo "" > /sys/module/dmatest/parameters/channel
echo "echo 1 > /sys/module/dmatest/parameters/run"
echo 1 > /sys/module/dmatest/parameters/run
sleep 5
echo "echo 0 > /sys/module/dmatest/parameters/run"
echo 0 > /sys/module/dmatest/parameters/run

echo "disable wq0.0"
echo "echo wq0.0 > $DSA_UNBIND_PATH"
echo wq0.0 > $DSA_UNBIND_PATH
echo "echo dsa0 > $DSA_UNBIND_PATH"
echo "disable dsa0"
echo dsa0 > $DSA_UNBIND_PATH