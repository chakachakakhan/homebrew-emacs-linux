set shell := ["bash", "-cu"]

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
    ./scripts/smoke-test.sh "$(brew --prefix emacs-pgtk)/bin/emacs"

# Run the complete automated verification on an installed local build.
verify:
    brew test emacs-pgtk
    ./scripts/smoke-test.sh "$(brew --prefix emacs-pgtk)/bin/emacs"
    brew linkage --test emacs-pgtk
    brew audit --strict --formula emacs-pgtk

# Remove the formula; personal Emacs configuration is left untouched.
uninstall:
    brew uninstall emacs-pgtk
