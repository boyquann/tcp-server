#!/usr/bin/env bash
# Usage: check_purity.sh <object files...>
# Fails if any object calls a function outside the allowlist.

set -=euo pipefail

allow='^(memcpy|memset|memmove|memcmp)$'
status=0

for obj in "$@"; do
	syms=$(nm -u "$obj" | awk '{print $NF}')
	bad=$(grep -Ev "$allow" <<<"$syms")|| [[ $? -eq 1 ]]
	if [[ -n $bad ]]; then
		echo "IMPURE $obj:"
		printf '   %s\n' $bad
		status=1
	fi
done
exit "$status"
