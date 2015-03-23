guest_zfstests() {
	RUNTS="$1"
	[ -z "$RUNTS" ] && echo "Must specify build runtime timestamp" && exit 1

	# Run the test suite and save the result to return as the final exit.
	export DISKS="c2t1d0 c2t2d0 c2t3d0 c2t4d0 c2t5d0"
	/opt/zfs-tests/bin/zfstest
	ret=$?

	resultsparent=/var/tmp/test_results
	resultsdir="$(ls -1td $resultsparent/* | head -1 | awk '{print $1}')"
	tsdir=/vagrant/zfstests/${RUNTS}
	echo "ZFS tests exited $ret, copying from $resultsdir to $tsdir ..."
	runcmd sudo cp -rp $resultsdir/\* $tsdir
	runcmd sudo chown -R vagrant $tsdir
	exit $ret
}
register_command guest zfstests "Actually run the ZFS tests"

zfstests__stop_rollback() {
	vagrant snap rollback default --name "${RUNTS}"
}
zfstests__stop_delete() {
	vagrant snap delete default --name "${RUNTS}"
}
zfstests_register_stoppers() {
	# Insert in reverse order of actual execution.
	register_stopper zfstests__stop_delete
	register_stopper zfstests__stop_rollback
}
zfstests_teardown() {
	zfstests__stop_rollback
	unregister_stopper zfstests__stop_rollback
	zfstests__stop_delete
	unregister_stopper zfstests__stop_delete
}

host_zfstests() {
	stopped=0
	ret=0

	## Everything should be sandboxed to this runtime timestamp.
	## Re-execute ourselves passing the runtime timestamp.
	RUNTS="$1"
	if [ -z "$RUNTS" ]; then
		RUNTS="$(date -u '+%Y.%m.%d.%H%M%S')"
		LOGDIR="${VIG_TOP}/zfstests/${RUNTS}"
		[ -d "$LOGDIR" ] && echo "$LOGDIR already exists?" && exit 127
		runcmd mkdir -p ${LOGDIR}
		vig_reexec_noreturn ${RUNTS} | tee ${LOGDIR}/log
		exit $?
	fi
	LOGDIR="${VIG_TOP}/zfstests/${RUNTS}"

	## 1. Upgrade the VM, bringing it up if needed.  This will create
	##    the VM snapshot "pre-upgrade-${RUNTS}", referenced here.
	host_upgrade_guest ${RUNTS} nopostsnap
	zfstests_register_stoppers

	## 2. Start the run, and copy back the results if possible.
	runguest zfstests $RUNTS

	## 3. Stop by rolling back the snapshot and destroying it.
	zfstests_teardown
}
register_command host zfstests "Perform a full ZFS test suite run"