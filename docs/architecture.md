# Architecture decision

## Recommendation

Use a Linux-only Homebrew formula as the first working and promotable package.
Keep `emacs-app-linux` as a future cask name, but do not publish that cask until
a portable prebuilt artifact exists and passes the cross-distribution matrix.

This is a staged decision, not abandonment of the cask goal:

```text
GNU Emacs 31.1 release + SHA-256
                  |
                  v
       Homebrew emacs-pgtk formula
                  |
          test-bot builds bottles
                  |
      UBlue and generic Linux tests
                  |
                  v
  decide whether the formula is sufficient
        or produce a proven portable artifact
                  |
                  v
        emacs-app-linux cask candidate
```

## Options considered

| Option | Result | Reason |
|---|---|---|
| Controlled prebuilt tarball | Defer | Correct long-term cask shape, but GTK/native-comp relocation and glibc compatibility are not yet proven |
| Homebrew source formula and bottles | Prototype now | Homebrew already manages dependencies, relocation, x86-64/ARM64 bottles, audit, and test-bot |
| Official GNU Linux binary | Unavailable | GNU 31.1 publishes source archives and signatures, not a supported Linux GUI binary |
| Other third-party binary | Reject for now | Reintroduces trust, cadence, and portability ownership unless that provider is demonstrably sustainable |

The formula is not chosen merely because it can compile Emacs. It is chosen
because it makes every runtime library an explicit Homebrew dependency and
lets Homebrew produce and relocate the binary package. A cask archive must
solve those same problems itself.

The formula conflicts with other Emacs packages and links normally, giving the
user an `emacs` command without a shell-profile edit. Emacs's compiled
GSettings database is kept under the formula's private `libexec/share` tree;
the `emacs` launcher prepends that tree to `XDG_DATA_DIRS` while preserving the
user's existing value. This avoids taking ownership of GLib's shared compiled
schema cache. AppStream metadata is omitted because it is not needed for a
Homebrew install and can cause a second shared-directory ownership collision.
The upstream desktop file and icons remain in standard linked XDG locations.

## Build behavior

The formula uses only released upstream source and makes no source changes.
`--disable-build-details` omits host names and timestamps that Emacs otherwise
records. Homebrew still controls the compiler and dependency versions, so the
build is reproducible in the practical package-manager sense, not yet a claim
of bit-for-bit reproducibility.

Before Emacs creates its portable dump, `lisp/site-load.el` removes Homebrew's
temporary compiler-shim directories from `exec-path`. This follows the current
homebrew-core Emacs formula and prevents a build-machine path from being
embedded in the installed `.pdmp` file. The local site-Lisp path is scoped to
this formula's own directory to avoid conflicts with other packages. A
post-install step removes the generic `site-lisp/subdirs.el` that upstream's
installer creates despite the scoped configuration.

PGTK is GTK 3 based. It is the preferred target for Wayland. GTK can select its
X11 backend, but GNU's own documentation recommends the regular GTK/X build
for users who exclusively use X11. The test plan therefore treats Wayland as
the primary GUI target and X11 as compatibility testing, not an identical
backend promise.

Native compilation has two distinct phases:

- During the build, `--with-native-compilation=aot` compiles the distributed
  Lisp files ahead of time.
- At runtime, users still need GCC and libgccjit so newly installed or changed
  Lisp packages can be compiled. They are therefore runtime dependencies and
  their library locations are included in the executable runpath.

## Dependency matrix

| Feature | Decision | Build/runtime provider | Reason and maintenance effect |
|---|---|---|---|
| PGTK | Required | `gtk+3` | Native Wayland GUI; GTK 3 is required by Emacs 31.1 PGTK |
| GTK-linked libraries | Required | `at-spi2-core`, `cairo`, `fontconfig`, `freetype`, `gdk-pixbuf`, `glib`, `harfbuzz`, `pango` | Emacs links these directly, so they are explicit dependencies rather than relying on GTK's dependency graph |
| Linux C ABI | Required | `glibc` | Keeps Homebrew-built GTK and related libraries on Homebrew's supported, non-mixed linker path |
| Native compilation | Required | `gcc`, `libgccjit` | AOT at build time and JIT for user packages at runtime; largest dependency burden |
| Tree-sitter | Required | `tree-sitter` | Modern parser integration; grammars remain separately installed by users |
| GnuTLS | Required | `gnutls` | Secure built-in network connections |
| XML | Required | `libxml2` | Built-in XML parsing |
| SQLite | Required | `sqlite` | Built-in database support used by modern packages |
| Dynamic modules | Required | compiler support | Lets Emacs load native extension modules |
| Cairo/HarfBuzz | Required | GTK dependency graph | Modern drawing and text shaping |
| SVG | Required | `librsvg` | Primary scalable image support |
| PNG/JPEG/GIF/TIFF/WebP | Required | corresponding Homebrew libraries | Common document and UI image formats |
| Little CMS | Required | `little-cms2` | Color management with modest burden |
| D-Bus | Required | `dbus` | Standard Linux desktop communication and notifications |
| ALSA | Enabled | `alsa-lib` | Normal Linux sound support; small incremental burden |
| Terminal interface | Required | `ncurses` | Emacs links it directly for terminal display support |
| JSON | Required, built in | Emacs | `--with-json` is not an Emacs 31.1 option; smoke-tested through `json-serialize` |
| ImageMagick | Disabled | none | Upstream disables it by default due to security/stability concerns; native image libraries cover the common formats |
| Xwidgets | Deferred | WebKitGTK if enabled | Very large dependency and security/update surface; not needed for a first stable editor |
| GPM | Disabled | none | Console mouse daemon is unnecessary for the GUI target |
| systemd library | Disabled | none | Avoids a distribution-specific runtime dependency; D-Bus remains enabled |
| ACL/xattr | Disabled | none | Avoids loading host `libattr` into a Homebrew-glibc build; not required for editor operation |
| SELinux/Smack | Disabled | none | Avoids tying the Homebrew build to one host security stack |

## Cask gate

The cask proposal in `proposals/Casks/emacs-app-linux.rb.example` defines the
expected archive contract and desktop artifacts. It intentionally contains
placeholder owner and checksums and is excluded from CI. Replacing those
placeholders is not enough to make it releasable. The artifact must also:

1. be built from the pinned GNU archive in a pinned environment;
2. include a machine-readable dependency/provenance manifest;
3. avoid absolute build-host and Homebrew-prefix references;
4. support runtime native compilation with Homebrew GCC/libgccjit;
5. pass `ldd`/runpath inspection and all smoke tests;
6. run on the listed UBlue and generic Linux systems;
7. have immutable release URLs and per-architecture SHA-256 values.
