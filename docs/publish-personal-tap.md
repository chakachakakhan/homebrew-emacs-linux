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

## 4. Test the published tap

On a machine without a local development tap for this project:

```bash
brew tap chakachakakhan/emacs-linux
brew install emacs-pgtk
brew test chakachakakhan/emacs-linux/emacs-pgtk
emacs --version
```

Then complete the unchecked interactive items in `docs/testing.md`. A green
GitHub Actions run is useful evidence, but it does not replace the Wayland,
desktop-launcher, clipboard, `emacsclient`, package, and uninstall checks.

## 5. Make later changes on a branch

Keep `main` as the version people can install. For later work:

```bash
git switch main
git pull --ff-only
git switch -c describe-the-change
```

Commit and test the branch, then merge it only after review. Do not use the
personal tap's `main` branch as a substitute for the future UBlue pull request.
