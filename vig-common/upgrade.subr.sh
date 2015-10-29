upgrade_prologue() {
	[ -z "$1" ] && echo "Error: Must specify upgrade BE name" && exit 1
	BENAME="$1"; shift
}
upgrade_epilogue() {
	sudo beadm unmount $BENAME
	sudo beadm activate $BENAME
}

guest_upgrade() {
	upgrade_prologue
	cd $GUEST_WS
	sudo $GUEST_WS/usr/src/tools/scripts/onu -t $BENAME \
		-d $GUEST_WS/packages/i386/nightly
	upgrade_epilogue
}
register_command guest upgrade "Upgrade the guest using built sources"

host_upgrade_guest() {
	upgrade_prologue
	OPTS="$1"; shift

	# Allow specifying "-" as the BE name to generate a date stamp.
	[ "$BENAME" = "-" ] && BENAME="$(date -u '+%Y.%m.%d.%H%M%S')"

	host_startvm
	runcmd vagrant snap take default --name pre-upgrade-$BENAME
	runguest upgrade $BENAME
	runcmd vagrant reload

	[ "$OPTS" != "nopostsnap" ] &&
		runcmd vagrant snap take default --name post-upgrade-$BENAME
}
register_command host upgrade_guest "Upgrade the guest using built sources"

guest_quick_upgrade() {
	upgrade_prologue
	cd $GUEST_WS
	sudo $GUEST_WS/usr/src/tools/quick/make-zfs onuzfs $BENAME
	upgrade_epilogue
}
register_command host quick_upgrade "Use make-zfs to do a quick upgrade"
