#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo "Please run it as root user"
    exit 1
fi

dhclient eth1

soFile=/home/mininet/pox/pox/lib/pxpcap/pxpcap.so
build_linux=/home/mininet/pox/pox/lib/pxpcap/pxpcap_c/
if [ ! -f "$soFile"  ]; then
    echo "`basename "$soFile"` non-existent"
    curDir=`pwd`; cd "$build_linux"; sh build_linux
    cd $curDic
fi

for module in `lsmod`; do
    if [ "$module" = "veth" ]; then
        rmmod "$module"
        break
    fi
done

x=0
while [ $x -le 6 ]; do
    echo "Set up veth$x and veth$(($x+1))"
    ip link add type veth
    ifconfig veth$x up
    ifconfig veth$(($x+1)) up
    #  has potential risk, since I assume this IP is available and no conflict
    #+ with existing IP address
    ifconfig veth$(($x+1)) 192.168.57.$(($x+71))
    x=$(($x+2))
done

SLEEP_TIME=10
printf "Wait ${SLEEP_TIME}s for the system to set everything up.\nYou may change the time accordingly."
sleep "$SLEEP_TIME"

/home/mininet/pox/pox.py --no-openflow datapaths.pcap_switch --address=192.168.56.101 --ports=veth0,veth2,veth4,veth6

