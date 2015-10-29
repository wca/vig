# Re-execution helpers.
reexec_with_runts() {
	if [ -n "$1" ]; then
		export RUNTS="$1"; shift
		export LOGDIR="${VIG_TOP}/zfstests/${RUNTS}"
		return
	fi
	export RUNTS="$(date -u '+%Y.%m.%d.%H%M%S')"
	export LOGDIR="${VIG_TOP}/zfstests/${RUNTS}"
	[ -d "$LOGDIR" ] && echo "$LOGDIR already exists?" && exit 127
	runcmd mkdir -p ${LOGDIR}
	vig_reexec_noreturn ${RUNTS} 2>&1 || tee ${LOGDIR}/host.log
	exit $? # exit for tee subshell
}
