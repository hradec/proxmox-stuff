#!/bin/bash

mkdir -p /tmp/xx
umount -f -l /tmp/xx
mount LABEL=PROXMOX_SSD /tmp/xx && \
rsync  -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/mnt/*","/gcs/*","/.LIZARDFS/*","/.MOOSEFS/*","/var/tmp/*","/var/lib/vz/images/*","/var/lib/lxcfs/cgroup/*","/zdb"} --delete  / /tmp/xx/

chroot /tmp/xx /bin/sh -c '\
	mount -t proc proc /proc ;\
	mount -t devtmpfs dev /dev ;\
	mount -t sysfs sys /sys ;\
	mount /dev/sdg4 /boot/efi ; \
	grub-install --target=x86_64-efi /dev/sdg --no-nvram ; \
	update-grub ; \
	umount /boot/efi /proc /dev /sys \
'

umount /tmp/xx
