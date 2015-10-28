guest_build() {
	[ -n "$1" ] && BRANCH="$1" && shift

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
register_command guest build "Perform a complete build"

guest_buildonlyzfs() {
	[ ! -d "${GUEST_WS}/packages" ] && \
		echo "Error: Must have completed a full build" && exit 1
	[ -n "$1" ] && BRANCH="$1" && shift
	[ -z "$BRANCH" ] && BRANCH="master"

	cd ${GUEST_WS}
	# First pull to see if the branch is available, then check it out
	# and pull again, rebasing.
	git pull -r || exit $?
	git checkout ${BRANCH} || exit $?
	git pull -r || exit $?
	bldenv illumos.sh './usr/src/tools/quick/make-zfs lint'
	exit $ret
}
register_command guest buildonlyzfs "Build only ZFS; useful for compile testing"

host_build() {
	[ -n "$1" ] && BRANCH="$1" || BRANCH="master"
	cd ${HOST_REPO} || \
		(echo "No illumos-gate companion repository?" && exit 1)
	if ! git show "$BRANCH" >/dev/null 2>&1; then
		echo "Error: Unknown branch '$BRANCH'!"
		exit 1
	fi

	# Set up the workspace and start the VM if necessary.
	host_workspace_setup
	host_startvm

	# The illumos build always returns non-zero because there are
	# currently-ignored lint warnings.
	runssh "${GUEST_VIG} build ${BRANCH} || true"
}
register_command host build "Perform a build in the VM"
