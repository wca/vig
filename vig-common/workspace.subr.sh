git_last_commit() {
	treeish=$1
	git log -1 --format=short --pretty=oneline $treeish | awk '{print $1}'
}

# The vig update method.
update_workspace() {
	# Update the copy of vig, if needed.
	cd ${VIG_REPO}
	commitid=$(git_last_commit master)
	idfile=${VIG_COPY}/.commitid
	[ -f "${idfile}" ] && currentid=$(cat ${idfile})
	[ "${currentid}" = "${commitid}" ] && return 1

	rm -rf ${VIG_COPY}
	runcmd mkdir -p ${VIG_COPY}
	runcmd "git archive ${commitid} | tar -C ${VIG_COPY} -xf -"
	echo "${commitid}" > ${idfile}
	return 0
}

check_closed_cksum() {
	prefix=$1
	closed=$2

	case "$closed" in
	on-closed-bins-nd) expected="35f08b4630d85307940482a8470f1188" ;;
	on-closed-bins)    expected="e6bdf40bd30d330e6a68f0515f6f2d24" ;;
	*)		   echo "*** ERROR: What's '${closed}'?" >&2 ;;
	esac

	cksum_cookie="${prefix}/.${closed}.cksum"
	if [ -f "${cksum_cookie}" ]; then
		cksum=$(cat ${cksum_cookie})
		[ "$cksum" = "$expected" ] && return
	fi

	echo $expected
}

guest_workspace_setup() {
	[ -n "$1" ] && BRANCH="$1"

	if [ ! -d "${GUEST_WS}/.git" ]; then
		parent=$(dirname ${GUEST_WS})
		runcmd mkdir -p ${parent}
		cd ${parent}
		git clone ${GUEST_REPO} illumos-gate
	fi

	# Update from the master copy in case it's needed.
	cd ${GUEST_WS}
	runcmd git pull -r

	# Pull the requested branch, if any, or setup if required.
	# This expects the workspace to be clean, obviously.  If this is not
	# the case, 'vig guest build' is meant for pre-commit change testing.
	if [ ! -d exception_lists -o -n "$BRANCH" ]; then
		[ -z "$BRANCH" ] && BRANCH="master"
		runcmd git checkout $BRANCH
	fi

	# Extract any closed binaries needed.
	for closed_bin in ${CLOSED_BINS}; do
		expected=$(check_closed_cksum ${GUEST_WS} ${closed_bin})
		[ -z "$expected" ] && continue

		runcmd tar xf ${CLOSED_BINS_DIR}/${closed_bin}.i386.tar.bz2
		echo "$expected" > .${closed_bin}.cksum
	done

	# Make sure illumos.sh is up to date.
	if [ ! -e illumos.sh -o ${VIG_COMMON}/illumos.sh -nt illumos.sh ]; then
		sed -e "s,WS_GATE_NAME,$(basename $(pwd)),g" \
			${VIG_COMMON}/illumos.sh > illumos.sh
	fi

	# Make sure the nightly script is up to date.
	# XXX Assumes no changes were made to it.  Is that valid?
	if ! cmp -s usr/src/tools/scripts/nightly.sh nightly.sh; then
		runcmd cp usr/src/tools/scripts/nightly.sh nightly.sh
		runcmd chmod +x nightly.sh
	fi
}
register_command guest workspace_setup

# This function is intended to be rerun anytime a build is needed.
host_workspace_setup() {
	# Fetch the closed binaries, if needed.  Cache them in case we need
	# multiple working spaces.
	curdir=$(pwd)

	cd ${VIG_REPO}
	[ ! -d ${CLOSED_BINS_DIR} ] && runcmd mkdir -p ${CLOSED_BINS_DIR}

	for closed_bin in ${CLOSED_BINS}; do
		closed_p=${closed_bin}.i386.tar.bz2
		cached_p=${CLOSED_BINS_DIR}/${closed_p}

		expected=$(check_closed_cksum ${CLOSED_BINS_DIR} ${closed_bin})
		[ -f "${cached_p}" -a -z "$expected" ] && continue

		fetch_url ${CLOSED_URL}/${closed_p} ${cached_p}
		echo "Checking MD5 for ${cached_p} ..."
		md5=$(md5_file ${cached_p})
		if [ "$md5" != "$expected" ]; then
			echo "MD5 checksum failure for ${f}"
			exit 1
		fi
		echo "$expected" > ${CLOSED_BINS_DIR}/.${closed_bin}.cksum
	done
	cd $curdir
}
register_command host workspace_setup "Perform any needed workspace setup"
