# GNU Emacs for Homebrew on Linux

Reproducible GNU Emacs 31.1 builds for Linux, with a fast binary cask and a
source formula for development.

Maintained by [Chaka Khan](https://github.com/chakachakakhan).

## Install

The binary cask is the normal installation path:

```bash
brew tap chakachakakhan/emacs-linux
brew install --cask emacs-app-linux
```

Homebrew 6 may ask you to trust a third-party tap before installation. Review
the tap first, then run:

```bash
brew trust --tap chakachakakhan/emacs-linux
```

Start Emacs with:

```bash
emacs
```

The current release targets Linux `x86_64` and `arm64`. It uses Emacs's PGTK
interface, which is primarily intended for Wayland and can also use GTK's X11
backend. GNU recommends the regular GTK/X build for systems that use X11
exclusively.

## What is included

- Native compilation through GCC and `libgccjit`
- Tree-sitter, dynamic modules, SQLite, GnuTLS, and XML support
- PNG, JPEG, GIF, TIFF, SVG, and WebP image support
- `emacs`, `emacsclient`, `ebrowse`, and `etags`
- Desktop launchers, icons, and man pages

The cask downloads a prepared release archive. Homebrew installs the shared
runtime libraries it needs, so users do not wait for Emacs to compile locally.
GCC and `libgccjit` remain runtime dependencies because Emacs can compile Lisp
after installation.

## Source builds

The formula is useful for development, feature changes, and systems where a
local build is preferred:

```bash
brew tap chakachakakhan/emacs-linux
brew install emacs-pgtk
```

This path builds GNU Emacs from source and therefore takes considerably longer
than the binary cask.

## Development

Run the fast checks first:

```bash
just check
just cask-check
```

Build and verify the source formula locally:

```bash
just install
just verify
```

Create a local cask release candidate from the installed formula:

```bash
just package
```

The release helper records the official GNU source URL and checksum in
`BUILD-MANIFEST.json`, removes Homebrew receipt metadata, creates the archive,
and writes its SHA-256 file. It does not publish anything.

## Releases

GitHub Actions builds the x86_64 and arm64 archives from the official GNU
Emacs source, runs headless and portability checks, and records build
provenance in each archive. A release is published only after the artifacts,
manifests, and checksums have been reviewed.

The cask displays the GNU Emacs version (`31.1`). An internal artifact revision
may appear in the immutable release URL when the same source version needs to
be rebuilt; it is not part of the user-facing Emacs version.

## Scope

Bluefin x86_64 is the primary validation environment. The project uses
standard Homebrew and XDG paths and avoids distribution-specific runtime
behavior, but support for additional distributions and architecture/desktop
combinations should be treated as work in progress until recorded in the test
plan.

This is vanilla GNU Emacs. It does not include custom configuration or a
preconfigured editing environment.

## Documentation

- [Architecture](docs/architecture.md) — build and packaging layout
- [Testing](docs/testing.md) — automated checks and validation evidence
- [Maintenance](docs/maintenance.md) — update, release, and rollback checklist
- [Release process](docs/release-process.md) — maintainer workflow
- [Contributing](CONTRIBUTING.md) — local development and pull requests
