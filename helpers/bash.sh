os_platform(){
	case $(uname -sr | tr '[:upper:]' '[:lower:]') in
		*darwin*)
			echo 'darwin'
		;;

		*linux*microsoft*)
			echo 'windows'
		;;

		*linux*)
			echo 'linux'
		;;
	esac
}

os_architecture(){
	case $(uname -m) in
		arm64|aarch64*|armv*)
			echo 'arm64'
		;;
		
		arm)
			echo 'arm'
		;;
		
		*)
			echo 'amd64'
		;;
	esac
}

os_binary_extension(){
	case $(os_platform) in
		windows)
			echo '.exe'
		;;
	esac
}

mkcert_installed(){
	if [ -n $LOCAL_CERT_BINARY ] && [ -f $LOCAL_CERT_BINARY ]; then
		echo $LOCAL_CERT_BINARY
	fi
}

mkcert_download(){
	local url=${1:-"https://dl.filippo.io/mkcert/latest?for=$(os_platform)/$(os_architecture)"}

	if [ -n $LOCAL_CERT_BINARY ]; then
		if curl -L --output $LOCAL_CERT_BINARY $url; then
			chmod +x $LOCAL_CERT_BINARY
			echo $LOCAL_CERT_BINARY
		fi
	fi
}

mkcert_exec(){
	local binary=$([ -n $LOCAL_CERT_BINARY ] && echo "./$LOCAL_CERT_BINARY"); shift

	if [ -n $binary ] && [ -f $binary ]; then
		./$binary $@
	fi
}

mkcert_root_path(){
	local binary=$1
	local directory=$(mkcert_exec $binary -CAROOT)

	if [ -n $directory ]; then
		case "$(os_platform)" in
			windows)
				echo $(wslpath $directory)
			;;

			*)
				echo $directory
			;;
		esac
	fi
}

mkcert_copy(){
	local from=$1
	local to=$2

	if [ -n $from ] && [ -n $to ]; then 
		# Create directory if it does not exist.
		if ! [ -d $to ]; then
			mkdir -p $to
		fi

		# Copy files.
		if \cp $from/*.pem $to; then 
			echo true
		fi
	fi
}

export LOCAL_CERT_PATH=${LOCAL_CERT_PATH:-".mkcert"}
export LOCAL_CERT_BINARY=${LOCAL_CERT_BINARY:-"$mkcert_path/mkcert$(os_binary_extension)"}
