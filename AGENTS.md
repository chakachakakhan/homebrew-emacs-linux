# AGENTS.md

## Project

Maintain and improve `emacs-app-linux` for the Universal Blue Homebrew ecosystem.

Initial target:
- `ublue-os/homebrew-experimental-tap`

Promotion path:
1. UBlue experimental tap
2. UBlue main tap
3. Official Homebrew, if/when the package is sufficiently portable and mature

The package should be developed on UBlue first, but must avoid UBlue-specific runtime assumptions where possible.

## Goal

Ship a clean, modern, vanilla GNU Emacs Linux GUI package through Homebrew.

Current stable target: GNU Emacs 31.1 or newer stable 31.x if upstream has advanced.

Desired capabilities include:
- PGTK
- native compilation
- tree-sitter
- dynamic modules
- GnuTLS
- JSON/XML support
- common image formats
- `emacsclient`
- sensible Linux desktop integration

Do not add opinionated Emacs configuration, Doom/Spacemacs behavior, custom branding, or unnecessary downstream patches.

## Important Sources

Audit current upstream state before making design decisions:

- https://github.com/ublue-os/homebrew-experimental-tap
- https://github.com/ublue-os/homebrew-tap
- https://github.com/d12frosted/homebrew-emacs-plus
- GNU Emacs upstream source and build documentation
- Official Homebrew documentation and relevant Linux casks

Treat:
- UBlue taps as the packaging/convention reference
- Emacs Plus as an Emacs build/features reference
- GNU Emacs as the source of truth

## Existing Emacs Cask

The experimental tap already contains `emacs-app-linux.rb`.

Use it as a reference for:
- PGTK packaging
- desktop integration
- executable exposure
- `pdmp` handling
- Homebrew/Linux library path issues
- XDG integration

Do not preserve its current third-party binary dependency merely for compatibility.

In particular, do not rely on `daegalus/linux-app-builds` as the long-term source of Emacs binaries.

## Core Technical Question

Before rewriting the cask, determine the best sustainable source/build architecture.

Compare:

1. Building GNU Emacs release artifacts ourselves in CI
2. Building Emacs through Homebrew formula machinery
3. Consuming an official GNU/upstream Linux binary, if one suitable for Homebrew exists
4. Other reputable artifact sources only if clearly superior and sustainable

Prefer a clear provenance chain:

GNU Emacs release -> documented build recipe -> reproducible CI build -> release artifact -> SHA256 -> Homebrew cask

Do not assume a custom binary pipeline is required until the alternatives have been researched.

## Development Rules

- Inspect current repository conventions before editing.
- Prefer existing Homebrew/UBlue mechanisms over custom scripts.
- Prefer upstream-supported Emacs behavior.
- Keep patches to an absolute minimum.
- Do not hardcode Bluefin, Fedora, rpm-ostree, or immutable-OS behavior unless unavoidable.
- Prefer Homebrew/XDG abstractions over fixed paths.
- Avoid hardcoding `/home/linuxbrew/.linuxbrew` when a supported Homebrew variable can be used.
- Do not assume Emacs 30 configure flags or behavior are unchanged in Emacs 31.
- Verify claims through source, docs, repository history, or tests.
- Keep the implementation simple enough to maintain long-term.

## Cask Conventions

Keep the experimental package name `emacs-app-linux` unless repository research gives a strong reason to change it.

Match neighboring UBlue casks in:
- file structure
- architecture handling
- version/SHA256 fields
- `url`
- `livecheck`
- `depends_on`
- artifacts/binaries
- desktop integration
- uninstall cleanup
- testing style

Do not make the Emacs cask look structurally unique without a technical reason.

## Build Requirements

Research and document the exact Emacs 31.x build configuration.

Evaluate at least:
- PGTK
- native compilation/libgccjit
- tree-sitter
- GnuTLS
- dynamic modules
- libxml2
- librsvg
- WebP
- JPEG
- PNG
- GIF
- TIFF
- SQLite
- other optional dependencies only when useful

For every dependency, distinguish:
- build-time requirement
- runtime requirement
- optional feature
- portability consequence

Pay special attention to native compilation:
- whether users require GCC/libgccjit at runtime
- where `.eln` files are written
- how package native compilation behaves after installation

## Portability

Stage 1: prove on UBlue.

Then expand validation toward generic Linux/Homebrew environments.

Desired progression:
- Bluefin
- Aurora
- Bazzite
- Fedora
- Ubuntu
- Debian
- Arch or another materially different environment

Architectures:
- x86_64 first
- aarch64 when practical and supportable

Do not claim general Linux support based only on successful Bluefin testing.

## Testing

At minimum verify:
- installation
- `emacs --version`
- batch-mode execution
- GUI launch
- PGTK
- `emacsclient`
- native compilation
- tree-sitter
- package installation
- Git/SSH interaction where relevant
- desktop launcher
- icons
- uninstall/cleanup

Separate headless CI smoke tests from GUI/desktop integration tests.

Use existing UBlue/Homebrew test infrastructure before adding custom CI.

## Research Deliverables

Before major implementation, produce concise notes covering:
1. Experimental tap conventions and promotion workflow
2. Main tap conventions
3. Historical examples of experimental -> main promotion
4. Why the current Emacs cask is still experimental
5. Emacs Plus build lessons that are relevant on Linux
6. GNU Emacs 31.x build requirements
7. Recommended artifact/build architecture
8. Dependency matrix
9. Proposed cask design
10. Test and maintenance plan

Cite exact files, PRs, issues, commits, or upstream docs whenever practical.

## Git Workflow

Work on a feature branch.

Prefer small, reviewable commits.

Example sequence:
- audit current Emacs cask
- add/rework build pipeline
- update cask for maintained artifacts
- add desktop integration fixes
- add tests
- add architecture support

Do not rewrite unrelated files.

## Human Approval Boundary

The human maintainer owns project authority.

You may:
- research
- edit files
- build
- test
- prepare commits
- prepare PR text
- prepare release notes
- recommend repository settings

Do not perform irreversible or externally authoritative actions without explicit approval, including:
- pushing to upstream UBlue repositories
- merging PRs
- publishing releases
- changing repository permissions/secrets
- deleting branches/tags/releases
- making maintainer commitments on behalf of the human

When a change is ready, clearly report:
- files changed
- tests run
- known limitations
- exact commands the maintainer should run next

## Definition of Done: Experimental PR

A proposed experimental-tap update should not be called ready until:
- current stable GNU Emacs 31.x is used
- `daegalus/linux-app-builds` is no longer a required long-term dependency
- source/build provenance is documented
- x86_64 install works on UBlue
- PGTK works
- native compilation works
- tree-sitter works
- `emacs` and `emacsclient` work
- desktop launcher works
- uninstall works
- Homebrew audit/test results are known
- cask follows UBlue conventions
- update/maintenance path is documented
- no unnecessary UBlue-specific runtime hack remains

## Long-Term Standard

Design every decision so the project can progress:

UBlue experimental -> UBlue main -> generic Linux/Homebrew -> official Homebrew

The guiding principle is:

> Build a package that is proven on UBlue, but does not depend on UBlue being the reason it works.
