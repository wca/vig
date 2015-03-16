guest_pkgrepo_init() {
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
	setprop="sudo svccfg -s ${pkgsrvnightly} setprop"
	${setprop} pkg/inst_root = astring: "${pkgrepo}"
	${setprop} pkg/port = count: ${pkgport}
	${setprop} pkg/readonly = boolean: true
	sudo svcadm refresh ${publisher}
	sudo svcadm enable ${publisher}
	sudo pkg set-publisher -G '*' -M '*' \
		-g http://localhost:${pkgport}/ ${publisher}
	# Remove the OpenIndiana "entire" package so it doesn't block local ones
	sudo pkg uninstall entire
}
register_command pkgrepo_init "Initalize a package repository for the workspace"
