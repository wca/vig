#!/bin/sh
# From anon@src.omniti.com:~omnios/core/omnios-build/build/illumos/build.sh:
# One small modification: runtime/perl -> pkg://omnios/runtime/perl
BUILD_DEPENDS_IPS="developer/astdev developer/build/make developer/build/onbld developer/gcc44 developer/java/jdk developer/lexer/flex developer/object-file developer/parser/bison library/glib2 library/libxml2 library/libxslt library/nspr/header-nspr library/perl-5/xml-parser library/security/trousers pkg://omnios/runtime/perl runtime/perl-64 runtime/perl/manual system/library/install system/library/dbus system/library/libdbus system/library/libdbus-glib system/library/mozilla-nss/header-nss system/management/snmp/net-snmp text/gnu-gettext sunstudio12.1"

# This package seems to be required to build too... without it we're missing
# basic things like /usr/include/stdio.h!
BUILD_DEPENDS_IPS="${BUILD_DEPENDS_IPS} system/header"

# This package is required to actually clone illumos-gate.
BUILD_DEPENDS_IPS="${BUILD_DEPENDS_IPS} pkg://omnios/developer/versioning/git"

# Install the base package set.
echo "$(date): Installing packages for illumos-gate development ..."
pkg install ${BUILD_DEPENDS_IPS}

# Errors still occurring:
#   javac -target 1.5 (fix in illumos-gate)
#   javac -target 5 (fix in illumos-gate)
#   apache missing: usr/src/lib/print/mod_ipp/mod_ipp.c
#   math.h missing: src/func.c
#   cups missing: usr/src/cmd/smbsrv/smbd
#   libsmb missing: usr/src/cmd/smbsrv/smbadm usr/src/cmd/idmap/idmapd
#   libsmbns missing: usr/src/cmd/krb5/kadmin/server
#   /usr/perl5/5.10.0/bin/xsubpp missing:
#       usr/src/cmd/perl/contrib/Sun/Solaris/Intrs [...]

# Fixup paths to find things.
echo "$(date): Fixing up build environment ..."
ln -sf /opt/sunstudio12.1 /opt/SUNWspro
mkdir -p /opt/gcc
ln -s /opt/gcc-4.4.4 /opt/gcc/4.4.4

# Ensure that things are accessible.
if ! grep SUNWspro/bin $HOME/.profile >/dev/null 2>&1; then
	echo "export PATH=/opt/SUNWspro/bin:\${PATH}" >> .profile
fi
if ! grep /opt/gcc/4.4.4 $HOME/.profile >/dev/null 2>&1; then
	echo "export PATH=/opt/gcc/4.4.4/bin:\${PATH}" >> .profile
fi

echo "Setting up a VM-local illumos-gate workspace ..."
su - vagrant -c /vagrant/git/workspace-setup.sh
