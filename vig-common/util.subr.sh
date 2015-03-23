which_one_of() {
	for cmd in $*; do
		if which $cmd >/dev/null 2>&1; then
			echo $cmd
			return;
		fi
	done
}

fetch_url() {
	url=$1
	target=$2

	cmd=$(which_one_of wget curl fetch)
	case "$cmd" in
		wget)		runcmd wget -O ${target} ${url} ;;
		curl|fetch)	runcmd $cmd -o ${target} ${url} ;;
		*)		echo "*** ERROR: Can't find curl/wget/fetch" >&2
				exit 1 ;;
	esac
}

md5_file() {
	fpath=$1

	cmd=$(which_one_of md5sum md5 openssl)
	case "$cmd" in
		md5sum)		md5sum $fpath | awk '{print $1}' ;;
		md5)		md5 $fpath | awk '{print $4}' ;;
		openssl)	openssl md5 $fpath | awk '{print $2}' ;;
		*)		echo "*** ERROR: Can't find MD5" >&2
				exit 1 ;;
	esac
}
