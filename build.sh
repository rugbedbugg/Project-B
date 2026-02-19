#!/bin/bash

set -euo pipefail

echo "[!] Note: It is not advisable to rename source files once compiled. If done so, please make sure the object file and the ELF/executable file also have the same name to avoid duplication of build artifacts."
echo

if [ -z "${1:-}" ]; then
	echo "Usage: ./build.sh <source>"
	exit 1
fi

name="${1%.s}"
if [ ! -f "./src/$name.s" ]; then
	echo "Source file \`$name.s\` not available in \`src/\` directory."
	echo "Please make sure the file exists and is in the intended location."
	exit 1
fi

mkdir -p objects/

as -o "objects/$name.o" "src/$name.s"
echo "[+] Assembled \"$name.s\""

ld -o "$name" "objects/$name.o"
echo "[+] Linked \"$name.o\""

echo "[+] Built executable \"$name\"" 	\ &&
echo 					\ &&
echo "Run \`./$name\` to execute and \`echo \$?\` to verify success."

