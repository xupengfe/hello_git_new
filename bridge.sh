#!/bin/bash

eth="enp0s20f0u1"

echo "nmcli connection delete $eth"
nmcli connection delete $eth

echo "nmcli connection delete $eth"
nmcli connection delete $eth

echo "nmcli connection delete virbr0"
nmcli connection delete virbr0

echo "nmcli connection delete virbr0"
nmcli connection delete virbr0

echo "nmcli connection add type ethernet con-name $eth ifname $eth"
nmcli connection add type ethernet con-name $eth ifname $eth

echo "nmcli connection add type bridge con-name virbr0 ifname virbr0"
nmcli connection add type bridge con-name virbr0 ifname virbr0

echo "nmcli connection modify virbr0 stp no"
nmcli connection modify virbr0 stp no

echo "nmcli connection modify $eth master virbr0"
nmcli connection modify $eth master virbr0

echo "nmcli connection modify virbr0 ipv4.method auto"
nmcli connection modify virbr0 ipv4.method auto

echo "nmcli connection up virbr0"
nmcli connection up virbr0

echo "nmcli networking off; nmcli networking on"
nmcli networking off; nmcli networking on

echo "nmcli connection down virbr0; nmcli connection up $eth"
nmcli connection down virbr0; nmcli connection up $eth
