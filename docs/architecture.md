# Architecture decision

## Decision

Use two deliberately separate layers:

1. `Formula/emacs-pgtk.rb` is the reproducible source-build recipe and the
   development fallback.
2. `emacs-app-linux` is a binary cask backed by immutable release archives
   built from that recipe.

This preserves Homebrew’s dependency and test machinery while removing the
multi-minute source build from the normal installation path.

```text
GNU Emacs release archive
          |
          v
Homebrew source-build recipe
          |
          v
GitHub Actions: x86_64 + ARM64
          |
          v
checksummed release archives
          |
          v
emacs-app-linux cask
```

The cask candidate is not copied into a tap until both architecture archives
exist, their checksums are independently reviewed, and the archive contract
has passed the portability tests in [`testing.md`](testing.md).

## Options considered

| Option | Decision | Reason |
|---|---|---|
| Homebrew source formula | Keep as the build recipe | Homebrew already resolves dependencies, builds bottles, and tests formulas; installation is slow from source |
| Controlled release artifacts | Use for the cask | Makes the normal install fast while retaining a clear GNU source-to-artifact provenance chain |
| Official GNU Linux binary | Not available for this target | GNU publishes the source release and signatures, not a supported portable PGTK Linux binary |
| `daegalus/linux-app-builds` | Do not use | The provider and Fedora-labelled ABI are outside this repository’s maintenance control |
| Emacs Plus | Reference only | It is a macOS packaging project; its patches and application layout do not belong in vanilla Linux Emacs |

## Artifact contract

Each release archive has a root named like:

```text
emacs-pgtk-31.1-linux-x86_64/
```

It contains the installed Emacs tree, a self-locating `bin/emacs` launcher,
the portable dumper image beside the versioned executable, command-line tools,
man pages, desktop files, icons, and:

```text
share/emacs-pgtk/BUILD-MANIFEST.json
```

The manifest records the GNU source URL and checksum, the recipe path, the
Emacs version, artifact revision, build platform, and source commit. Homebrew
receipt/SBOM files are excluded because they describe the builder’s formula
keg, not the cask payload.

The release workflow produces a `.tar.gz` and matching `.sha256` file for each
architecture. The cask’s `version` uses the normal Homebrew comma form:
`31.1,1`, while the GitHub release tag is `emacs-31.1-1`.

## Runtime model

The artifact does not copy a compiled GSettings cache into a user directory.
The launcher prepends its private schema directory to `XDG_DATA_DIRS` and
sets Emacs’s data, executable, documentation, and load paths relative to the
installed archive. Desktop files are rewritten at cask install time to use
the active `HOMEBREW_PREFIX`.

The cask declares the formula's non-build dependencies, including GTK,
GnuTLS, image libraries, XML, SQLite, and the native-compilation toolchain.
The release archive deliberately does not vendor those shared libraries, so
the cask remains a normal Homebrew binary installation with Homebrew-managed
runtime versions. GCC/libgccjit are runtime requirements, not merely build
requirements: Emacs uses them when a user installs or changes
native-compilable Lisp. Tree-sitter provides the runtime parser library;
language grammars remain user-installed libraries.

The first artifact build uses Homebrew’s Linux toolchain, so the initial
portability target is the standard Linux Homebrew prefix used by UBlue. An
arbitrary-prefix and cross-distribution test remains a release gate; this is
why the cask candidate is not yet an experimental-tap submission.

## Build configuration

The formula uses released GNU Emacs source with no downstream source patches.
The selected 31.1 configuration is:

| Feature | Decision | Provider | Reason |
|---|---|---|---|
| PGTK | Enabled | `gtk+3` | Native Linux GUI; primary Wayland target |
| Native compilation | Enabled, AOT | `gcc`, `libgccjit` | Fast built-in Lisp and runtime package compilation |
| Tree-sitter | Enabled | `tree-sitter` | Modern parser integration |
| GnuTLS | Enabled | `gnutls` | Secure network connections |
| XML | Enabled | `libxml2` | Built-in XML parsing |
| SQLite | Enabled | `sqlite` | Database support used by modern packages |
| Dynamic modules | Enabled | compiler/runtime support | Native extension modules |
| SVG | Enabled | `librsvg` | Scalable image support |
| PNG/JPEG/GIF/TIFF/WebP | Enabled | corresponding libraries | Common document and UI formats |
| Little CMS | Enabled | `little-cms2` | Color management |
| D-Bus | Enabled | `dbus` | Desktop communication |
| ALSA | Enabled | `alsa-lib` | Linux sound support |
| ImageMagick | Disabled | — | Avoids a large security and update surface; native image libraries cover common formats |
| Xwidgets | Deferred | WebKitGTK | Large optional dependency; not needed for the first package |
| GPM/systemd/SELinux/Smack/ACL/xattr | Disabled | — | Avoids unnecessary host-specific runtime coupling |

JSON is built into Emacs 31.1 and is tested through `json-serialize`; it is
not passed as a configure option.

## Why the old cask was not copied

The existing UBlue cask is a useful packaging reference, but its launcher
patches hardcode `/home/linuxbrew/.linuxbrew`, labels the artifact
`fedora-latest`, copies `gschemas.compiled` into a user directory, and exposes
the obsolete `ctags` executable. The candidate keeps its useful architecture,
binary, manpage, desktop, icon, and livecheck shape while moving build
ownership into this repository and avoiding those runtime hacks.
