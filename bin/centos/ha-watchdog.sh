#!/bin/bash


errorOnes=$(ha-manager status  | grep error | awk '{print $2}' | awk -F':' '{print $2}')

ha-manager status
for id in $errorOnes ; do
	ha-manager set $id -state disabled
done
sleep 5
errorOnes=$(ha-manager status  | grep disable | awk '{print $2}' | awk -F':' '{print $2}')
for id in $errorOnes ; do
	echo "starting $id"
	ha-manager set $id -state started
done
ha-manager status

