# Test plan and evidence

Do not turn a planned test into a claimed test. Add the date, machine/image,
architecture, command, and result when a row is actually run.

## Automated repository checks

Fast syntax and style checks run on every push and pull request. The source
build workflow runs on changes to the formula, build scripts, or build
configuration, and can also be started manually.

## Automated headless checks

`scripts/smoke-test.sh` verifies:

- Emacs major version 31;
- the released build options include PGTK;
- native compilation is available and can create a real `.eln` file;
- tree-sitter, SQLite, GnuTLS, JSON, and dynamic modules are available;
- PNG, JPEG, GIF, TIFF, SVG, and WebP support can be loaded.

The source-build CI runs the formula build and smoke test on GitHub's x86-64
and ARM64 Ubuntu runners. A distribution-tap submission will additionally run
the target tap's `brew test-bot` workflow and produce bottle artifacts.

## Cask artifact checks

After `scripts/package-cask-artifact.sh` creates a local archive, inspect it
before using its checksum in the cask:

```bash
tar -tzf dist/emacs-pgtk-31.1-linux-x86_64.tar.gz
tar -xzf dist/emacs-pgtk-31.1-linux-x86_64.tar.gz -C /tmp
/tmp/emacs-pgtk-31.1-linux-x86_64/bin/emacs --batch --quick --eval \
  '(message "%s" emacs-version)'
```

Verify all of the following for each architecture:

- `BUILD-MANIFEST.json` parses and names the official GNU source checksum;
- the portable dumper image is present and the relative executable link works;
- no Homebrew receipt or SBOM is included in the payload;
- the launcher resolves its own archive path and preserves `XDG_DATA_DIRS`;
- the archive contains the four desktop files, six application icons, command
  binaries, and man pages;
- `readelf -d`/`ldd` show no missing runtime libraries;
- the headless smoke test, native compilation, and GUI launch pass;
- the archive works from a clean Caskroom path before publishing.

The release workflow produces reviewable assets but does not install or update
the cask automatically. The checked-in cask records the published release;
`proposals/` retains the placeholder template for preparing a later release.

## Stage 1: local Bluefin x86-64

- [x] `./scripts/check-local.sh`
- [x] build with `./scripts/install-local.sh`
- [x] `brew test local/emacs-linux/emacs-pgtk`
- [x] `./scripts/smoke-test.sh "$(brew --prefix local/emacs-linux/emacs-pgtk)/bin/emacs"`
- [x] `brew linkage --test local/emacs-linux/emacs-pgtk`
- [ ] `emacs -nw` starts and exits normally
- [x] `emacs` opens a PGTK frame on Wayland
- [ ] clipboard copy/paste in both directions
- [ ] font rendering and HiDPI scaling
- [ ] input method used by the tester
- [ ] file chooser and drag-and-drop
- [x] upstream desktop files and icons are installed
- [ ] desktop launcher appears and opens a file
- [x] `emacsclient` connects to an isolated Emacs daemon
- [ ] install a package and confirm run-time native compilation
- [ ] install and load one tree-sitter grammar
- [ ] Git subprocess works
- [ ] SSH/TRAMP smoke test works
- [x] uninstall removes linked Homebrew files without touching user configuration
- [x] reinstall succeeds from the still-tapped personal repository

Capture `M-x report-emacs-bug`'s build summary or evaluate
`system-configuration-options` when recording results.

### Recorded automated result: 2026-08-27

| Item | Environment | Result |
|---|---|---|
| Source and checksum | Official GNU Emacs 31.1 archive | SHA-256 matched `1da5790d9580c81932b5bf700633114468da7b3412d69faa767daebf974f4586` |
| Personal tap discovery | Local Git remote tapped as `chakachakakhan/emacs-linux` | Passed; Homebrew 6 required and accepted explicit `brew trust --tap` |
| Cask archive packaging | Same machine, x86-64 | Packaging and archive-structure checks passed; the final executable smoke test must be rerun after restoring the complete formula runtime dependency set |
| Source build/install | Bluefin 20260824 (`dakota-nvidia-gaming`), x86-64, Homebrew 6.0.19 | Passed through `brew install emacs-pgtk`; 6,009 files, 290.8 MB, approximately 6 minutes |
| Syntax and style | Same machine | Passed; ShellCheck was not installed and was explicitly skipped |
| Formula test | Same machine | Passed |
| Feature/native-compile smoke test | Same machine | Passed on GNU Emacs 31.1; created a real `.eln` file |
| Direct dependency linkage | Same machine | Passed |
| `brew audit --strict --formula` | Same machine | Passed |
| Embedded compiler-shim path check | Same machine | No absolute Homebrew shim directory found in the installed keg |
| Wayland GUI | Same machine, `XDG_SESSION_TYPE=wayland` | A real PGTK frame opened and exited cleanly; GTK printed a harmless missing `canberra-gtk-module` message requested by the host environment |
| `emacsclient` | Same machine | Connected to an isolated daemon and returned Emacs 31.1, native-comp available, and tree-sitter available |
| Desktop artifacts | Same machine | Upstream desktop files and hicolor PNG/SVG icons are installed; application-menu discovery and opening a file remain interactive tests |
| Uninstall/reinstall | Same machine | Uninstall removed the formula, linked executable, and linked desktop file; reinstall from `chakachakakhan/emacs-linux` passed and left Emacs installed |

The unchecked Stage 1 items require interactive use. In particular, Wayland
clipboard behavior, application-menu discovery, package installation, a real
tree-sitter grammar, Git, and TRAMP have not been claimed from this run.

## Stage 2: UBlue

| System | x86-64 | ARM64 | Wayland GUI | Headless | Status |
|---|---:|---:|---:|---:|---|
| Bluefin | tested | planned | short frame launch passed | automated passed | partial Stage 1 evidence |
| Aurora | planned | planned | planned | planned | not yet recorded |
| Bazzite | planned | planned | planned | planned | not yet recorded |

Not every architecture/system pair must be owned by one maintainer, but an
unsupported pair must be stated rather than implied.

## Stage 3: generic Linux

Test supported Homebrew configurations at minimum on current Fedora, Ubuntu
LTS, Debian stable, and Arch. For each, run the headless checks, GUI checks,
native compilation, desktop launch, upgrade, and uninstall.

For PGTK-on-X11 compatibility, test with `GDK_BACKEND=x11`. Record it
separately from the primary Wayland result because GNU documents limitations
and recommends the ordinary GTK/X build for X11-only systems.

## Formula distribution gate

- [ ] local stage complete with recorded evidence (automated portion passed;
  interactive portion remains)
- [ ] x86-64 CI green
- [ ] ARM64 CI green, or ARM64 explicitly scoped out with a reason
- [x] `brew audit` and `brew style` green locally
- [ ] test-bot produces installable bottles
- [x] no downstream source patch
- [ ] update and rollback procedure rehearsed
- [ ] maintainer commitment stated
- [ ] known PGTK/X11 limitations documented

## Release-backed cask gate

- [x] cask-shaped candidate follows current UBlue Linux cask structure
- [x] release workflow builds both Linux architectures
- [x] local archive helper records source provenance and emits checksums
- [x] first GitHub release assets published
- [x] per-architecture checksums copied into `Casks/emacs-app-linux.rb`
- [ ] cask installs from the published release without a source rebuild
- [ ] cask upgrade, GUI launch, `emacsclient`, and uninstall tested

## Cask gate (additional)

- [ ] immutable x86-64 and ARM64 release artifacts
- [ ] checksums reproduced locally
- [ ] no missing dynamic libraries on every target distribution
- [ ] no build-host paths in binaries, `.pdmp`, `.eln`, scripts, or desktop files
- [ ] archive works from a non-default Homebrew prefix in an unsupported-prefix
  test, even though official Linux Homebrew normally uses its default prefix
- [ ] runtime native compilation works from both terminal and desktop launcher
- [ ] cask install, upgrade, uninstall, reinstall, and zap tested
- [ ] artifact provenance and licenses shipped
