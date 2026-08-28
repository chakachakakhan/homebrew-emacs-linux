set shell := ["bash", "-cu"]

formula_ref := "local/emacs-linux/emacs-pgtk"

# Show the available project commands.
default:
    @just --list

# Run syntax, style, and shell checks without installing Emacs.
check:
    ./scripts/check-local.sh

# Build and install the local formula through Homebrew.
install:
    ./scripts/install-local.sh

# Test the installed formula, including a real native compilation.
smoke:
    ./scripts/smoke-test.sh "$(brew --prefix '{{formula_ref}}')/bin/emacs"

# Run the complete automated verification on an installed local build.
verify:
    brew test '{{formula_ref}}'
    ./scripts/smoke-test.sh "$(brew --prefix '{{formula_ref}}')/bin/emacs"
    brew linkage --test '{{formula_ref}}'
    brew audit --strict --formula '{{formula_ref}}'

# Package the installed formula as a local release candidate archive.
package:
    ./scripts/package-cask-artifact.sh

# Check the cask candidate without downloading a release asset.
cask-check:
    if [[ -f Casks/emacs-app-linux.rb ]]; then brew ruby -- -c Casks/emacs-app-linux.rb; else brew ruby -- -c proposals/Casks/emacs-app-linux.rb.example; fi

# Remove the formula; personal Emacs configuration is left untouched.
uninstall:
    brew uninstall '{{formula_ref}}'
