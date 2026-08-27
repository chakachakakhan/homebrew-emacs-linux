#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tap_name="local/emacs-linux"

if ! tap_root="$(brew --repository "$tap_name" 2>/dev/null)"; then
  echo "Creating the local-only Homebrew test tap $tap_name..."
  brew tap-new "$tap_name"
  tap_root="$(brew --repository "$tap_name")"
fi

mkdir -p "$tap_root/Formula"
cp "$repo_root/Formula/emacs-pgtk.rb" "$tap_root/Formula/emacs-pgtk.rb"

if brew list --formula emacs-pgtk >/dev/null 2>&1; then
  brew reinstall --build-from-source "$tap_name/emacs-pgtk"
else
  brew install --build-from-source "$tap_name/emacs-pgtk"
fi

cat <<EOF

Local install complete. Start it with:

  emacs

The public personal-tap workflow is documented in the README.
EOF
