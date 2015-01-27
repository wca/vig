#!/bin/sh
# This script manages the current vagrant box by automatically installing
# the illumos-gate build as a temporary BE, then restarting and
# automatically executing the zfstest suite, collecting the output.
#
# Whether the BE doesn't start, the test run times out or finishes
# successfully, the script will automatically rollback the VM to the
# snapshot set immediately prior, and restart it.
#
# The expectation is that the vagrant box will always be used to generate
# the build and also to run the tests.  While in test mode, it will never be
# used to store any data, such that the VM can be rolled back to just after
# the last build completed.
#
# This requires https://github.com/scalefactory/vagrant-multiprovider-snap
# for managing VM snapshots.  It works for VirtualBox and VMware via the
# commercial VMware plugin.
#
# ***********************************************************************
# NOTE: THIS REQUIRES NETWORK ACCESS TO ALL PKG REPOSITORIES!
# ***********************************************************************

VAGRANTHOME=/export/home/vagrant

runcmd() {
	echo "+ $*"
	eval $*; ret=$?
	[ $ret -ne 0 ] && stop
}

stop() {
	if [ $stopped -eq 0 ]; then
		vagrant snap rollback default --name "${RUNTS}"
		stopped=1
	fi
	if [ $stopped -eq 1 ]; then
		vagrant snap delete default --name "${RUNTS}"
		stopped=2
	fi
	exit $ret
}

main() {
	stopped=0
	ret=0

	## Everything should be sandboxed to this runtime timestamp.
	## Re-execute ourselves passing the runtime timestamp.
	RUNTS="$1"
	if [ -z "$RUNTS" ]; then
		RUNTS="$(date -u '+%Y.%m.%d.%H%M%S')"
		LOGDIR="$(pwd)/zfstests/${RUNTS}"
		[ -d "$LOGDIR" ] && echo "$LOGDIR already exists?" && exit 127
		mkdir -p ${LOGDIR}
		exec $0 ${RUNTS} | tee ${LOGDIR}/log
		exit 127 # NOTREACHED
	fi
	LOGDIR="$(pwd)/zfstests/${RUNTS}"

	## 1. Create a snapshot of the VM and bring it up if needed.
	##    Once the snapshot is created, trap signals to shutdown properly.
	runcmd vagrant snap take default --name $RUNTS
	trap 'stop' INT TERM

	## 2. Install the current packages into a new BE and restart.
	runcmd vagrant ssh -c \"$VAGRANTHOME/ws/zfstest-prestart.sh ${RUNTS}\"
	runcmd vagrant reload

	## 3. Start the run, and copy back the results if possible.
	runcmd vagrant ssh -c \"$VAGRANTHOME/ws/zfstest-actual.sh ${RUNTS}\"

	## 4. Stop by rolling back the snapshot and destroying it.
	stop
}

main $*
