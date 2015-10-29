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

guest_quick_upgrade() {
	cd $GUEST_WS
	makezfs=${GUEST_WS}/usr/src/tools/quick/make-zfs
	# Allow installing a temporary local override.
	[ -x /usr/local/bin/make-zfs ] && makezfs=/usr/local/bin/make-zfs
	sudo $makezfs onuzfs
	upgrade_epilogue
}
register_command guest quick_upgrade "Use make-zfs to do a quick upgrade"

upgrade_prologue_host() {
	upgrade_prologue
	OPTS="$1"; shift
	# Allow specifying "-" as the BE name to generate a date stamp.
	[ "$BENAME" = "-" ] && BENAME="$(date -u '+%Y.%m.%d.%H%M%S')"

	host_startvm
	runcmd vagrant snap take default --name pre-upgrade-$BENAME
}

upgrade_epilogue_host() {
	[ "$OPTS" != "nopostsnap" ] &&
		runcmd vagrant snap take default --name post-upgrade-$BENAME
}

host_upgrade_guest() {
	upgrade_prologue_host
	runguest upgrade $BENAME
	runcmd vagrant reload
	upgrade_epilogue_host
}
register_command host upgrade_guest "Upgrade the guest using built sources"

host_quick_upgrade() {
	upgrade_prologue_host
	runguest quick_upgrade
	runcmd vagrant reload
	upgrade_epilogue_host
}
register_command host quick_upgrade "Wrap the guest quick upgrade"
