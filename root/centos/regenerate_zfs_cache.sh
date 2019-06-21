#!/bin/bash


zpool status | grep 'pool:' | awk '{print $(NF)}' | while read p ; do 
	echo zpool set cachefile=/etc/zfs/zpool.cache $p 
	zpool set cachefile=/etc/zfs/zpool.cache $p 
done

