#!/bin/bash

set -euo pipefail

echo "[!] Note: It is not advisable to rename source files once compiled. If done so, please make sure the object file and the ELF/executable file also have the same name to avoid duplication of build artifacts."
echo

if [ -z "${1:-}" ]; then
	echo "Usage: ./build.sh <source>"
	exit 1
else
	if [ ! -f "./src/$1.s" ]; then
		echo "Source file \`$1.s\` not available in \`src/\` directory."
		echo "Please make sure the file exists and is in the intended location."
		exit 1
	fi

	mkdir -p objects/
	as -o objects/$1.o src/$1.s	&& echo "[+] Assembled \"$1.s\""
	ld -o $1 objects/$1.o 		&& echo "[+] Linked \"$1.o\""
	
	echo "[+] Recompiled webserver \"$1\""
	echo
	echo "Run \`./server\` and \`echo \$?\` to verify success."

fi

