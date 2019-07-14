#!/bin/bash

# grab the host main ip address
host="$(ping -c 1 $(hostname) | grep PING | awk '{print $3}' | tr -d '()')"

# windows is offline
if [ "$(qm list | grep win2008r2 | grep running)" == "" ] ; then
	echo '# so we have to shutdown eveything that depends on it'
	timeout 30 systemctl stop glusterfs-server
	if [ $? != 0 ] ; then
		timeout 30 pkill -fc -9 gluster
	fi
	echo '# force umount of the iscsi block device'
	umount -f -l /gv0
	echo '# and stop iscsi'
	timeout 30 systemctl stop iscsid
	if [ $? != 0 ] ; then
		timeout 30 pkill -fc -9 iscsid
	fi
	echo '# so now everything is ready to bring'
	echo '# /gv0 up once windows is online!'


# windows is online
else
    echo "
    # if iscsi gluster block device doesn't exist, lets restart everything
    # and try to bring it up.. since windows is online, we should be able to
    # to do it now!

    # first we need to make sure windows iscsi target is online!
    # we do this by checking the iscsi port if its open or not."
    if  [ "$(nmap -p 3260 192.168.0.7 | grep 3260 | grep open)" != "" ] ; then
      echo '
      # now that we known iscsi target it online, lets check if our block device is! '
      if [ ! -e /dev/disk/by-uuid/1f809b02-84a4-4e95-92fc-ec8d4230f5bd ] ; then
	echo '
	# its not, so we have to bring everything up'
	timeout 60 systemctl restart iscsid
	if [ $? != 0 ] ; then
		timeout 60 systemctl stop iscsid
		timeout 30 pkill -fc -9 iscsid
		timeout 60 systemctl stop iscsid
		timeout 60 systemctl start iscsid
	fi
	echo '
	# log in on windows target to bring the block device online'
	iscsiadm -m node -T iqn.1991-05.com.microsoft:win-cu4cm8kradf-3dserver-target -l

        echo '
        # the iscsi block device came online susscessfully!'
        if [ -e /dev/disk/by-uuid/1f809b02-84a4-4e95-92fc-ec8d4230f5bd ] ; then
		echo '
		# so we bring glusterfs online, and hopefully it will be up!'
		systemctl restart autofs
		ls -l /gv0
		timeout 60 systemctl restart glusterfs-server
		if [ $? != 0 ] ; then
			timeout 60 systemctl stop glusterfs-server
			timeout 30 pkill -fc -9 gluster
			timeout 60 systemctl stop glusterfs-server
			timeout 60 systemctl start glusterfs-server
		fi
	fi
      fi
      echo "
      # iscsi block device is up!"
      echo '
      # if gluster brick of this host is offline, force it online... so we can have gluster
      # even if centos is offline'
      if [ "$( gluster vol status | grep $host | awk '{print $(NF-1)}')" != "Y" ] ; then
	echo "
	# forcing start gluster volume..."
	gluster volume start gv0 force
      fi
      echo "# all done!! Gluster volume should be up and running!"
    else
      echo "# windows iscsi target is offline still..."
    fi
fi

