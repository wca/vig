#!/bin/sh
# This needs to run as root.
if [ "`id -u`" != "0" ]; then
	echo "Must run as root"
	exit 1
fi

# Constants used below.
TOP=/usbkey/vagrant
CACHE=$(pwd)
ZONE_JSON=${TOP}/zones/build.json
[ -z "$ZONE_USER" ] && ZONE_USER="willa"
BOOTSTRAP_URL="http://pkgsrc.joyent.com/packages/SmartOS/bootstrap"
BOOTSTRAP="bootstrap-2014Q3-x86_64.tar.gz"
SMF=/opt/custom/smf
PACKAGES="scmgit"

set -e
set -x

# Set up the "smartos multiarch 13.3.0 image" zone.
# Source: https://wiki.smartos.org/display/DOC/Building+SmartOS+on+SmartOS
imgadm import a1d74530-4212-11e3-8a71-a7247697c8f2

mkdir -p ${TOP}/zones
cat > ${ZONE_JSON} <<EOF
{"alias":"build","brand":"joyent","vcpus":4,"max_physical_memory":4096,"tmpfs":4096,"fs_allowed":"ufs,pcfs,tmpfs","image_uuid":"a1d74530-4212-11e3-8a71-a7247697c8f2","quota":15,"nics":[{"nic_tag":"admin","ip":"dhcp"}]}
EOF

vmadm create -f ${ZONE_JSON}
ZONE_ID=$(vmadm list | tail -1 | awk '{print $1}')
[ -z "$ZONE_ID" ] && echo "Error: Could not find zone id" && exit 1
ZLOGIN_ROOT="zlogin ${ZONE_ID}"
ZLOGIN_USER="zlogin -l $ZONE_USER ${ZONE_ID}"
ZLOGIN_SUDO="$ZLOGIN_USER pfexec"
ZONE_ROOT=/zones/${ZONE_ID}/root

# Set up the zone: remove the motd and set up the zone user.
$ZLOGIN_ROOT rm -f /etc/motd
$ZLOGIN_ROOT useradd $ZONE_USER
$ZLOGIN_ROOT usermod -P \"Primary Administrator\" $ZONE_USER
$ZLOGIN_ROOT mkdir -p /home/$ZONE_USER ${SMF}
$ZLOGIN_ROOT chown -R $ZONE_USER /home/$ZONE_USER

# Make the user a bit more usable
echo "export PATH=$PATH:\${PATH}" | $ZLOGIN_USER "cat > .profile"
perl -pi -e 's,PASSREQ=YES,PASSREQ=NO,g' ${ZONE_ROOT}/etc/default/login
$ZLOGIN_ROOT passwd -d ${ZONE_USER}

# Set up DHCP for the zone.
cp dhcp-setup ${ZONE_ROOT}/opt/local/sbin
cp network-dhcp.xml ${ZONE_ROOT}${SMF}/network-dhcp.xml
#cat dhcp-setup | $ZLOGIN_ROOT /bin/sh -c "cat > /opt/local/sbin/dhcp-setup"
#cat network-dhcp.xml | $ZLOGIN_ROOT /bin/sh -c "cat > ${SMF}/network-dhcp.xml"
$ZLOGIN_SUDO /lib/svc/method/manifest-import
$ZLOGIN_SUDO svcadm enable -r site/dhcp

# Bootstrap packages.
# NB: This part is already done for the zone image in question.
#cd ${CACHE}
#if [ ! -f "${BOOTSTRAP}" ]; then
#	curl -O ${BOOTSTRAP_URL}/${BOOTSTRAP}
#fi
#cd ${ZONE_ROOT}
#gzcat ${CACHE}/${BOOTSTRAP} | tar -xf -

# Set up packages we need.
$ZLOGIN_SUDO pkg_admin rebuild
$ZLOGIN_SUDO pkgin -y up
$ZLOGIN_SUDO pkgin -y in ${PACKAGES}
