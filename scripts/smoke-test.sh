#!/usr/bin/env bash
set -euo pipefail

emacs_binary="${1:-emacs}"

if ! command -v "$emacs_binary" >/dev/null 2>&1 && [[ ! -x "$emacs_binary" ]]; then
  echo "Cannot execute Emacs at: $emacs_binary" >&2
  exit 1
fi

test_dir="$(mktemp -d)"
cleanup() {
  rm -rf -- "$test_dir"
}
trap cleanup EXIT

source_file="$test_dir/native-smoke.el"
output_file="$test_dir/native-smoke.eln"
printf '%s\n' ';;; -*- lexical-binding: t; -*-' \
  '(defun emacs-pgtk-native-smoke () 42)' > "$source_file"

read -r -d '' test_form <<ELISP || true
(progn
  (unless (= emacs-major-version 31)
    (error "Expected Emacs 31, got %s" emacs-version))
  (unless (string-match-p "--with-pgtk" system-configuration-options)
    (error "PGTK is not compiled in"))
  (unless (and (fboundp 'native-comp-available-p)
               (native-comp-available-p))
    (error "Native compilation is unavailable"))
  (unless (and (fboundp 'treesit-available-p)
               (treesit-available-p))
    (error "Tree-sitter is unavailable"))
  (unless (and (fboundp 'sqlite-available-p)
               (sqlite-available-p))
    (error "SQLite is unavailable"))
  (unless (gnutls-available-p)
    (error "GnuTLS is unavailable"))
  (unless module-file-suffix
    (error "Dynamic modules are unavailable"))
  (unless (string= (json-serialize '((answer . 42))) "{\"answer\":42}")
    (error "Built-in JSON support failed"))
  (dolist (type '(png jpeg gif tiff svg webp))
    (unless (image-type-available-p type)
      (error "Image type %s is unavailable" type)))
  (native-compile "$source_file" "$output_file")
  (unless (file-exists-p "$output_file")
    (error "Native compilation did not create %s" "$output_file"))
  (princ "Emacs PGTK smoke test passed\n"))
ELISP

"$emacs_binary" --batch --quick --eval "$test_form"
"$emacs_binary" --version | head -n 1
