#!/bin/bash

# mount fuse and nfs mounts in fstab
for n in $(egrep 'fuse|nfs' /etc/fstab | awk '{print $2}') ; do 
        if [ "$(mount | grep -v autofs | grep $n)" == "" ] || [ "$(timeout 30 ls $n)" == "" ] ; then
                mkdir -p $n
		umount -f -l $n || true
		umount -f -l $n || true
		umount -f -l $n || true
                mount $n
	fi
done


