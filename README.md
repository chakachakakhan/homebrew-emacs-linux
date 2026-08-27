# GNU Emacs PGTK for Homebrew on Linux

Personal Homebrew packaging work for a vanilla GNU Emacs 31.1 build with the
PGTK interface, native compilation, and tree-sitter on Linux.

Maintainer: [Tahir Khan](https://github.com/chakachakakhan)

## Project status

The source formula is working and tested locally on Bluefin x86-64. The next
iteration moves the user-facing install path to a release-backed cask so users
download a prepared build instead of compiling Emacs during installation.

The cask candidate is intentionally kept under [`proposals/`](proposals/) until
the release workflow has produced and verified immutable x86-64 and ARM64
archives. This repository does not claim that the cask is ready for UBlue yet.

## Current install path

The working development package is a Homebrew formula:

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

## Planned cask path

After release assets and checksums are reviewed, the cask will provide:

```bash
brew tap chakachakakhan/emacs-linux
brew install --cask emacs-app-linux
```

The cask archive contains the upstream desktop files, icons, portable dumper
image, command-line tools, and man pages. It declares the formula’s full
non-build runtime dependency set so Homebrew supplies the GTK, image, network,
database, and native-compilation libraries required by the prepared binary.

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

## Design principles

- Build from the official GNU Emacs release archive.
- Keep Emacs vanilla: no Emacs Plus patches, custom configuration, branding,
  or UBlue-specific runtime behavior.
- Use the existing Homebrew formula machinery for dependency resolution and
  CI builds.
- Use a cask only for immutable, checksummed release artifacts.
- Treat Bluefin as the first validation environment, not as the package’s
  permanent dependency.
- Keep release publication and UBlue pull requests under maintainer review.

See [`docs/architecture.md`](docs/architecture.md) for the decision record,
[`docs/testing.md`](docs/testing.md) for evidence and remaining gates, and
[`docs/maintenance.md`](docs/maintenance.md) for the update and release flow.
