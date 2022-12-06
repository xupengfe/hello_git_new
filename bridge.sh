#!/bin/bash

eth="enp0s20f0u1"

nmcli connection delete $eth
nmcli connection delete $eth
nmcli connection delete virbr0
nmcli connection delete virbr0
nmcli connection add type ethernet con-name $eth ifname $eth
nmcli connection add type bridge con-name virbr0 ifname virbr0
nmcli connection modify virbr0 stp no
nmcli connection modify $eth master virbr0
nmcli connection modify virbr0 ipv4.method auto
nmcli connection up virbr0
