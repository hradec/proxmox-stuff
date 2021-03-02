#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ] ; then

	echo -e "\n\n$(basename $0) <vm id> <nic name>\n\n"

else
	vm=$1
	net=$2

	net_config=$( pvesh  get /nodes/3dserver/qemu/$vm/config --output-format yaml | grep $net | sed 's/.link_down..//' | awk -F': ' '{print $2}')

	#echo "$net_config"

	pvesh  set /nodes/3dserver/qemu/$vm/config -$net $net_config,link_down=1
	sleep 5
	pvesh  set /nodes/3dserver/qemu/$vm/config -$net $net_config,link_down=0
fi
