os_platform(){
	case "$(uname -sr | tr '[:upper:]' '[:lower:]')" in
		*darwin*)
			echo "mac"
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
			mkdir -p "$directory"
		fi

		if curl -L --silent --output "$LOCALCERT_BINARY" "$url"; then
			chmod +x "$LOCALCERT_BINARY" && echo "$LOCALCERT_BINARY"
		fi
	fi
}

localcert_exec(){
	local binary=$([ -n "$LOCALCERT_BINARY" ] && echo "./$LOCALCERT_BINARY")

	if [ -n "$binary" ] && [ -f "$binary" ]; then
		$binary $@
	fi
}

localcert_root_install(){
	localcert_exec -install

	local directory=$(localcert_root_path)
	local cert="$directory/rootCA.pem"

	case "$(os_platform)" in
		mac)
			# Add the certificate to the macos trust store
			if [ -f $cert ]; then
				security verify-cert -c "$directory/rootCA.pem" > /dev/null 2>&1
				if [ $? != 0 ]; then
					security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$directory/rootCA.pem"
					echo "$cert"
				fi 
			fi
		;;

		*)
			echo "$cert"
		;;
	esac
}

localcert_root_path(){
	local directory=$(localcert_exec -CAROOT)

	if [ -n "$directory" ]; then
		case "$(os_platform)" in
			windows)
				echo "$(wslpath "$directory")"
			;;

			*)
				echo "$directory"
			;;
		esac
	fi
}

localcert_root_copy(){
	local source=$(localcert_root_path)
	local output=${1:-"$LOCALCERT_CERTIFICATES"}

	if [ -n "$source" ] && [ -n "$output" ]; then 
		# Create directory if it does not exist.
		if ! [ -d "$output" ]; then
			mkdir -p "$output"
		fi

		# Copy files.
		if \cp "$source/rootCA.pem" "$output/rootCA.crt" && \cp "$source/rootCA-key.pem" "$output/rootCA.key"; then 
			echo "true"
		fi
	fi
}

localcert_generate(){
	local name=$([[ "$1" == */* ]] && basename "$1" || echo "$1")
	local directory=$([[ "$1" == */* ]] && dirname "$1" || echo "$LOCALCERT_CERTIFICATES")
	shift
	local domains=$@

	if [ -n "$name" ] && [ -n "$domains" ]; then
		local key="$directory/$name.key"
		local cert="$directory/$name.crt"

		# Create directory if it does not exist.
		if [ -n "$directory" ] && ! [ -d "$directory" ]; then
			mkdir -p "$directory"
		fi

		# Copy root certificate.
		localcert_root_copy "$directory" > /dev/null

		# Generate certificate for domains.
		localcert_exec \
			--key-file "$key" \
			--cert-file "$cert" \
			$domains
	fi
}

localcert_help()
{
	echo -e "Utility script to generate SSL certificates for local development."
	echo
	echo -e "Syntax:"
	echo -e " \033[1m./localcert <certificate-name> <domain> \033[2m<domain> ...\033[0m"
	# echo
	# echo -e "Options:"
	# echo -e " \033[1m-h\033[0m          Print this Help."
	echo
}

export LOCALCERT_CERTIFICATES=${LOCALCERT_CERTIFICATES:-".certificates"}
export LOCALCERT_CACHE=${LOCALCERT_CACHE:-".localcert/cache"}
export LOCALCERT_BINARY=${LOCALCERT_BINARY:-"$LOCALCERT_CACHE/mkcert$(os_binary_extension)"}
