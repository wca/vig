upgrade_prologue() {
	[ -z "$1" ] && echo "Error: Must specify upgrade BE name" && exit 1
	BENAME="$1"; shift
}

guest_upgrade() {
	upgrade_prologue $1; shift
	cd $GUEST_WS
	sudo $GUEST_WS/usr/src/tools/scripts/onu -t $BENAME \
		-d $GUEST_WS/packages/i386/nightly
	sudo beadm unmount $BENAME
	sudo beadm activate $BENAME
}
register_command guest upgrade "Upgrade the guest using built sources"

guest_quick_upgrade() {
	cd $GUEST_WS
	makezfs=${GUEST_WS}/usr/src/tools/quick/make-zfs
	# Allow installing a temporary local override.
	[ -x /usr/local/bin/make-zfs ] && makezfs=/usr/local/bin/make-zfs
	bldenv illumos.sh "$makezfs onuzfs"
}
register_command guest quick_upgrade "Use make-zfs to do a quick upgrade"

take_snap() {
	snap="$1"
	# Insert to the head so snapshots can be easily destroyed in reverse.
	SNAPS="$snap $SNAPS"
	runcmd vagrant snap take default --name $snap
}

upgrade_prologue_host() {
	upgrade_prologue $1; shift
	for opt in $*; do
		case $opt in
			*=*)	eval ${opt} ;;
			*)	eval ${opt}=1 ;;
		esac
	done
	# Allow specifying "-" as the BE name to generate a date stamp.
	[ "$BENAME" = "-" ] && BENAME="$(date -u '+%Y.%m.%d.%H%M%S')"

	host_startvm
	take_snap pre-upgrade-$BENAME
}

upgrade_epilogue_host() {
	[ -z "$NO_POSTSNAP" ] && take_snap post-upgrade-$BENAME
}

host_upgrade_guest() {
	upgrade_prologue_host $*
	runguest upgrade $BENAME
	runcmd vagrant reload
	upgrade_epilogue_host
}
register_command host upgrade_guest "Upgrade the guest using built sources"

host_quick_upgrade() {
	upgrade_prologue_host $*
	runguest quick_upgrade
	runcmd vagrant reload
	upgrade_epilogue_host
}
register_command host quick_upgrade "Wrap the guest quick upgrade"
