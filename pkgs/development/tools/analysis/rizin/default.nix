{
  lib,
  pkgs, # for passthru.plugins
  stdenv,
  fetchurl,
  pkg-config,
  libusb-compat-0_1,
  readline,
  libewf,
  perl,
  pcre2,
  zlib,
  openssl,
  file,
  libmspack,
  libzip,
  lz4,
  xxHash,
  xz,
  meson,
  python3,
  cmake,
  ninja,
  capstone,
  tree-sitter,
  zstd,
}:

let
  rizin = stdenv.mkDerivation rec {
    pname = "rizin";
    version = "0.8.1";

    src = fetchurl {
      url = "https://github.com/rizinorg/rizin/releases/download/v${version}/rizin-src-v${version}.tar.xz";
      hash = "sha256-7yseZSXX3DasQ1JblWdJwcyge/F8H+2LZkAtggEKTsI=";
    };

    mesonFlags = [
      "-Duse_sys_capstone=enabled"
      "-Duse_sys_magic=enabled"
      "-Duse_sys_libzip=enabled"
      "-Duse_sys_zlib=enabled"
      "-Duse_sys_lz4=enabled"
      "-Duse_sys_libzstd=enabled"
      "-Duse_sys_lzma=enabled"
      "-Duse_sys_xxhash=enabled"
      "-Duse_sys_openssl=enabled"
      "-Duse_sys_libmspack=enabled"
      "-Duse_sys_tree_sitter=enabled"
      "-Duse_sys_pcre2=enabled"
      # this is needed for wrapping (adding plugins) to work
      "-Dportable=true"
    ];

    patches = [
      # Normally, Rizin only looks for files in the install prefix. With
      # portable=true, it instead looks for files in relation to the parent
      # of the directory of the binary file specified in /proc/self/exe,
      # caching it. This patch replaces the entire logic to only look at
      # the env var NIX_RZ_PREFIX
      ./librz-wrapper-support.patch
    ];

    nativeBuildInputs = [
      pkg-config
      meson
      (python3.withPackages (
        pp: with pp; [
          pyyaml
        ]
      ))
      ninja
      cmake
    ];

    # meson's find_library seems to not use our compiler wrapper if static parameter
    # is either true/false... We work around by also providing LIBRARY_PATH
    preConfigure = ''
      LIBRARY_PATH=""
      for b in ${toString (map lib.getLib buildInputs)}; do
        if [[ -d "$b/lib" ]]; then
          LIBRARY_PATH="$b/lib''${LIBRARY_PATH:+:}$LIBRARY_PATH"
        fi
      done
      export LIBRARY_PATH
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace binrz/rizin/macos_sign.sh \
        --replace 'codesign' '# codesign'
    '';

    buildInputs = [
      file
      libzip
      capstone
      readline
      libusb-compat-0_1
      libewf
      pcre2
      perl
      zlib
      lz4
      openssl
      libmspack
      tree-sitter
      xxHash
      xz
      zstd
    ];

    postPatch = ''
      # find_installation without arguments uses Meson’s Python interpreter,
      # which does not have any extra modules.
      # https://github.com/mesonbuild/meson/pull/9904
      substituteInPlace meson.build \
        --replace "import('python').find_installation()" "find_program('python3')"
    '';

    passthru = rec {
      plugins = {
        jsdec = pkgs.callPackage ./jsdec.nix {
          inherit rizin openssl;
        };
        rz-ghidra = pkgs.qt6.callPackage ./rz-ghidra.nix {
          inherit rizin openssl;
          enableCutterPlugin = false;
        };
        # sigdb isn't a real plugin, but it's separated from the main rizin
        # derivation so that only those who need it will download it
        sigdb = pkgs.callPackage ./sigdb.nix { };
      };
      withPlugins =
        filter:
        pkgs.callPackage ./wrapper.nix {
          inherit rizin;
          plugins = filter plugins;
        };
    };

    meta = {
      description = "UNIX-like reverse engineering framework and command-line toolset";
      homepage = "https://rizin.re/";
      license = lib.licenses.gpl3Plus;
      mainProgram = "rizin";
      maintainers = with lib.maintainers; [
        raskin
        makefu
        mic92
      ];
      platforms = with lib.platforms; unix;
    };
  };
in
rizin
