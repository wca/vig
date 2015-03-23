guest_upgrade() {
	BENAME="$1"
	[ -z "$BENAME" ] && echo "Error: Must specify upgrade BE name"

	cd $GUEST_WS
	sudo $GUEST_WS/usr/src/tools/scripst/onu -t $BENAME \
		-d $GUEST_WS/packages/i386/nightly
}
register_command guest upgrade "Upgrade the guest using built sources"

host_upgrade_guest() {
	BENAME="$1"
	[ -z "$BENAME" ] && echo "Error: Must specify upgrade BE name"
	OPTS="$2"

	host_startvm
	runcmd vagrant snap take default --name pre-upgrade-$BENAME
	runguest upgrade $BENAME
	runcmd vagrant reload

	[ "$OPTS" = "nopostsnap" ] &&
		runcmd vagrant snap take default --name post-upgrade-$BENAME
}
register_command host upgrade_guest
