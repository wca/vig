#!/bin/sh
top=$(pwd)
pkgrepo=${top}/packages/i386/nightly/repo.redist
pkgport=4321
pkgsrv=svc:/application/pkg/server
publisher=on-nightly
pkgsrvnightly=${pkgsrv}:${publisher}

set -e
set -x
sudo svccfg -s ${pkgsrv} add ${publisher}
sudo svccfg -s ${pkgsrvnightly} addpg pkg application
sudo svccfg -s ${pkgsrvnightly} setprop pkg/inst_root = astring: "${pkgrepo}"
sudo svccfg -s ${pkgsrvnightly} setprop pkg/port = count: ${pkgport}
sudo svccfg -s ${pkgsrvnightly} setprop pkg/readonly = boolean: true
sudo svcadm refresh ${publisher}
sudo svcadm enable ${publisher}
sudo pkg set-publisher -G '*' -M '*' -g http://localhost:${pkgport}/ ${publisher}
# Remove the OpenIndiana "entire" package so it doesn't block local ones.
sudo pkg uninstall entire
