#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cask_files=("$repo_root/proposals/Casks/emacs-app-linux.rb.example")
if [[ -f "$repo_root/Casks/emacs-app-linux.rb" ]]; then
  cask_files+=("$repo_root/Casks/emacs-app-linux.rb")
fi

echo "Checking shell syntax..."
bash -n \
  "$repo_root/scripts/check-local.sh" \
  "$repo_root/scripts/install-local.sh" \
  "$repo_root/scripts/smoke-test.sh" \
  "$repo_root/scripts/package-cask-artifact.sh" \
  "$repo_root/scripts/update-cask-checksums.sh"

echo "Checking Ruby syntax..."
if command -v ruby >/dev/null 2>&1; then
  ruby -c "$repo_root/Formula/emacs-pgtk.rb"
  for cask_file in "${cask_files[@]}"; do
    ruby -c "$cask_file"
  done
elif command -v brew >/dev/null 2>&1; then
  brew ruby -- -c "$repo_root/Formula/emacs-pgtk.rb"
  for cask_file in "${cask_files[@]}"; do
    brew ruby -- -c "$cask_file"
  done
else
  echo "Ruby and Homebrew are not installed; skipped Ruby syntax check."
fi

if command -v brew >/dev/null 2>&1; then
  echo "Checking Homebrew style..."
  brew style "$repo_root/Formula/emacs-pgtk.rb"
  echo "Cask candidate syntax passed above; cask style is checked after it is copied into a tap-shaped Casks directory."
else
  echo "Homebrew is not installed; skipped Homebrew style check."
fi

if command -v shellcheck >/dev/null 2>&1; then
  echo "Checking shell scripts with ShellCheck..."
  shellcheck \
    "$repo_root/scripts/check-local.sh" \
    "$repo_root/scripts/install-local.sh" \
    "$repo_root/scripts/smoke-test.sh" \
    "$repo_root/scripts/package-cask-artifact.sh" \
    "$repo_root/scripts/update-cask-checksums.sh"
else
  echo "ShellCheck is not installed; skipped ShellCheck."
fi

echo "Fast local checks passed."
