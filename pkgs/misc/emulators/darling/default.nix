{ lib
, stdenv
, fetchFromGitHub
, cmake
, libcap
, bison
, flex
, pkg-config
, fuse
, libarchive
, ffmpeg
, pulseaudio
, libX11
, freetype
, libtiff
, giflib
, fontconfig
, cairo
, expat
, libXrandr
, libXcursor
, libXdmcp
, libxkbfile
, pcre
, dbus
, glib
, clang_10
, libGLU
, libbsd
, python2
, openssl
, systemd
, libpng
, file
, sqlite
, ruby
, icu
, bzip2
, libunwind
#, clangStdenv
, llvmPackages
, perl
, gawk
}:
let
  inherit (llvmPackages) stdenv;
in

stdenv.mkDerivation rec {
  pname = "darling";
  version = "0.1.20210224";

  src = fetchFromGitHub {
    owner = "darlinghq";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-9+uG3Ks+pnfI34YrvE08jSDsboiwHN0qwjpG3HAXzLI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    bison
    flex
    pkg-config
    llvmPackages.llvm.dev
  ];

  buildInputs = [
    libunwind
    gawk
    bzip2
    perl
    icu
    sqlite
    ruby
    file
    libpng
    systemd
    libbsd
    python2
    openssl
    libGLU
    glib
    libcap
    fuse
    libarchive
    ffmpeg
    pulseaudio
    libX11
    freetype
    libtiff
    giflib
    fontconfig
    cairo
    expat
    libXrandr
    libXcursor
    pcre
    libXdmcp
    libxkbfile
    dbus
  ] ++ (with llvmPackages; [
    libclang
    lld
    llvm
  ]);

  buildFlags = [ "CC=clang" "CXX=clang++" "BUILD_CC=clang BUILD_CXX=clang++ BUILD_AS=clang" ];

  cmakeFlags = [
    # reduce build time during dev
    "-DTARGET_i386=OFF"
    "-DFULL_BUILD=OFF"
    # get rid of spammy warnings
    "-Wno-deprecated"
    "-Wno-error=unknown-warning"
  ];

  meta = with lib; {
    description = "Darwin/macOS emulation layer for Linux";
    homepage = "github.com/darlinghq/darling";
    license = licenses.gpl3;
    maintainers = with maintainers; [  ];
  };
}
