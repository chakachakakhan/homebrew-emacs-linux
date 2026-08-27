# Repository audit

Audit date: 2026-08-27.

The repositories were inspected at these exact revisions:

| Repository | Revision | Observation |
|---|---|---|
| [UBlue experimental tap](https://github.com/ublue-os/homebrew-experimental-tap) | `244b8bcec8973f29808f2b5e35487d46daee0657` | Maintainer-only staging tap; Linux x86-64 and ARM64 CI |
| [UBlue production tap](https://github.com/ublue-os/homebrew-tap) | `77d7ae9ecf48259340127d93694c06db16191879` | Production Linux casks and formulae |
| [Emacs Plus](https://github.com/d12frosted/homebrew-emacs-plus) | `d0baf34e06d9f17f2c3ba850c8995321802d3b74` | Useful macOS build reference, not a Linux dependency |
| [linux-app-builds](https://github.com/daegalus/linux-app-builds) | current default branch on audit date | Existing binary provider to replace |

## Experimental tap

The experimental README says the tap is for maintainers, provides no stability
or support promise, and directs stable packages to a PR against the production
tap. Its current `tests.yml` runs Homebrew `test-bot` on `ubuntu-24.04` and
`ubuntu-24.04-arm`, checks tap syntax and style, builds changed formulae, and
uploads bottle artifacts for pull requests. Its scheduled bump workflow uses
`brew bump` and opens update PRs.

The existing
[`emacs-app-linux.rb`](https://github.com/ublue-os/homebrew-experimental-tap/blob/244b8bcec8973f29808f2b5e35487d46daee0657/Casks/emacs-app-linux.rb)
is useful evidence of intended desktop integration, but it is not a sound base
for a release bump:

- it consumes `daegalus/linux-app-builds` rather than a GNU artifact;
- the archive is labeled `fedora-latest`, so its ABI floor moves with Fedora;
- it patches the downloaded launcher during installation;
- it hard-codes `/home/linuxbrew/.linuxbrew` repeatedly;
- it copies a compiled GSettings database from the build host into a user's
  data directory;
- its upstream build has the headless smoke test commented out;
- its upstream build claims distribution independence without bundling or
  otherwise proving all dynamic dependencies;
- that build passes `--with-json`, which is not an Emacs 31.1 configure option;
- it exports `DISPLAY=:0` for Wayland sessions, which is not required for PGTK
  and can select the wrong display;
- it exposes `ctags`, but Emacs 31.1 no longer installs that executable.

The current tap CI is good enough to validate a formula contribution. A second
copy of the tap's test-bot workflow should not be added to the tap itself.

## Production tap and promotion evidence

Promotion is a normal pull-request process, not an automated state transition.
The clearest recent examples are:

- [Antigravity production PR #199](https://github.com/ublue-os/homebrew-tap/pull/199)
  added the tested cask; [experimental PR #126](https://github.com/ublue-os/homebrew-experimental-tap/pull/126)
  then removed the promoted copy.
- [ROG Control Center production PR #378](https://github.com/ublue-os/homebrew-tap/pull/378)
  promoted the cask; [experimental PR #348](https://github.com/ublue-os/homebrew-experimental-tap/pull/348)
  removed it from staging.
- Zed was added to production in
  [PR #451](https://github.com/ublue-os/homebrew-tap/pull/451) and later removed
  from experimental in
  [PR #572](https://github.com/ublue-os/homebrew-experimental-tap/pull/572).

In these examples, the package definition was effectively moved once it had a
working upstream artifact and normal update path. The repository history does
not expose a formal minimum soak time or download count. For Emacs, the larger
dependency and native-compilation surface justifies stricter project-specific
gates than these simpler upstream-binary casks needed.

Representative production casks such as
[`zed-linux.rb`](https://github.com/ublue-os/homebrew-tap/blob/77d7ae9ecf48259340127d93694c06db16191879/Casks/zed-linux.rb)
and
[`vscodium-linux.rb`](https://github.com/ublue-os/homebrew-tap/blob/77d7ae9ecf48259340127d93694c06db16191879/Casks/vscodium-linux.rb)
consume binaries released by the application vendor. They use Homebrew's
`HOMEBREW_PREFIX` and, in newer examples, XDG variables rather than assuming a
particular user's home layout. That model cannot be copied directly for Emacs
because GNU does not publish an equivalent Linux GUI artifact.

## GNU Emacs 31.1

GNU published Emacs 31.1 on 2026-08-24. The official archive and signature are
listed in the [GNU FTP index](https://ftp.gnu.org/gnu/emacs/). The SHA-256 of
`emacs-31.1.tar.xz` is:

```text
1da5790d9580c81932b5bf700633114468da7b3412d69faa767daebf974f4586
```

That matches the current official
[`homebrew-core` Emacs formula](https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/e/emacs.rb).
Homebrew already bottles Emacs 31.1 for x86-64 and ARM64 Linux, but the core
formula deliberately configures Linux with `--without-x`; it is not the desired
PGTK GUI build.

The released `INSTALL` file says PGTK uses GTK 3 and can select Wayland, X11,
or Broadway via `GDK_BACKEND`. It also explicitly says that an ordinary GTK/X
build is better for an X11-only system. Therefore “PGTK supports X11” is true,
but “PGTK is the best X11 build” is not.

## Emacs Plus

Emacs Plus 31 confirms several useful implementation details:

- the same official Emacs 31.1 source checksum is used;
- GCC and libgccjit are runtime dependencies for just-in-time native
  compilation, not merely build dependencies;
- its formula embeds the GCC library location in the executable runpath;
- modern Emacs has native support for common image formats, so ImageMagick is
  optional and is avoided by default;
- Emacs 31 no longer exposes `ctags`.

Its patches, Cocoa application layout, path injection, icons, and macOS release
bundling are intentionally not copied. They solve a different platform's
problems and would violate this project's vanilla-Emacs goal.

## Homebrew model

Homebrew describes a cask as a package definition for a precompiled binary and
a formula as a source build. See the
[`homebrew-cask` overview](https://github.com/Homebrew/homebrew-cask) and
[`Formula Cookbook`](https://docs.brew.sh/Formula-Cookbook). Given the absence
of a GNU Linux binary, the formula in this repository is the smallest design
whose dependency resolution, relocation, bottle creation, and testing are all
handled by existing Homebrew mechanisms.

