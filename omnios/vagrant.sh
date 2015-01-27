#!/bin/sh
if [ ! -d "git/omnios" -o ! -f "git/illumos.sh" ]; then
	echo "Expecting to be in a vagrant machine directory with"
	echo "a 'git' subdirectory consisting of a git clone of"
	echo "git://github.com/wca/illumos-gate"
	exit 1
fi

set -e
set -x
ln -sf git/omnios/Vagrantfile .
ln -sf git/omnios/setup.sh .
vagrant up
