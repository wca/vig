#!/bin/sh
cmd=`pwd`
while :; do
	[ "${cmd}" = "/" ] && echo "Not in a valid tree" && exit 1
	[ -f ${cmd}/Makefile.cmd ] && break
	cmd=`dirname $cmd`
done

find $cmd/zpool $cmd/zfs -name '*.[ch]' -type f | \
	xargs grep -h '^#include <' > ../ztest_hdrck.cpp
