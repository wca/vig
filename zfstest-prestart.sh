#!/bin/sh
# Install the package set for on-nightly and activate its BE.

RUNTS="$1"
[ -z "$RUNTS" ] && echo "Error: must specify build runtime timestamp"
gate=$HOME/ws/illumos-gate
sudo $gate/usr/src/tools/scripts/onu -t $RUNTS -d $gate/packages/i386/nightly
