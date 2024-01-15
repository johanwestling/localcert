#!/bin/bash
. ./helpers/bash.sh

echo ""
echo "Generate"
echo "========"
echo ""

if [ -z $(mkcert_installed $mkcert_bin) ]; then
	echo "-> Downloading $mkcert_bin"
	if [ -n $(mkcert_download $mkcert_bin) ]; then
		echo "   Done"
		echo ""
	else
		echo "   Failed"
		echo ""
		exit 1
	fi
fi

echo "-> Installing rootCA"
mkcert_exec $mkcert_bin \
	-install
echo "   Done"
echo ""

echo "-> Copying rootCA"
if [ -n $(mkcert_copy $(mkcert_root_path $mkcert_bin) $mkcert_path/certificates/) ]; then
	echo "   Done"
	echo ""
else 
	echo "   Failed"
	echo ""
	exit 1
fi

echo "-> Generate rfsisu certificates"
mkcert_exec $mkcert_bin -key-file="$mkcert_path/certificates/rfsisu-key.pem" -cert-file="$mkcert_path/certificates/rfsisu.pem" rfsisu.local.aventyret.com "*.rfsisu.local.aventyret.com"
echo "   Done"
echo ""
