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
	local output=${1:-"$LOCALCERT_CACHE"}

	if [ -n "$source" ] && [ -n "$output" ]; then 
		# Create directory if it does not exist.
		if ! [ -d "$output" ]; then
			mkdir -p $output
		fi

		# Copy files.
		if \cp $source/* $output; then 
			echo "true"
		fi
	fi
}

localcert_generate(){
	local output=$1
	local domain=$2

	if [ -n "$output" ] && [ -n "$domain" ]; then
		local name=$(basename "$output")
		local directory=$(dirname "$output")

		if [[ "$directory" == "." ]]; then
			directory=".localcert/certificates"
		fi

		local key="$directory/$name.key"
		local cert="$directory/$name.pem"

		# Create directory if it does not exist.
		if ! [ -d "$directory" ]; then
			mkdir -p $directory
		fi

		# Generate certificate.
		localcert_exec \
			--key-file "$key" \
			--cert-file "$cert" \
			$domain "*.$domain" ::1
	fi
}

export LOCALCERT_CACHE=${LOCALCERT_CACHE:-".localcert/cache"}
export LOCALCERT_BINARY=${LOCALCERT_BINARY:-"$LOCALCERT_CACHE/mkcert$(os_binary_extension)"}
