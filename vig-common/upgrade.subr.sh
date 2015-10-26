guest_upgrade() {
	BENAME="$1"
	[ -z "$BENAME" ] && echo "Error: Must specify upgrade BE name" && exit 1

	cd $GUEST_WS
	sudo $GUEST_WS/usr/src/tools/scripts/onu -t $BENAME \
		-d $GUEST_WS/packages/i386/nightly
	sudo beadm unmount $BENAME
	sudo beadm activate $BENAME
}
register_command guest upgrade "Upgrade the guest using built sources"

host_upgrade_guest() {
	BENAME="$1"
	[ -z "$BENAME" ] && echo "Error: Must specify upgrade BE name" && exit 1
	OPTS="$2"

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
