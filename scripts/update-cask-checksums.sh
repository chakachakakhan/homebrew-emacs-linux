#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cask_path="${CASK_PATH:-$repo_root/Casks/emacs-app-linux.rb}"
checksum_file="${1:-}"

if [[ -z "$checksum_file" || ! -f "$checksum_file" ]]; then
  echo "Usage: $0 PATH/TO/SHA256SUMS" >&2
  exit 2
fi

if [[ ! -f "$cask_path" ]]; then
  echo "Cask file does not exist: $cask_path" >&2
  echo "Copy the reviewed candidate to Casks/emacs-app-linux.rb first." >&2
  exit 1
fi

# Read only the GNU version. The cask keeps any artifact rebuild revision in
# its release URL so users see the actual Emacs version during installation.
emacs_version="$(sed -n 's/^  version "\([0-9][0-9.]*\).*/\1/p' "$cask_path" | head -n 1)"
if [[ -z "$emacs_version" ]]; then
  echo "Could not read the Emacs version from $cask_path" >&2
  exit 1
fi

x86_name="emacs-pgtk-${emacs_version}-linux-x86_64.tar.gz"
arm_name="emacs-pgtk-${emacs_version}-linux-arm64.tar.gz"
x86_sha="$(awk -v name="$x86_name" '$2 == name {print $1; exit}' "$checksum_file")"
arm_sha="$(awk -v name="$arm_name" '$2 == name {print $1; exit}' "$checksum_file")"

for checksum in "$x86_sha" "$arm_sha"; do
  if [[ ! "$checksum" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "Missing or invalid checksum in $checksum_file" >&2
    exit 1
  fi
done

sed -i -E \
  -e 's#(arm64_linux:[[:space:]]*")[^"]+#\1'"$arm_sha"'#' \
  -e 's#(x86_64_linux:[[:space:]]*")[^"]+#\1'"$x86_sha"'#' \
  "$cask_path"

echo "Updated $cask_path"
