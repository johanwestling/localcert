os_platform(){
	case "$(uname -sr | tr '[:upper:]' '[:lower:]')" in
		*darwin*)
			echo "darwin"
		;;

		*linux*microsoft*)
			echo "windows"
		;;

		*linux*)
			echo "linux"
		;;
	esac
}

os_architecture(){
	case "$(uname -m)" in
		arm64|aarch64*|armv*)
			echo "arm64"
		;;
		
		arm)
			echo "arm"
		;;
		
		*)
			echo "amd64"
		;;
	esac
}

os_binary_extension(){
	case "$(os_platform)" in
		windows)
			echo ".exe"
		;;
	esac
}

localcert_installed(){
	if [ -n "$LOCALCERT_BINARY" ] && [ -f "$LOCALCERT_BINARY" ]; then
		echo "$LOCALCERT_BINARY"
	fi
}

localcert_download(){
	local url=${1:-"https://dl.filippo.io/mkcert/latest?for=$(os_platform)/$(os_architecture)"}
	local directory=$(dirname "$LOCALCERT_BINARY")

	if [ -n "$LOCALCERT_BINARY" ]; then
		# Create directory if it does not exist.
		if ! [ -d "$directory" ]; then
			mkdir -p $directory
		fi

		if curl -L --output $LOCALCERT_BINARY $url; then
			chmod +x $LOCALCERT_BINARY && echo $LOCALCERT_BINARY
		fi
	fi
}

localcert_exec(){
	local binary=$([ -n "$LOCALCERT_BINARY" ] && echo "./$LOCALCERT_BINARY")

	if [ -n "$binary" ] && [ -f "$binary" ]; then
		$binary $@
	fi
}

localcert_root_path(){
	local directory=$(localcert_exec -CAROOT)

	if [ -n "$directory" ]; then
		case "$(os_platform)" in
			windows)
				echo $(wslpath "$directory")
			;;

			*)
				echo "$directory"
			;;
		esac
	fi
}

localcert_root_copy(){
	local source=$(localcert_root_path)
	local destination=${1:-"$LOCALCERT_CACHE"}

	if [ -n "$source" ] && [ -n "$destination" ]; then 
		# Create directory if it does not exist.
		if ! [ -d "$destination" ]; then
			mkdir -p $destination
		fi

		# Copy files.
		if \cp $source/* $destination; then 
			echo "true"
		fi
	fi
}

localcert_generate(){
	local name=$1
	local domain=$2
	local key="$LOCALCERT_CACHE/$name.key"
	local cert="$LOCALCERT_CACHE/$name.pem"

	if [ -n "$name" ] && [ -n "$domain" ]; then
		localcert_exec \
			--key-file "$key" \
			--cert-file "$cert" \
			$domain "*.$domain" ::1
	fi
}

export LOCALCERT_CACHE=${LOCALCERT_CACHE:-".cache"}
export LOCALCERT_BINARY=${LOCALCERT_BINARY:-"$LOCALCERT_CACHE/mkcert$(os_binary_extension)"}
