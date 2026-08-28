# Release and maintenance

## Release checklist

1. Confirm the next stable GNU Emacs release and verify its detached signature
   using the documented GNU maintainer key.
2. Update the source URL, mirror, checksum, and build options in
   `Formula/emacs-pgtk.rb` after reviewing that release’s `INSTALL`, `NEWS`,
   `PROBLEMS`, and `configure --help`.
3. Run the local formula checks and the complete Stage 1 test plan.
4. Run the manually triggered `Build Linux cask artifacts` workflow. It builds
   x86-64 and ARM64 assets with fixed portable compiler targets, records
   provenance, and uploads the archives and checksums as workflow artifacts.
   It does not publish a release.
5. Download and review the archives, manifests, dynamic-linker output, and
   smoke-test results. Create the GitHub release manually only after that
   review, using the immutable tag `emacs-<version>-<artifact-revision>` and
   both architecture archives plus a combined `SHA256SUMS` file.
6. Copy the reviewed per-architecture checksums into `Casks/emacs-app-linux.rb`
   and update its internal `artifact_revision`. The cask's public version
   remains the GNU version; `scripts/update-cask-checksums.sh` handles the
   checksum replacement.
7. Run cask style/audit and install, upgrade, launch, and uninstall tests from
   the published release.
8. Submit the cask to the target tap with the test evidence and a concise
   maintenance note.

The artifact revision is deliberately separate from the cask's public version.
Increment it when the source version is unchanged but the release archive or
build recipe changes. Never replace an existing release asset or tag.

## Automation

The workflow is manually dispatched and does not run on every push. It builds
and uploads reviewable artifacts but does not publish a GitHub release, push to
UBlue, open pull requests, or silently change the cask checksum.

The UBlue experimental and main taps run scheduled Homebrew Bump workflows.
Those workflows can open update pull requests when Homebrew can discover a
package's upstream version, and their test/publish workflows validate approved
changes. They do not build or publish this repository's custom Emacs assets,
so a maintainer still needs to make and review each release artifact, update
the cask, and submit the distribution-tap pull request.

Changes to Emacs feature flags, dependencies, PGTK behavior, and native
compilation require maintainer review even when an automated bump is possible.

## Failure and rollback

- Never replace files at an existing release URL or tag.
- If a build fails, inspect the build log, linker output, manifest, and smoke
  test instead of weakening the check.
- Treat a failed CPU portability check as a release blocker. Do not solve it
  by asking users to run a different launcher or by assuming that a newer CPU
  is representative of the release audience.
- Keep the last known-good cask checksum and release available while testing a
  new artifact revision.
- If an experimental-tap update is broken, prepare a small revert or disable
  change for maintainer review; do not hide the failure in the test suite.

## Maintainer responsibilities

The maintainer is responsible for release publication, repository settings,
distribution submissions, communication with reviewers, and claims about
platforms that were tested. CI produces evidence; it does not replace those
decisions.
