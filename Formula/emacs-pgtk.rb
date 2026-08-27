class EmacsPgtk < Formula
  desc "GNU Emacs text editor with the PGTK interface"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://ftpmirror.gnu.org/gnu/emacs/emacs-31.1.tar.xz"
  mirror "https://ftp.gnu.org/gnu/emacs/emacs-31.1.tar.xz"
  sha256 "1da5790d9580c81932b5bf700633114468da7b3412d69faa767daebf974f4586"
  license "GPL-3.0-or-later"
  compatibility_version 1

  depends_on "pkgconf" => :build
  depends_on "texinfo" => :build

  depends_on "alsa-lib"
  depends_on "at-spi2-core"
  depends_on "cairo"
  depends_on "dbus"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc"
  depends_on "gdk-pixbuf"
  depends_on "giflib"
  depends_on "glib"
  depends_on "glibc"
  depends_on "gmp"
  depends_on "gnutls"
  depends_on "gtk+3"
  depends_on "harfbuzz"
  depends_on "jpeg-turbo"
  depends_on "libgccjit"
  depends_on "libpng"
  depends_on "librsvg"
  depends_on "libtiff"
  depends_on "libxml2"
  depends_on :linux
  depends_on "little-cms2"
  depends_on "ncurses"
  depends_on "pango"
  depends_on "sqlite"
  depends_on "tree-sitter"
  depends_on "webp"
  depends_on "zlib-ng-compat"

  conflicts_with "emacs", because: "both install an emacs executable"
  conflicts_with cask: "emacs-app-linux"

  def install
    gcc_lib = formula_opt_lib("gcc")/"gcc/current"
    libgccjit_lib = formula_opt_lib("libgccjit")/"gcc/current"

    # Native compilation needs libgccjit both while Emacs is built and later
    # when a user package is compiled. Keep both libraries discoverable in the
    # executable's runpath; LIBRARY_PATH is also consumed by libgccjit's driver.
    ENV.append "CPPFLAGS", "-I#{formula_opt_include("libgccjit")}"
    ENV.append "LDFLAGS", "-L#{libgccjit_lib} -L#{gcc_lib}"
    ENV.append "LDFLAGS", "-Wl,-rpath,#{libgccjit_lib} -Wl,-rpath,#{gcc_lib}"
    ENV.prepend_path "LIBRARY_PATH", gcc_lib
    ENV.prepend_path "LIBRARY_PATH", libgccjit_lib

    args = %W[
      --prefix=#{prefix}
      --infodir=#{info}/emacs
      --enable-locallisppath=#{opt_share}/emacs/site-lisp/emacs-pgtk
      --disable-acl
      --disable-build-details
      --disable-silent-rules
      --disable-xattr
      --with-pgtk
      --with-native-compilation=aot
      --with-tree-sitter
      --with-gnutls
      --with-xml2
      --with-sqlite3
      --with-modules
      --with-cairo
      --with-rsvg
      --with-webp
      --with-jpeg
      --with-png
      --with-gif
      --with-tiff
      --with-lcms2
      --with-dbus
      --with-sound=alsa
      --without-imagemagick
      --without-gpm
      --without-libsystemd
      --without-selinux
      --without-libsmack
    ]

    # Emacs snapshots exec-path into its portable dump. Remove Homebrew's
    # temporary compiler shims so bottles do not retain build-machine paths.
    File.write "lisp/site-load.el", <<~LISP
      (setq exec-path (delete nil
        (mapcar
          (lambda (entry)
            (unless (string-match-p "Homebrew/shims" entry) entry))
          exec-path)))
    LISP

    system "./configure", *args
    system "make"
    system "make", "install"

    # Keep Emacs's compiled GSettings database private. Linking a second
    # gschemas.compiled into Homebrew's shared data directory would overwrite
    # another package's cache. The launcher adds this directory through XDG.
    (libexec/"share").mkpath
    mv share/"glib-2.0", libexec/"share"

    # AppStream metadata is useful to distribution software centers, but it is
    # not needed by Homebrew and can collide with another linked keg directory.
    rm_r share/"metainfo"

    (bin/"emacs").unlink
    (bin/"emacs").write <<~BASH
      #!/bin/bash
      xdg_data_dirs="${XDG_DATA_DIRS:-#{HOMEBREW_PREFIX}/share:/usr/local/share:/usr/share}"
      export XDG_DATA_DIRS="#{opt_libexec}/share:$xdg_data_dirs"
      exec "#{opt_bin}/emacs-#{version}" "$@"
    BASH
  end

  def post_install
    # Upstream creates this generic index even when locallisppath is scoped.
    # Leaving it at the shared site-lisp root conflicts with other formulae.
    (share/"emacs/site-lisp/subdirs.el").unlink if (share/"emacs/site-lisp/subdirs.el").exist?
  end

  def caveats
    <<~EOS
      This build uses Emacs's PGTK interface, which upstream recommends for
      Wayland. GTK can also select its X11 backend, but upstream recommends the
      regular GTK/X build for machines that use X11 exclusively.

      If no display server is available, start Emacs in terminal mode:
        emacs -nw
    EOS
  end

  test do
    lisp = <<~ELISP
      ;;; -*- lexical-binding: t; -*-
      (progn
        (unless (string-match-p "--with-pgtk" system-configuration-options)
          (error "PGTK is not compiled in"))
        (unless (and (fboundp 'native-comp-available-p)
                     (native-comp-available-p))
          (error "native compilation is unavailable"))
        (unless (and (fboundp 'treesit-available-p)
                     (treesit-available-p))
          (error "tree-sitter is unavailable"))
        (unless (and (fboundp 'sqlite-available-p)
                     (sqlite-available-p))
          (error "SQLite is unavailable"))
        (unless (gnutls-available-p)
          (error "GnuTLS is unavailable"))
        (unless module-file-suffix
          (error "dynamic modules are unavailable"))
        (unless (string-prefix-p "#{opt_libexec}/share:"
                                 (or (getenv "XDG_DATA_DIRS") ""))
          (error "private desktop data is missing from XDG_DATA_DIRS"))
        (princ "emacs-pgtk-ok"))
    ELISP

    (testpath/"test.el").write(lisp)
    assert_equal "emacs-pgtk-ok",
                 shell_output("#{bin}/emacs --batch --quick --load #{testpath}/test.el").strip
    assert_path_exists bin/"emacsclient"
    assert_match "Exec=emacs %F", (share/"applications/emacs.desktop").read
  end
end
