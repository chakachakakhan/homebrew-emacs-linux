# GNU Emacs PGTK for Homebrew on Linux

A personal Homebrew tap for vanilla GNU Emacs 31.1 on Linux, built with the
PGTK interface, native compilation, and tree-sitter.

## Status

The source formula is working and has been tested on Bluefin x86-64. The first
binary cask release is available for Linux x86-64 and ARM64, so normal
installation downloads a prepared build instead of compiling Emacs locally.

Release: [`emacs-31.1-1`](https://github.com/chakachakakhan/homebrew-emacs-linux/releases/tag/emacs-31.1-1)

The comma suffix in Homebrew's cask version is an artifact revision, not part
of the GNU Emacs version. This release contains GNU Emacs 31.1.

Broader Linux and desktop validation is still in progress. The source formula
remains available for development and for environments where building locally
is preferred.

## Install the source formula

The formula is useful for development and for systems where building from
source is preferred:

```bash
brew tap chakachakakhan/emacs-linux
brew trust --tap chakachakakhan/emacs-linux
brew install emacs-pgtk
```

Then run:

```bash
emacs
```

The source build is deliberately retained as the build recipe and fallback
path. It is not the intended end-user experience because a complete Emacs
build takes several minutes.

## Install the binary cask

Install the published binary cask with:

```bash
brew tap chakachakakhan/emacs-linux
brew trust --tap chakachakakhan/emacs-linux
brew install --cask emacs-app-linux
```

The archive contains the upstream desktop files, icons, portable dumper image,
command-line tools, and man pages. Homebrew supplies the shared runtime
libraries required by the prepared binary.

## Included features

- PGTK with Wayland support and GTK's X11 backend
- Native compilation through GCC and libgccjit
- Tree-sitter, dynamic modules, SQLite, GnuTLS, and XML support
- PNG, JPEG, GIF, TIFF, SVG, and WebP image support
- `emacs`, `emacsclient`, `ebrowse`, and `etags`
- Desktop files, icons, and man pages

## Build and test

Run checks that do not rebuild Emacs:

```bash
just check
```

Build and install the development formula locally:

```bash
just install
just verify
```

Package the installed formula as a local release candidate:

```bash
just package
```

The release helper records the GNU source URL and checksum in
`BUILD-MANIFEST.json`, removes Homebrew receipt metadata, creates the cask
archive, and writes a matching `.sha256` file. It does not publish anything.

## Packaging model

The formula is the source-build recipe and the cask is the fast binary
installation. GitHub Actions builds each architecture from the official GNU
Emacs source archive, records the source and build commit in the artifact
manifest, and uploads reviewable archives. Releases are published only after
the archives and checksums have been inspected.

The build is intended to remain vanilla GNU Emacs. It does not include Emacs
Plus patches, custom configuration, or distribution-specific runtime behavior.

## Documentation

- [`docs/architecture.md`](docs/architecture.md) — build and packaging layout
- [`docs/testing.md`](docs/testing.md) — automated checks and validation status
- [`docs/maintenance.md`](docs/maintenance.md) — release and update process
- [`docs/publish-personal-tap.md`](docs/publish-personal-tap.md) — distribution workflow
