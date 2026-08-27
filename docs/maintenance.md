# Maintenance plan

## Release flow

1. Confirm a new stable Emacs release in the official
   [GNU archive](https://ftp.gnu.org/gnu/emacs/), including its detached
   signature.
2. Verify the signature locally using the documented GNU maintainer key and
   calculate SHA-256 independently. Do not copy a checksum from an untrusted
   release announcement.
3. Update `url`, `mirror`, and `sha256` in the formula.
4. Review the new release's `INSTALL`, `NEWS`, `PROBLEMS`, and `configure
   --help`; do not assume options are unchanged.
5. Build and run the full local Stage 1 checklist.
6. Push the update to the maintainer's personal fork and let both CI
   architectures finish.
7. Review logs and artifacts before opening any UBlue PR.
8. In the experimental tap, allow its existing bump/test-bot workflows to
   validate and bottle the formula. Do not add a competing release bot.
9. Publish only after human review of the diff and test evidence.

## Automation boundary

Automation should detect and propose routine version/checksum changes and run
tests. It should not silently publish a release, push to UBlue, or promote a
package. Emacs feature flags, new dependencies, PGTK changes, and native-comp
changes always require human review.

The standalone workflow in this repository has only `contents: read`; it cannot
create releases or modify the repository. That is intentional during personal
testing.

## Failure and rollback

- Keep the previous known-good formula commit and bottle available.
- If a release fails local or CI tests, do not weaken the test to make it green;
  inspect `config.log`, Homebrew linkage output, and the smoke-test failure.
- If an already-published experimental update is broken, revert the small
  version update or mark the package disabled with a clear reason. Coordinate
  the exact mechanism with UBlue maintainers.
- Never replace an artifact at an existing release URL. Publish a new build
  revision and new checksums.

## Human responsibilities

Tahir Khan remains responsible for GitHub authentication, repository/fork
ownership, pushes, pull requests, release approval, maintainer communication,
and the claim that a platform was tested. CI evidence supports that judgment;
it does not replace it.

