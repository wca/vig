guest_build() {
	[ -n "$1" ] && BRANCH="$1"

	guest_workspace_setup $BRANCH
	cd ${GUEST_WS}

	# Tail the nightly log while the build is running.
	/usr/gnu/bin/tail -F log/nightly.log &
	tailpid=$!

	./nightly.sh $* illumos.sh
	ret=$?
	kill -15 $tailpid
	exit $ret
}
register_command guest build "Perform a build"

host_build() {
	[ -n "$1" ] && BRANCH="$1"

	# Set up the workspace and start the VM if necessary.
	host_workspace_setup
	host_startvm

	# The illumos build always returns non-zero because there are
	# currently-ignored lint warnings.
	runssh "${GUEST_VIG} build ${BRANCH} || true"
}
register_command host build "Perform a build in the VM"
