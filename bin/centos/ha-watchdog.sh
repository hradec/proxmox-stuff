#!/bin/bash


errorOnes=$(ha-manager status  | grep error | awk '{print $2}' | awk -F':' '{print $2}')

ha-manager status
for id in $errorOnes ; do
	ha-manager set $id -state disabled
done
sleep 5
for id in $errorOnes ; do
	ha-manager set $id -state started
done
ha-manager status

