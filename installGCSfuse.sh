#!/bin/bash


if [ -e /usr/bin/apt ] ; then

	apt install lsb-release

	export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
	echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

	apt update
	apt install gcsfuse

else

	sudo tee /etc/yum.repos.d/gcsfuse.repo > /dev/null <<EOF
[gcsfuse]
name=gcsfuse (packages.cloud.google.com)
baseurl=https://packages.cloud.google.com/yum/repos/gcsfuse-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

	yum -y update
	yum -y install gcsfuse

fi
