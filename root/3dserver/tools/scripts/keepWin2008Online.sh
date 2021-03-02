#!/bin/bash


startvm() {
	vm=$1
	date
	ip=$(pvesh create /nodes/3dserver/qemu/$vm/agent -command network-get-interfaces --output-format yaml | grep ipv4 -B 1 | egrep 'ip.address:' | grep -v 127.0.0.1 | awk -F':' '{print $2}')
	echo ip: $ip
	[ "$ip" == "" ] && ip="192.168.250.7"
	if [ "$(pgrep -fa kvm.*win2008)" == "" ] ; then
		# restart windows 2008 
		eval $(qm showcmd $vm)
		count=0
		# and wait to come up!
		while [ "$(ping -c 5  $ip | grep ' 0%')" == "" ] || [ $count -gt 30 ] ; do
			echo "Waiting windows to start up... $count"
			let count=$count+1
			sleep 10
		done
	else
		# if vm is up but we can't ping, reset the vm network
		if [ "$(ping -c 5  $ip | grep ' 0%')" == "" ] ; then
			/root/proxmox-stuff/root/3dserver/tools/scripts/resetVMNetwork.sh
		else
			echo "vm is up and pingable"
		fi
	fi
}

startvm 103 > /tmp/windows.log 2>&1
cat /tmp/windows.log

