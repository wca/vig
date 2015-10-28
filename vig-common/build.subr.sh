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

ZFS_DIRS="$ZFS_DIRS lib/libzfs"
ZFS_DIRS="$ZFS_DIRS lib/libzfs_core"
ZFS_DIRS="$ZFS_DIRS lib/libzpool"
ZFS_DIRS="$ZFS_DIRS cmd/zdb"
ZFS_DIRS="$ZFS_DIRS cmd/zfs"
ZFS_DIRS="$ZFS_DIRS cmd/zhack"
ZFS_DIRS="$ZFS_DIRS cmd/zinject"
ZFS_DIRS="$ZFS_DIRS cmd/zpool"
ZFS_DIRS="$ZFS_DIRS cmd/zstreamdump"
ZFS_DIRS="$ZFS_DIRS cmd/ztest"
guest_buildonlyzfs() {
	[ ! -d "${GUEST_WS}/packages" ] && \
		echo "Error: Must have completed a full build" && exit 1

	cd ${GUEST_WS}
	git pull -r || exit $?
	bldenv illumos.sh
	for dir in $ZFS_DIRS; do
		cd ${GUEST_WS}/usr/src/$dir
		dmake
		ret=$?
		[ $ret -ne 0 ] && break
	done
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
