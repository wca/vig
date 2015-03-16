host_syssetup() {
	CURDIR=$(pwd)
	echo "Checking vagrant plugin list..."
	if ! vagrant plugin list | grep "^${SNAPPLUGIN}" >/dev/null 2>&1; then
		echo "Installing ${SNAPPLUGIN} as prerequisite ..."
		checkcmd vagrant plugin install ${SNAPPLUGIN}
	fi
	echo "Checking vagrant box list..."
	if ! vagrant box list | grep "^${HIPSTER}" >/dev/null 2>&1; then
		echo "Creating ${HIPSTER} vagrant box..."
		cd ${VIG_DIR}/..
		packer_dir=$(basename ${OI_PACKER_GIT})
		[ ! -d "${packer_dir}" ] && runcmd git clone ${OI_PACKER_GIT}
		cd ${packer_build}
		runcmd packer build template.json
		runcmd vagrant box add --name ${HIPSTER} \
			./${HIPSTER}-virtualbox.box
		cd ${CURDIR}
	fi
	echo "All set!"
}
register_command host syssetup "Set up the host system for use"
