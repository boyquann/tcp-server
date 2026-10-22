#!/usr/bin/env bash
# Usage: run_canary.sh <name> <must-fail|report-only> <signature> <command...>
# A canary passes only if the tool fired: the expected signature appears in
# the output, and (for must-fail) the command exited non-zero.
#

set -euo pipefail

name=$1
mode=$2
sig=$3
shift 3

status=0

out=$("$@" 2>&1) || status=$?

if [[ $mode == must-fail && $status -eq 0 ]]; then
	echo "CANARY FAIL $name: expected signature not found: $sig"
	printf '%s\n' "$out"
	exit 1
fi

if ! grep -qF -- "$sig" <<<"$out"; then
	echo "CANARY FAIL $name: xpected signature not found: $sig"
	printf '%s\n' "$out"
	xit 1
fi

echo "CANARY OK  $name"
