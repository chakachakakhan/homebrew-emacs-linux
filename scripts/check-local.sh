#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking shell syntax..."
bash -n \
  "$repo_root/scripts/check-local.sh" \
  "$repo_root/scripts/install-local.sh" \
  "$repo_root/scripts/smoke-test.sh"

echo "Checking Ruby syntax..."
if command -v ruby >/dev/null 2>&1; then
  ruby -c "$repo_root/Formula/emacs-pgtk.rb"
elif command -v brew >/dev/null 2>&1; then
  brew ruby -- -c "$repo_root/Formula/emacs-pgtk.rb"
else
  echo "Ruby and Homebrew are not installed; skipped Ruby syntax check."
fi

if command -v brew >/dev/null 2>&1; then
  echo "Checking Homebrew style..."
  brew style "$repo_root/Formula/emacs-pgtk.rb"
else
  echo "Homebrew is not installed; skipped Homebrew style check."
fi

if command -v shellcheck >/dev/null 2>&1; then
  echo "Checking shell scripts with ShellCheck..."
  shellcheck \
    "$repo_root/scripts/check-local.sh" \
    "$repo_root/scripts/install-local.sh" \
    "$repo_root/scripts/smoke-test.sh"
else
  echo "ShellCheck is not installed; skipped ShellCheck."
fi

echo "Fast local checks passed."
