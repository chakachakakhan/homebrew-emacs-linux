# Release process

This repository publishes the `chakachakakhan/emacs-linux` Homebrew tap. The
GitHub repository is `chakachakakhan/homebrew-emacs-linux`.

## Review locally

From the repository root:

```bash
git status
git log --oneline --decorate -5
just check
just cask-check
```

For source-formula changes, also run `just install` and `just verify`. Record
the machine, architecture, Homebrew version, and result when reporting test
evidence.

## Publish a binary release

1. Update and test the source formula for the new stable GNU Emacs release.
2. Run **Build Linux cask artifacts** from GitHub Actions with the GNU version
   and the next internal artifact revision.
3. Download both architecture artifacts and inspect the archives, manifests,
   checksums, linker output, and workflow smoke-test logs.
4. Create an immutable GitHub release tagged
   `emacs-<version>-<artifact-revision>` with both archives and a combined
   `SHA256SUMS` file.
5. Update `Casks/emacs-app-linux.rb` with the reviewed checksums and release
   revision. The cask still reports only the GNU version to users.
6. Run `just check`, `just cask-check`, and the published cask install,
   launch, `emacsclient`, upgrade, and uninstall tests.

Never replace an archive at an existing release tag. If the source version is
unchanged but the archive changes, increment the internal artifact revision
and publish a new immutable release.

## Distribution-tap submissions

The initial submission to a UBlue tap is a contributor or maintainer pull
request. UBlue's scheduled Homebrew Bump workflow can open update pull
requests for packages that Homebrew can discover, and its test/publish
workflows validate and merge approved paths. That automation does not build or
publish this repository's custom Emacs artifacts, decide whether a rebuild is
needed, or remove the maintainer's responsibility for the cask update.

For each Emacs release, provide reviewers with the immutable release URL,
architecture checksums, source provenance, test results, and a short note
explaining how the next update will be maintained.

## Local tap testing

To test the published tap rather than a local checkout:

```bash
brew uninstall --formula emacs-pgtk 2>/dev/null || true
brew uninstall --cask emacs-app-linux 2>/dev/null || true
brew untap chakachakakhan/emacs-linux 2>/dev/null || true
brew tap chakachakakhan/emacs-linux
brew trust --tap chakachakakhan/emacs-linux
brew install --cask emacs-app-linux
```

Do not remove `~/.emacs.d` or `~/.config/emacs`; uninstalling the package
should leave user configuration untouched.
