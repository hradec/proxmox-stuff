#!/usr/bin/python2

import socket, os, sys
from glob import glob as glob

# variables setup
# =============================================================================
hostname = socket.gethostname()
CD = os.path.dirname( os.path.abspath(__file__) )

vm_map = {
	'vfxws-013' : 'vfxws-013',
	'vfxws-021' : 'vfxws-021',
	'vfxws-024' : 'vfxws-024',
	'vfxws-026' : 'vfxws-026',
	'3dserver'  : '3dserver',
	'centos'    : 'centos',
	'manjaro'   : 'manjaro',
}

folders = {
	'bin' 		: 'bin',
	'sbin' 		: 'sbin',
	'etc' 		: 'etc',
	'crontab' 	: 'var/spool/cron/crontabs',
	'root'	 	: 'root',
	'lib'	 	: 'lib',
	'lib64'	 	: 'lib64',
}

files_need_reboot = {
}

if 'proxmox' in hostname:
	folders['crontab'] = 'var/spool/cron/crontabs'

if hostname not in vm_map:
	vm_map[ hostname ] = hostname

# function setup
# =============================================================================
def switchBranch():
	# to easy test new features, we can switch git branch based on
	# the name of the vm. if the name has '-branch-' in it, whatever
	# comes after '-branch-' is the branch name.
	# if there's no '-branch-', it defaults to master branch.
	# ex:  storage-4-branch-split-atomo
	# 				the branch will be split-atomo!
	branch='atomo-centos-novo'

	os.system( 'mkdir -p /root/.ssh ; chmod 0700 /root/.ssh ; echo "StrictHostKeyChecking no" > /root/.ssh/config' )

	# make a copy of this file so we can check if it changed after updating!
	os.system("cp %s/setup.py /dev/shm/ " % CD)

	current_branch = ''.join(os.popen("cd %s ; git branch -a | grep '*' | awk '{print $(NF)}'" % CD).readlines()).strip()
	if current_branch != branch:
		os.system( '''
			cd %s
			git stash
			git reset HEAD~5 --hard
			git pull
			git checkout remotes/origin/%s -b %s || git checkout %s
			git pull
			sync
		''' % (CD, branch, branch, branch) )

	# check if this setup.py changed... if so, reboot so we can run the updated one
	cmd = "cd %s ; diff ./setup.py /dev/shm/setup.py" % CD




def install():
	reboot=False
	for vm in [ x for x in vm_map if x in hostname ]:
		# we check if we need to reboot after updating the image
		for f in files_need_reboot:
			cmd = "diff %s %s" % (f % vm_map[vm], files_need_reboot[f])
			if ''.join(os.popen(cmd).readline()).strip():
				reboot = True

		# update the image
		for f in folders:
			for file in glob( "%s/%s/%s/*" % ( CD, f, vm_map[vm] ) ) :
				target="/%s/%s" % ( folders[f], os.path.basename(file) )
				if os.path.islink( target ):
					cmd = "rm -rfv %s" % target
					print cmd
					os.system( cmd )
				cmd = "cp -rfuvL  %-80s /%s/" % ( file, folders[f] )
				print cmd
				os.system( cmd )

		if reboot:
			os.system( "systemctl reboot" )
		else:
			os.system( "systemctl restart autofs")
			os.system( "systemctl restart glusterfs-server")
			os.system( "systemctl restart smbd")
			os.system( "systemctl restart nfsd")

def copyBack():
	for vm in [ x for x in vm_map if x in hostname ]:
		for f in folders:
			cmd = "mkdir -p %s/%s/%s/" % ( CD, f, vm_map[vm] )
			print cmd
			os.system( cmd )

		for f in folders:
			for file in [ x.strip() for x in os.popen( "find %s/%s/%s/ -type f -print" % ( CD, f, vm_map[vm] ) ).readlines()]:
				if os.path.islink(file):
					print "%s file is a link, so we don't copy back..."
				else:
					cmd = "cp -rfuv /%-40s %s/%s/%s" % ( folders[f]+file.split(vm_map[vm])[-1], CD, f, vm_map[vm]+file.split(vm_map[vm])[-1] )
					print cmd
					os.system( cmd )

		os.system( "cd %s ; git status" % CD )


# void main()
# =============================================================================
if len(sys.argv) == 1:
	print '='*80
	print '''
		to install files to the system, just run:

			setup.py --install

		to copy files from a system back to the depot, run:

			setup.py --commit


	obs: setup.py will copy the files correctly, denpending on
	     what hostname it is.
	'''
	print '='*80
else:
	# use an alternative git branch, based on the vm name
	switchBranch()
	print sys.argv
	# install
	if "-i" in sys.argv[1]:
		install()

	# copy back
	if "-c" in sys.argv[1]:
		copyBack()
