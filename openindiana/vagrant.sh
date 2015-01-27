#!/bin/sh
if [ ! -d "git/openindiana" -o ! -f "git/illumos.sh" ]; then
	echo "Expecting to be in a vagrant machine directory with"
	echo "a 'git' subdirectory consisting of a git clone of"
	echo "git://github.com/wca/illumos-gate"
	exit 1
fi

run() {
	echo "+ $*"
	$*; ret=$?
	if [ $ret -ne 0 ]; then
		echo "* Got exit code $ret, exiting ..."
		exit $ret
	fi
	true
}

run ln -sf git/openindiana/Vagrantfile .
run ln -sf git/openindiana/setup.sh .
run rm -rf zfsdisks

# Destroy the VM if needed.
vagrant destroy -f >/dev/null 2>&1 || true

# Make sure the disks are gone too.
zfsdisks=$(pwd)/zfsdisks
for i in 1 2 3 4 5; do
	VBoxManage showhdinfo ${zfsdisks}/disk${i}.vdi >/dev/null 2>&1
	[ $? -ne 0 ] && continue
	run VBoxManage closemedium disk $(pwd)/zfsdisks/disk${i}.vdi --delete
done

# Bring up the VM, then restart it for setup changes to take effect.
run vagrant up
run vagrant reload
