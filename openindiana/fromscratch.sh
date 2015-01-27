#!/bin/sh
# This script brings up a VM from scratch, performs an initial build, then
# does a zfstest run against it.

if which realpath >/dev/null 2>&1; then
	this=$(realpath $0)
elif which perl >/dev/null 2>&1; then
	this=$(perl -e 'use Cwd "abs_path";print abs_path(shift)' $0)
fi
parent=$(dirname $this)
topdir=$(dirname $parent)

[ -z "$BRANCH" ] && BRANCH="illumos-master"

# Bring up a fresh vagrant machine from scratch.
set -e
$parent/vagrant.sh

# Checkout the branch and initiate a build.  The nightly currently fails due
# to lint failures; ignore errors for that, at least for now.
cmd="cd ws/illumos-gate && git checkout $BRANCH"
cmd="$cmd && ../build-init.sh && (../build.sh || true)"

set -x
vagrant ssh -c "$cmd"

# Run the zfs test suite.
$topdir/zfstest-run.sh
