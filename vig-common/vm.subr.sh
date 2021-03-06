host_setupvm() {
	cd ${VIG_TOP}
	runcmd ln -sf .vig/vig-common/openindiana-Vagrantfile Vagrantfile
	runcmd ln -sf .vig/vig-common/openindiana-setup.sh setup.sh

	# Destroy the VM if needed.
	ignorecmd vagrant destroy -f >/dev/null 2>&1

	# Make sure the disks are gone too.
	zfsdisks=$(pwd)/zfsdisks
	for i in 1 2 3 4 5; do
		disk=${zfsdisks}/disk${i}.vdi
		VBoxManage showhdinfo ${disk} >/dev/null 2>&1 || continue
		runcmd VBoxManage closemedium disk ${disk} --delete
	done
	runcmd rm -rf zfsdisks

	# Bring up the VM, then restart it for setup changes to take effect.
	# Note that we must use VirtualBox here, since VMware providers
	# currently don't have a working HGFS.
	runcmd vagrant up --provider=virtualbox
	runcmd vagrant reload
}
register_command host setupvm "(Re-)Setup the VM"

host_startvm() {
	[ ! -e ${VIG_TOP}/Vagrantfile ] && host_setupvm || runcmd vagrant up
}
register_command host startvm "Start the VM if needed"

host_fromscratch() {
	host_build
	host_zfstests
}
register_command host fromscratch "Perform everything from scratch"

host_runguest() {
	runguest $*
}
register_command host runguest "Run an arbitrary guest vig command"
