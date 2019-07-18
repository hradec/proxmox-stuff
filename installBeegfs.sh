#!/bin/bash

wget -q https://www.beegfs.io/release/latest-stable/gpg/DEB-GPG-KEY-beegfs -O- | apt-key add -
curl -L https://www.beegfs.io/release/latest-stable/dists/beegfs-deb9.list > /etc/apt/sources.list.d/beegfs-deb9.list
apt -y update && \
for pkg in beegfs-mgmtd beegfs-meta libbeegfs-ib beegfs-storage libbeegfs-ib beegfs-client beegfs-helperd beegfs-utils beegfs-admon ; do
	apt -y install $pkg || (echo error ; break)
	/etc/init.d/beegfs-client rebuild || (echo error ; break)
done
