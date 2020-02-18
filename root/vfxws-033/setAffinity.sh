#!/bin/bash

win10cores=$(( $(cat /etc/pve/qemu-server/3002.conf  | grep limi | awk '{print $NF}') -1 ))

if [ "$(taskset -pc $(pgrep -f kvm.*win10) | head -1 | awk '{print $NF}')" != "0-$win10cores" ] ; then

	taskset -apc  0-$win10cores $(pgrep -f kvm.*win10) | head -1
	taskset -apc $(( win10cores + 1 ))-63 $(pgrep -f kvm.*netboot) | head -1

	taskset -p $(pgrep -f kvm.*win10) | head -1
	taskset -p $(pgrep -f kvm.*netboot) | head -1
	taskset -pc $(pgrep -f kvm.*win10) | head -1
	taskset -pc $(pgrep -f kvm.*netboot) | head -1
fi
