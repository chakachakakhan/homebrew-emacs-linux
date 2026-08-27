# Publish the personal tap

The public repository name must be:

```text
chakachakakhan/homebrew-emacs-linux
```

That repository name produces the shorter Homebrew tap name:

```text
chakachakakhan/emacs-linux
```

## 1. Review locally

From the prepared `homebrew-emacs-linux` folder:

```bash
git status
git log --oneline --decorate -5
just verify
```

Do not continue if a test fails or if the file list contains private material.

## 2. Create the GitHub repository

On GitHub, create a repository named `homebrew-emacs-linux` under the
`chakachakakhan` account. Leave “Add a README”, `.gitignore`, and license
unchecked because the prepared local repository already has tracked files.

Choosing a repository license is a maintainer decision. The Emacs source built
by the formula is GPL-3.0-or-later, but that does not automatically choose the
license for this tap's original scripts and documentation.

## 3. Add GitHub as the remote and push

Using HTTPS:

```bash
git remote add origin https://github.com/chakachakakhan/homebrew-emacs-linux.git
git push -u origin main
```

Or, if GitHub SSH authentication is already configured:

```bash
git remote add origin git@github.com:chakachakakhan/homebrew-emacs-linux.git
git push -u origin main
```

Run only one `git remote add origin` command. Pushing to the personal repository
does not submit anything to UBlue.

If Git rejects the push with `main -> main (fetch first)`, the GitHub
repository already contains a commit—usually because it was initialized with a
README, license, or `.gitignore`. Do not immediately force-push. Inspect it
with `git fetch origin` and `git log --oneline --graph --decorate --all -10`.
For a brand-new repository whose generated files are unwanted, the simplest
beginner-safe fix is to delete and recreate it empty; otherwise, merge the
remote work deliberately before pushing.

## 4. Test the published tap

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

Then complete the unchecked interactive items in `docs/testing.md`. A green
GitHub Actions run is useful evidence, but it does not replace the Wayland,
desktop-launcher, clipboard, `emacsclient`, package, and uninstall checks.

### Retest on this development machine

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

This rebuilds Emacs from the GitHub copy. It does not remove `~/.emacs.d`,
`~/.config/emacs`, or other personal Emacs configuration.

## 5. Produce the binary cask release

The cask is intentionally a separate publication step from the personal tap
formula. After reviewing the local formula and Stage 1 evidence:

1. Push the reviewed branch to the personal repository.
2. Run **Build Linux cask artifacts** from GitHub Actions with `31.1` and
   artifact revision `1` (or the values for the release being prepared).
3. Download and review both archives, their `BUILD-MANIFEST.json` files, the
   per-archive checksums, and the workflow smoke-test logs.
4. After that review, manually create the GitHub release with the immutable tag
   `emacs-31.1-1`, both archives, and a combined `SHA256SUMS` file.
5. Copy `proposals/Casks/emacs-app-linux.rb.example` to
   `Casks/emacs-app-linux.rb`, replace the checksum placeholders using
   `scripts/update-cask-checksums.sh`, and run `just cask-check`.

Do not submit the cask to UBlue until the release archive has been tested on
the intended systems. A source formula install and a successful archive build
do not by themselves prove cask portability.

## 6. Make later changes on a branch

Keep `main` as the version people can install. For later work:

```bash
git switch main
git pull --ff-only
git switch -c describe-the-change
```

Commit and test the branch, then merge it only after review. Do not use the
personal tap's `main` branch as a substitute for the future UBlue pull request.
