# Release and maintenance

## Release checklist

1. Confirm the next stable GNU Emacs release and verify its detached signature
   using the documented GNU maintainer key.
2. Update the source URL, mirror, checksum, and build options in
   `Formula/emacs-pgtk.rb` after reviewing that release’s `INSTALL`, `NEWS`,
   `PROBLEMS`, and `configure --help`.
3. Run the local formula checks and the complete Stage 1 test plan.
4. Run the manually triggered `Build Linux cask artifacts` workflow. It builds
   x86-64 and ARM64 assets, records provenance, and uploads the archives and
   checksums as workflow artifacts. It does not publish a release.
5. Download and review the archives, manifests, dynamic-linker output, and
   smoke-test results. Create the GitHub release manually only after that
   review, using the immutable tag `emacs-<version>-<artifact-revision>` and
   both architecture archives plus a combined `SHA256SUMS` file.
6. Copy the reviewed per-architecture checksums into the cask candidate and
   move it to `Casks/emacs-app-linux.rb`. The mechanical replacement can be
   checked with `scripts/update-cask-checksums.sh`.
7. Run cask style/audit and install, upgrade, launch, and uninstall tests from
   the published release.
8. Submit the cask to the target tap with the test evidence and a concise
   maintenance note.

The cask’s artifact revision is separate from the GNU version. Increment it
when the source version is unchanged but the release archive or build recipe
changes.

## Automation

The workflow is manually dispatched and does not run on every push. It builds
and uploads reviewable artifacts but does not publish a GitHub release, push to
UBlue, open pull requests, or silently change the cask checksum.

Routine version detection and checksum updates can be automated later. Changes
to Emacs feature flags, dependencies, PGTK behavior, and native compilation
require maintainer review.

## Failure and rollback

- Never replace files at an existing release URL or tag.
- If a build fails, inspect the build log, linker output, manifest, and smoke
  test instead of weakening the check.
- Keep the last known-good cask checksum and release available while testing a
  new artifact revision.
- If an experimental-tap update is broken, prepare a small revert or disable
  change for maintainer review; do not hide the failure in the test suite.

## Maintainer responsibilities

The maintainer is responsible for release publication, repository settings,
distribution submissions, communication with reviewers, and claims about
platforms that were tested. CI produces evidence; it does not replace those
decisions.
