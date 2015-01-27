#!/bin/sh

[ -z "$DEST_REPO" ] && DEST_REPO="git://github.com/wca/illumos-gate"
if [ -z "$REPO_URL" ]; then
	[ -d "/vagrant/git" ] && REPO_URL="/vagrant/git"
	[ -z "$REPO_URL" ] && REPO_URL="$DEST_REPO"
fi

ws="$1"
[ -z "${ws}" ] && ws="illumos-gate"
ws_path="${HOME}/ws/${ws}"

if [ -d "${ws_path}" ]; then
	echo "Workspace ${ws} already setup at ${ws_path}, skipping" 
else
	echo "Setting up repository ${REPO_URL} at ${ws_path} ..."
	mkdir -p ${HOME}/ws
	cd ${HOME}/ws
	git clone ${REPO_URL} ${ws}
fi
cd ${ws_path}
# Make sure we've got the latest remote branches etc.
git config remote.origin.url "$DEST_REPO"
git pull -r
cp -f *.sh ..

# Fetch the closed binaries, if needed.  Cache them in case we need multiple
# working spaces.
closed_bins=${HOME}/.closed_bins
closed_url=http://dlc.openindiana.org/dlc.sun.com/osol/on/downloads/20100817
mkdir -p ${closed_bins}
for f in on-closed-bins-nd on-closed-bins; do
	p=${f}.i386.tar.bz2
	cached_p=${closed_bins}/${p}
	if [ ! -f "${cached_p}" ]; then
		wget -qO ${cached_p} ${closed_url}/${p}; ret=$?
		[ $ret -ne 0 ] && exit $ret
	fi
	echo "Checking MD5 for ${cached_p} ..."
	md5=$(md5sum ${cached_p} | awk '{print $1}')
	case "$f" in
	on-closed-bins-nd) expected="35f08b4630d85307940482a8470f1188" ;;
	on-closed-bins)    expected="e6bdf40bd30d330e6a68f0515f6f2d24" ;;
	*)		   echo "???" && exit 1 ;;
	esac
	if [ "$md5" != "$expected" ]; then
		echo "MD5 checksum failure for ${f}"
		exit 1
	fi
	echo "MD5 OK, extracting ${cached_p} ..."
	tar xf ${cached_p}
done

cat <<EOF

Build setup done.  To build illumos, cd ${ws_path}, then switch to the
branch you wish to build and run ../illumos-build-init.sh.  Once done:

Full build:  ./nightly.sh illumos.sh
Incremental: ./nightly.sh -i illumos.sh
EOF
