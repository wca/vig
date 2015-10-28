#!/bin/sh
# The OpenIndiana vagrant provisioner script.
# This is separate from the vig-common scripts because vagrant will transmit
# this file (and only this file) to the guest for provisioning.

# Remove the incorporation since it will conflict for some reason...
# pkg install: No matching version of developer/parser/bison can be installed:
#   Reject: pkg://openindiana.org/developer/parser/bison@2.7.1-2014.0.1.0
#   Reason:  This version is excluded by installed incorporation entire@0.5.11-2015.0.2.0
echo "Removing 'entire' incorporation to prevent conflicts..."
pkg uninstall entire

# Install the base package set from oi-dev.
echo "Installing package set ..."
pkg install \
 pkg:/data/docbook \
 pkg:/developer/astdev \
 pkg:/developer/build/make \
 pkg:/developer/build/onbld \
 pkg:/developer/illumos-gcc \
 pkg:/developer/gnu-binutils \
 pkg:/developer/opensolaris/osnet \
 pkg:/developer/java/jdk \
 pkg:/developer/lexer/flex \
 pkg:/developer/object-file \
 pkg:/developer/parser/bison \
 pkg:/developer/versioning/mercurial \
 pkg:/developer/versioning/git \
 pkg:/developer/library/lint \
 pkg:/library/glib2 \
 pkg:/library/libxml2 \
 pkg:/library/libxslt \
 pkg:/library/nspr/header-nspr \
 pkg:/library/perl-5/xml-parser \
 pkg:/library/security/trousers \
 pkg:/print/cups \
 pkg:/print/filter/ghostscript \
 pkg:/runtime/perl-522 \
 pkg:/system/library/math/header-math \
 pkg:/system/library/install \
 pkg:/system/library/dbus \
 pkg:/system/library/libdbus \
 pkg:/system/library/libdbus-glib \
 pkg:/system/library/mozilla-nss/header-nss \
 pkg:/system/header \
 pkg:/system/management/product-registry \
 pkg:/system/management/snmp/net-snmp \
 pkg:/text/gnu-gettext \
 pkg:/library/python-2/python-extra-26 \
 pkg:/web/server/apache-13 \
 pkg:/system/test/testrunner \
 pkg:/system/test/zfstest \
 pkg:/developer/sunstudio12u1

# Ensure that things are accessible in the correct order.
echo "export PATH=/opt/SUNWspro/sunstudio12.1/bin:\${PATH}" >> .profile
echo "export PATH=/opt/gcc/4.4.4/bin:\${PATH}" >> .profile
echo "export PATH=/opt/onbld/bin:\${PATH}" >> .profile
echo "export PATH=/usr/bin:\${PATH}" >> .profile

# Remove /tmp so we can build properly.  This requires a reboot.
perl -pi -e 's,(^.*/tmp.*$),#$1,g' /etc/vfstab
