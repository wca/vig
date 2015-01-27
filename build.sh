#!/bin/sh
# Tail the nightly log while the build is running.
/usr/gnu/bin/tail -F log/nightly.log &
tailpid=$!

./nightly.sh $* illumos.sh
ret=$?
kill -15 $tailpid
exit $ret
