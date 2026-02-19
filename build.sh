#!/bin/bash

set -euo pipefail

if [ -z "${1:-}" ]; then
	echo "Usage: ./build.sh <source>"
	exit 1
fi

name="${1%.s}"
gcc -nostdlib -no-pie -o "$name" "src/$name.s"

echo "[+] Built executable \"$name\" using GCC."
echo "[!] Run \`./$name\` to execute and \`echo \$?\` to verify success."

