#!/bin/sh
RUNTS=$1
[ -z "$RUNTS" ] && echo "Must specify build runtime timestamp" && exit 1

# Run the test suite and save the result to return as the final exit code.
export DISKS="c2t1d0 c2t2d0 c2t3d0 c2t4d0 c2t5d0"
/opt/zfs-tests/bin/zfstest
ret=$?

resultsdir="$(ls -1td /var/tmp/test_results/* | head -1 | awk '{print $1}')"
tsdir=/vagrant/zfstests/${RUNTS}
echo "ZFS tests exited $ret, copying from $resultsdir to $tsdir ..."
cp -rp $resultsdir/* $tsdir

exit $ret
