# GNU Emacs PGTK for Homebrew on Linux

This is the personal Homebrew tap for a pre-publication prototype of vanilla
GNU Emacs 31.1 with its PGTK interface on Linux.

## Install from the personal tap

Once `chakachakakhan/homebrew-emacs-linux` is published on GitHub:

```bash
brew tap chakachakakhan/emacs-linux
brew trust --tap chakachakakhan/emacs-linux
brew install emacs-pgtk
```

Homebrew 6 requires the explicit trust step before it will load a formula from
a non-official tap. Trusting is a local decision stored in Homebrew's user
configuration; it does not grant this repository access to your machine or
GitHub account.

Then start the GUI with:

```bash
emacs
```

The GitHub repository must be named `homebrew-emacs-linux`. Homebrew removes
the `homebrew-` prefix when it forms the tap name
`chakachakakhan/emacs-linux`.

Nothing here has been pushed, published, or submitted upstream. The working
implementation is deliberately a Homebrew **formula**, because GNU currently
publishes Emacs source code but no supported portable Linux GUI binary. A cask
is included only as a reviewed proposal in `proposals/`; it must not be shipped
until a relocatable artifact has passed the portability tests in
[`docs/testing.md`](docs/testing.md).

## What is implemented

- GNU Emacs 31.1 from the official GNU release archive and pinned SHA-256
- GTK 3 PGTK build for native Wayland and GTK's other supported backends
- ahead-of-time and run-time native compilation through GCC/libgccjit
- tree-sitter, GnuTLS, XML, SQLite, dynamic modules, Cairo, HarfBuzz, SVG,
  WebP, PNG, JPEG, GIF, TIFF, Little CMS, D-Bus, and ALSA support
- no Emacs Plus patches, custom configuration, branding, or UBlue-only paths
- a headless smoke test that checks the promised features and performs an
  actual native compilation
- a normal `emacs` command and upstream desktop launcher without shell-profile
  edits or shared GSettings-cache overwrites
- read-only GitHub Actions checks on x86-64 and ARM64 Linux runners

## Current status

This is a development prototype, not an experimental-tap submission yet. On
2026-08-27, the personal-tap source install, automated checks, a real PGTK
Wayland frame launch, and an isolated `emacsclient` round trip passed on
Bluefin 20260824 x86-64 with Homebrew 6.0.19. Clipboard, menu discovery, and
the other unchecked interactive tests remain unclaimed. This one-machine
result does not prove Aurora/Bazzite coverage, ARM64 behavior, or generic Linux
portability.

The research and decision record is in:

- [`docs/repository-audit.md`](docs/repository-audit.md)
- [`docs/architecture.md`](docs/architecture.md)
- [`docs/testing.md`](docs/testing.md)
- [`docs/maintenance.md`](docs/maintenance.md)

## Local checks

First run the fast checks, which do not install anything:

```bash
./scripts/check-local.sh
```

Homebrew requires formulae to live in a tap. This helper copies the recipe to a
local-only test tap, then builds and installs it:

```bash
./scripts/install-local.sh
```

Then verify the installed editor:

```bash
./scripts/smoke-test.sh "$(brew --prefix emacs-pgtk)/bin/emacs"
```

If you have `just`, the full already-installed verification is:

```bash
just verify
```

Launch the GUI on Wayland:

```bash
emacs
```

Launch in the terminal (also useful without a display server):

```bash
emacs -nw
```

Remove the prototype without deleting your Emacs configuration:

```bash
brew uninstall emacs-pgtk
brew untap chakachakakhan/emacs-linux
```

For the local-only development helper, untap `local/emacs-linux` instead.

Homebrew's default Linux prefix is `/home/linuxbrew/.linuxbrew`, but the recipe
does not hard-code it. Homebrew supplies the active prefix when it builds and
relocates a bottle.

## Before publishing

Read [`docs/testing.md`](docs/testing.md) and record real results. In
particular, do not claim that the cask, ARM64, X11, or a distribution has been
tested unless it actually has been tested there.

The first GitHub publication steps are documented in
[`docs/publish-personal-tap.md`](docs/publish-personal-tap.md).
