#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
emacs_version="${EMACS_VERSION:-31.1}"
artifact_revision="${ARTIFACT_REVISION:-1}"
output_dir="${1:-$repo_root/dist}"
formula_ref="${EMACS_FORMULA_REF:-local/emacs-linux/emacs-pgtk}"
formula_prefix="${EMACS_FORMULA_PREFIX:-$(brew --prefix "$formula_ref")}"
source_url="$(sed -n 's/^[[:space:]]*url "\([^"]*\)"/\1/p' "$repo_root/Formula/emacs-pgtk.rb" | head -n 1)"
source_sha256="$(sed -n 's/^[[:space:]]*sha256 "\([0-9a-f]\{64\}\)"/\1/p' "$repo_root/Formula/emacs-pgtk.rb" | head -n 1)"
build_commit="${GITHUB_SHA:-$(git -C "$repo_root" rev-parse HEAD)}"
build_platform="${BUILD_PLATFORM:-$(uname -s)-$(uname -m)}"
compiler_target="${HOMEBREW_ARCH:-native}"

if [[ ! -d "$formula_prefix" ]]; then
  echo "Emacs formula prefix does not exist: $formula_prefix" >&2
  echo "Install $formula_ref first, or set EMACS_FORMULA_PREFIX." >&2
  exit 1
fi

case "${ARTIFACT_ARCH:-$(uname -m)}" in
  x86_64|amd64)
    artifact_arch="x86_64"
    ;;
  aarch64|arm64)
    artifact_arch="arm64"
    ;;
  *)
    echo "Unsupported artifact architecture: ${ARTIFACT_ARCH:-$(uname -m)}" >&2
    exit 1
    ;;
esac

archive_root="emacs-pgtk-${emacs_version}-linux-${artifact_arch}"
work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
stage_dir="$work_dir/$archive_root"
mkdir -p "$stage_dir" "$output_dir"
cp -a "$formula_prefix/." "$stage_dir/"

real_emacs="$stage_dir/bin/emacs-${emacs_version}"
if [[ ! -x "$real_emacs" ]]; then
  echo "Expected Emacs executable is missing: $real_emacs" >&2
  exit 1
fi

# Homebrew's formula receipt and SBOM describe the build keg, not the cask
# payload. Keep the upstream license and runtime files, but leave Homebrew
# installation metadata behind.
rm -rf -- "$stage_dir/.brew"
rm -f -- \
  "$stage_dir/INSTALL_RECEIPT.json" \
  "$stage_dir/sbom.spdx.json"

# The formula installs a Homebrew-specific user service whose unit file points
# back into the build keg. It is not part of the cask contract, so do not ship
# a stale service definition that would appear usable after extraction.
rm -rf -- "$stage_dir/lib/systemd"

pdmp_file="$(find "$stage_dir/libexec/emacs/$emacs_version" -type f -name '*.pdmp' -print -quit)"
if [[ -z "$pdmp_file" ]]; then
  echo "No portable dumper image was found under $stage_dir/libexec." >&2
  exit 1
fi
target_triplet="$(basename "$(dirname "$pdmp_file")")"
ln -sfn \
  "../libexec/emacs/$emacs_version/$target_triplet/$(basename "$pdmp_file")" \
  "$stage_dir/bin/emacs-${emacs_version}.pdmp"

# The installed formula launcher points into the build keg. Replace it with a
# self-locating launcher that works from the Caskroom and adds only the Homebrew
# runtime directories needed by native compilation and tree-sitter.
rm -f -- "$stage_dir/bin/emacs"
cat > "$stage_dir/bin/emacs" <<EOF
#!/usr/bin/env bash
set -euo pipefail

script_path="\${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
  script_path="\$(readlink -f -- "\$script_path")"
fi
root_dir="\$(cd -- "\$(dirname -- "\$script_path")/.." && pwd)"
brew_prefix="\${HOMEBREW_PREFIX:-}"
if [[ -z "\$brew_prefix" ]] && command -v brew >/dev/null 2>&1; then
  brew_prefix="\$(brew --prefix)"
fi

library_paths=()
for directory in \
  "\$brew_prefix/lib" \
  "\$brew_prefix/opt/gcc/lib/gcc/current" \
  "\$brew_prefix/opt/libgccjit/lib/gcc/current" \
  "\$brew_prefix/opt/tree-sitter/lib"; do
  [[ -d "\$directory" ]] && library_paths+=("\$directory")
done
[[ -n "\${LD_LIBRARY_PATH:-}" ]] && library_paths+=("\$LD_LIBRARY_PATH")
if ((\${#library_paths[@]})); then
  IFS=:; export LD_LIBRARY_PATH="\${library_paths[*]}"; unset IFS
fi

export XDG_DATA_DIRS="\$root_dir/libexec/share:\${XDG_DATA_DIRS:-\$root_dir/share:/usr/local/share:/usr/share}"
export EMACSDATA="\$root_dir/share/emacs/$emacs_version/etc"
export EMACSPATH="\$root_dir/libexec/emacs/$emacs_version/$target_triplet"
export EMACSDOC="\$root_dir/share/emacs/$emacs_version/etc"
# Do not leave a trailing colon here. An empty EMACSLOADPATH element asks
# Emacs to append its compiled-in default path, which points back to the
# temporary Homebrew Cellar used to build the artifact.
export EMACSLOADPATH="\$root_dir/share/emacs/$emacs_version/lisp"

exec "\$root_dir/bin/emacs-$emacs_version" "\$@"
EOF
chmod 0755 "$stage_dir/bin/emacs"

# Desktop files are installed into the user's XDG data directory by the cask.
# Keep them portable in the release archive and let the cask substitute the
# active Homebrew prefix at install time.
for desktop_file in "$stage_dir"/share/applications/*.desktop; do
  [[ -f "$desktop_file" ]] || continue
  sed -i -E \
    -e 's#^Exec=emacs([[:space:]])#Exec=@HOMEBREW_PREFIX@/bin/emacs\1#' \
    -e 's#^Exec=emacsclient([[:space:]])#Exec=@HOMEBREW_PREFIX@/bin/emacsclient\1#' \
    -e 's#[^[:space:]\"]*/bin/emacsclient#@HOMEBREW_PREFIX@/bin/emacsclient#g' \
    "$desktop_file"
done

mkdir -p "$stage_dir/share/emacs-pgtk"
cat > "$stage_dir/share/emacs-pgtk/BUILD-MANIFEST.json" <<EOF
{
  "artifact": "$archive_root",
  "artifact_revision": "$artifact_revision",
  "build_commit": "$build_commit",
  "build_platform": "$build_platform",
  "compiler_target": "$compiler_target",
  "recipe": "Formula/emacs-pgtk.rb",
  "source": {
    "sha256": "$source_sha256",
    "url": "$source_url"
  },
  "version": "$emacs_version"
}
EOF

archive_path="$output_dir/$archive_root.tar.gz"
source_date_epoch="${SOURCE_DATE_EPOCH:-0}"
tar \
  --sort=name \
  --mtime="@$source_date_epoch" \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -cf - \
  -C "$work_dir" \
  "$archive_root" | gzip -n > "$archive_path"

checksum="$(sha256sum "$archive_path" | awk '{print $1}')"
printf '%s  %s\n' "$checksum" "$(basename "$archive_path")" > "$archive_path.sha256"
printf 'Created %s\nSHA-256: %s\n' "$archive_path" "$checksum"
