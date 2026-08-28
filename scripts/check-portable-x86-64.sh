#!/usr/bin/env bash
set -euo pipefail

binary="${1:?Usage: check-portable-x86-64.sh PATH_TO_BINARY}"
artifact_arch="${ARTIFACT_ARCH:-$(uname -m)}"

if [[ "$artifact_arch" != "x86_64" && "$artifact_arch" != "amd64" ]]; then
  echo "Portable x86-64 instruction check skipped for $artifact_arch."
  exit 0
fi

if [[ ! -r "$binary" ]]; then
  echo "Binary does not exist or is not readable: $binary" >&2
  exit 1
fi

if ! command -v objdump >/dev/null 2>&1; then
  echo "objdump is required for the x86-64 portability check." >&2
  exit 1
fi

disassembly="$(mktemp)"
cleanup() {
  rm -f -- "$disassembly"
}
trap cleanup EXIT

objdump -d "$binary" > "$disassembly"

# x86-64 baseline has no VEX or EVEX vector instructions. In particular,
# this catches AVX/AVX2/AVX-512 instructions that can be emitted when a
# GitHub-hosted runner is newer than the machines that will install the cask.
if grep -Eiq '^[[:space:]]*[0-9a-f]+:[[:space:]]+([0-9a-f]{2}[[:space:]]+)+v[a-z0-9]' "$disassembly"; then
  echo "The x86-64 artifact contains non-baseline vector instructions: $binary" >&2
  grep -Ei '^[[:space:]]*[0-9a-f]+:[[:space:]]+([0-9a-f]{2}[[:space:]]+)+v[a-z0-9]' "$disassembly" | sed -n '1,5p' >&2
  exit 1
fi

echo "x86-64 baseline instruction check passed: $binary"
