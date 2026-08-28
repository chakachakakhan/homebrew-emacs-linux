# Development and release workflow

This repository publishes the `chakachakakhan/emacs-linux` Homebrew tap.
The GitHub repository is:

```text
chakachakakhan/homebrew-emacs-linux
```

That repository name produces the shorter Homebrew tap name:

```text
chakachakakhan/emacs-linux
```

## Review locally

From the repository root:

```bash
git status
git log --oneline --decorate -5
just verify
```

## Test the published formula

On a machine without a local development tap for this project:

```bash
brew update
brew tap chakachakakhan/emacs-linux
brew trust --tap chakachakakhan/emacs-linux
brew install emacs-pgtk
brew test chakachakakhan/emacs-linux/emacs-pgtk
emacs --version
```

Homebrew 6 deliberately requires the trust command for a formula from a
non-official tap. Read the repository before trusting it. The trust entry is
stored in your local Homebrew configuration and can be inspected with
`brew trust --json=v1`.

Then complete the interactive items in [`testing.md`](testing.md). A green
GitHub Actions run is useful evidence, but it does not replace the Wayland,
desktop-launcher, clipboard, `emacsclient`, package, and uninstall checks.

### Retest after changing the formula

During preparation, this machine tapped the local repository folder under the
public tap name. After the GitHub push, replace that local tap with the real
GitHub tap before claiming the published install was tested:

```bash
brew uninstall emacs-pgtk
brew untap chakachakakhan/emacs-linux
brew tap chakachakakhan/emacs-linux
brew trust --tap chakachakakhan/emacs-linux
brew install emacs-pgtk
just verify
```

This rebuilds Emacs from the GitHub copy. It does not remove personal Emacs
configuration such as `~/.emacs.d` or `~/.config/emacs`.

## Produce the binary cask release

The cask is intentionally a separate publication step from the personal tap
formula. After reviewing the local formula and Stage 1 evidence:

1. Push the reviewed branch to this repository.
2. Run **Build Linux cask artifacts** from GitHub Actions with the pinned GNU
   Emacs version and the next artifact revision for the release being
   prepared.
3. Download and review both archives, their `BUILD-MANIFEST.json` files, the
   per-archive checksums, and the workflow smoke-test logs.
4. After that review, manually create the GitHub release with the immutable tag
   `emacs-<version>-<artifact-revision>`, both archives, and a combined
   `SHA256SUMS` file.
5. Copy `proposals/Casks/emacs-app-linux.rb.example` to
   `Casks/emacs-app-linux.rb`, replace the checksum placeholders using
   `scripts/update-cask-checksums.sh`, and run `just cask-check`.

Do not submit the cask to a distribution tap until the release archive has been
tested on the intended systems. A source formula install and a successful
archive build do not by themselves prove cask portability.

## Make later changes on a branch

Keep `main` as the version people can install. For later work:

```bash
git switch main
git pull --ff-only
git switch -c describe-the-change
```

Commit and test the branch, then merge it only after review.
