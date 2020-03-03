#!/bin/bash

# mount fuse and nfs mounts in fstab
for n in $(egrep 'fuse|nfs' /etc/fstab | awk '{print $2}') ; do 
        if [ "$(mount | grep -v autofs | grep $n)" == "" ] ; then
                mkdir -p $n
                mount $n
	fi
done


