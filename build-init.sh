#!/bin/sh
cp ../illumos.sh .
ws=$(basename $(pwd))
perl -pi -e "s,REPLACE_WITH_WS_GATE_NAME,${ws},g" illumos.sh
cp usr/src/tools/scripts/nightly.sh .
chmod +x nightly.sh
