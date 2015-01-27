#!/bin/sh
top=$(pwd)
src=${top}/usr/src
parent=${top}/..

$parent/illumos-build-init.sh

# Documentation: usr/src/test/README usr/src/test/zfs-tests/doc/README
# NB: Building illumos-gate should also generate the zfstest package.
set -e
set -x
bldenv illumos.sh "cd ${src}/test && dmake install"
bldenv illumos.sh "cd ${src}/pkg && dmake install"
