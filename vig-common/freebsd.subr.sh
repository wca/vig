sysrc_enabled() {
	file="$1"
	var="$2"

	cur=$(sysrc -f $file -n $var)
	case "$cur" in
		[Yy][Ee][Ss]) return 0 ;;
		*) return 1 ;;
	esac
}

kld_loaded() {
	kldstat -qm $1
}

ensure_module() {
	file="$1"
	module="$2"

	if ! sysrc_enabled $1 ${module}_enable; then
		runcmd sudo sysrc -f $file ${var}=YES
	fi
	case "$file" in
		/boot/loader.conf)
			kld_loaded $module || runcmd sudo kldload $module
			;;
		/etc/rc.conf)
			if ! service $module status >/dev/null 2>&1; then
				runcmd sudo service $module start
			fi
			;;
	esac
}

host_setupfreebsd() {
	pkgs=""
	# Xauth is included so VirtualBox GUI is remotely runnable
	for pkg in vagrant virtualbox-ose xauth; do
		pkg info -q $pkg && continue
		pkgs="$pkgs $pkg"
	done
	[ -n "$pkgs" ] && runcmd sudo pkg install -y $pkgs

	ensure_module /boot/loader.conf vboxdrv
	ensure_module /etc/rc.conf vboxnet

	vbug=$(id -g vboxusers)
	if ! id -G | grep -w $vbug >/dev/null 2>&1; then
		runcmd sudo pw groupmod vboxusers -m $(whoami)
		echo "*** You were not a member of vboxusers; fixed."
		echo "*** Restart this shell to activate this membership."
		exit 1
	fi
}
