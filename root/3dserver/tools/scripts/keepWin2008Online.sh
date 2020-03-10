#!/bin/bash


startvm() {
	if [ "$(pgrep -fa kvm.*win2008)" == "" ] ; then
		# restart windows 2008 
		eval $(qm showcmd 103)
	fi
}

startvm > /tmp/windows.log 2>&1
