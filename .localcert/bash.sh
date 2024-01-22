localcert_machine_platform(){
	local platform=$(uname -sr | tr '[:upper:]' '[:lower:]')

	case "$platform" in
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

localcert_machine_architecture(){
	local architecture=$(uname -m)

	case "$architecture" in
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

localcert_bin_platform(){
	local platform=$(localcert_machine_platform)

	case "$platform" in
		mac)
			echo "darwin"
		;;
		
		*)
			echo "$platform"
		;;
	esac
}

localcert_bin_extension(){
	local platform=$(localcert_machine_platform)

	case "$platform" in
		windows)
			echo ".exe"
		;;
	esac
}

localcert_bin_path(){
	if [ -n "$LOCALCERT_BIN" ] && [ -f "$LOCALCERT_BIN" ]; then
		echo "$LOCALCERT_BIN"
	fi
}

localcert_bin_install(){
	local binary=$LOCALCERT_BIN
	local platform=$(localcert_bin_platform)
	local architecture=$(localcert_machine_architecture)
	local url=${1:-"https://dl.filippo.io/mkcert/latest?for=$platform/$architecture"}
	local directory=$([ -n "$binary" ] && dirname "$binary")

	# Create directory (if it does not exist).
	if [ -n "$directory" ] && ! [ -d "$directory" ]; then
		mkdir -p "$directory" > /dev/null 2>&1
	fi

	# Install mkcert binary.
	if [ -n "$binary" ]; then
		curl -L --silent --output "$binary" "$url" > /dev/null 2>&1 \
			&& chmod +x "$binary" > /dev/null 2>&1 \
			&& echo "$binary"
	fi
}


localcert_bin(){
	local binary=$(localcert_bin_path)
	local executable=$([ -n "$binary" ] && echo "./$binary")

	if [ -n "$executable" ] && [ -f "$executable" ]; then
		$executable $@
	fi
}

localcert_root_path(){
	local platform=$(localcert_machine_platform)
	local directory=$(localcert_bin -CAROOT)

	if [ -n "$directory" ]; then
		case "$platform" in
			windows)
				echo "$(wslpath "$directory")"
			;;

			*)
				echo "$directory"
			;;
		esac
	fi
}

localcert_root_install(){
	localcert_bin -install > /dev/null 2>&1
	
	if [ $? == 0 ]; then
		local platform=$(localcert_machine_platform)
		local directory=$(localcert_root_path)
		local certificate="$directory/rootCA.pem"
		
		if [ -f "$certificate" ]; then
			case "$platform" in
				mac)
					# Check if certificate is trusted.
					security verify-cert -c "$certificate" > /dev/null 2>&1 && echo "$certificate"

					# Elevate to trust certificate (if it is not already trusted).
					if [ $? != 0 ]; then
						sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$certificate" && echo "$certificate"
					fi
				;;

				linux)
					# Update certificates in Linux system.
					update-ca-certificates && echo "$certificate"
				;;

				*)	
					echo "$certificate"
				;;
			esac
		fi
	fi
}

localcert_root_copy(){
	local from=$(localcert_root_path)
	local name="rootCA"
	local directory=${1:-"$LOCALCERT_OUTPUT"}

	if [ -n "$from" ] && [ -n "$directory" ]; then 
		# Create directory (if it does not exist).
		if ! [ -d "$directory" ]; then
			mkdir -p "$directory" > /dev/null 2>&1
		fi

		# Copy root certificate.
		\cp "$from/$name.pem" "$directory/$name.crt" \
			&& \cp "$from/$name-key.pem" "$directory/$name.key" \
			&& echo "true"
	fi
}

localcert_generate(){
	local name=$([[ "$1" == */* ]] && basename "$1" || echo "$1")
	local directory=$([[ "$1" == */* ]] && dirname "$1" || echo "$LOCALCERT_OUTPUT")
	shift
	local domains=$@

	if [ -n "$name" ] && [ -n "$domains" ]; then
		local key="$directory/$name.key"
		local cert="$directory/$name.crt"

		# Create directory if it does not exist.
		if [ -n "$directory" ] && ! [ -d "$directory" ]; then
			mkdir -p "$directory" > /dev/null 2>&1
		fi

		# Generate certificate for domains.
		localcert_bin \
			--key-file "$key" \
			--cert-file "$cert" \
			$domains > /dev/null 2>&1

		if [ $? == 0 ]; then
			echo "true"
		fi
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

export LOCALCERT_OUTPUT=${LOCALCERT_OUTPUT:-".certificates"}
export LOCALCERT_CACHE=${LOCALCERT_CACHE:-".localcert/cache"}
export LOCALCERT_BIN=${LOCALCERT_BIN:-"$LOCALCERT_CACHE/mkcert$(localcert_bin_extension)"}
