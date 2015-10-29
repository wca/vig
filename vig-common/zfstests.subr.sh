guest_zfstests() {
	RUNTS="$1"
	[ -z "$RUNTS" ] && echo "Must specify build runtime timestamp" && exit 1
	shift

	# Any additional arguments specify individual test suites.
	ZT_ARGS=""
	if [ ! -z "$*" ]; then
		tests=/opt/zfs-tests/tests/functional
		cp ${VIG_TOP}/zfstests.run /tmp/test.run
		cd $tests
		for i in $*; do
			tests=$(ls -1 $i | egrep -v '(^(cleanup|setup)|\.)')
			echo "[$tests/$i]" >> /tmp/test.run
			str=""
			for t in $tests; do
				str="${str}'${t}',"
			done
			echo "tests = [$str]" >> /tmp/test.run
		done
		ZT_ARGS="$ZT_ARGS -c /tmp/test.run"
	fi

	# Run the test suite and save the result to return as the final exit.
	export DISKS="c3t1d0 c3t2d0 c3t3d0 c3t4d0 c3t5d0"
	/opt/zfs-tests/bin/zfstest $ZT_ARGS
	ret=$?

	resultsparent=/var/tmp/test_results
	[ ! -d $resultsparent ] && echo "No results parent!" && exit $ret
	resultsdir="$(ls -1td $resultsparent/* | head -1 | awk '{print $1}')"
	[ -z "$resultsdir" ] && echo "No results dir!" && exit $ret
	tsdir=/vagrant/zfstests/${RUNTS}
	echo "ZFS tests exited $ret, copying from $resultsdir to $tsdir ..."
	runcmd sudo cp -rp $resultsdir/\* $tsdir
	runcmd sudo chown -R vagrant $tsdir
	exit $ret
}
register_command guest zfstests "Actually run the ZFS tests"

zfstests__stop_rollback() {
	[ -n "$NO_TEARDOWN" ] && return
	vagrant snap rollback default --name "pre-upgrade-${RUNTS}"
}
zfstests__stop_delete() {
	[ -n "$NO_TEARDOWN" ] && return
	vagrant snap delete default --name "pre-upgrade-${RUNTS}"
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

zfstests_run() {
	stoppers_init
	zfstests_register_stoppers
	runguest zfstests $RUNTS
	zfstests_teardown
}

host_zfstests() {
	reexec_with_runts $*
	host_upgrade_guest ${RUNTS} nopostsnap
	zfstests_run
}
register_command host zfstests "Perform a full ZFS test suite run"

host_quickertests() {
	reexec_with_runts $*
	host_quick_upgrade ${RUNTS}
	zfstests_run
}
register_command host quickertests "Perform the ZFS tests a quicker way"
