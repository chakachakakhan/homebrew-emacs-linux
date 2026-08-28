# Contributing

Thanks for helping improve GNU Emacs packaging on Linux.

## Before opening a pull request

Keep changes focused and work from a feature branch. For formula or cask
changes, run:

```bash
just check
just cask-check
```

If the source formula or release packaging changes, also run the relevant
commands from [Testing](docs/testing.md) and describe the environment and
result in the pull request.

Do not commit release archives or generated Homebrew build directories. The
release workflow creates artifacts separately and records their provenance in
the archive manifest.

## Cask changes

The cask is backed by immutable GitHub release assets. Do not reuse an existing
release tag or replace an asset in place. Verify both architecture checksums
and the archive contents before updating `Casks/emacs-app-linux.rb`.

The cask should remain easy to install, use standard Homebrew/XDG behavior,
and avoid user-specific Emacs configuration. Keep the user-facing version
equal to the GNU Emacs version; artifact rebuild details belong in the release
process and immutable URL.

## Submitting changes

Use a clear commit message, explain user-visible behavior, and include any
known platform limitations. A maintainer will review the change before it is
merged or submitted to a distribution tap.
