{ lib
, pkgs
, stdenv
, fetchFromGitHub
, glfw
, freetype
, openssl
, git
, makeWrapper
, strace
, binutils-unwrapped
, libGL
, boehmgc
, sqlite
, libexecinfo
, xorg
, valgrind

, upx ? null
}:

assert stdenv.hostPlatform.isUnix -> upx != null;

stdenv.mkDerivation rec {
  pname = "vlang";
  version = "weekly.2021.29";

  #src = fetchFromGitHub {
  #  owner = "vlang";
  #  repo = "v";
  #  rev = version;
  #  sha256 = "03p2iny4mwd4ly5lg9cqkgyjiikwwy10iws4svkn7xs8x6qxgfyx";
  #};

  src = ../../../../../../v;

  # V compiler source translated to C for bootstrap.
  vc = fetchFromGitHub {
    owner = "vlang";
    repo = "vc";
    rev = "bee5e18046d0449260f981aec2de7ee849c3d6c0";
    sha256 = "0hs5n5sv8f01rf3id14k8j39paay4kka6k1n638i4pnh72gmh7cw";
  };

  # https://github.com/vlang/markdown
  markdown = fetchFromGitHub {
    owner = "vlang";
    repo = "markdown";
    rev = "1cda5d4a1538cac51504651cb5a4e02406807452";
    sha256 = "0g3r3z2q4ncg3lyi2wl7h8l025zr21j5jw72hq1v94645n6vx5i3";
  };

  nativeBuildInputs = [
    makeWrapper
    git
    strace
    libGL
    openssl
    boehmgc
    sqlite
    libexecinfo
    xorg.libX11.dev
    xorg.libX11
    xorg.xinput 
    xorg.libXi 
    xorg.libXext 
    xorg.libXcursor
    valgrind
  ];

  propagatedBuildInputs = [
    glfw
    freetype
    openssl
  ] ++ lib.optional stdenv.hostPlatform.isUnix upx;

  postPatch = ''
    substituteInPlace Makefile \
      --replace "rm -rf" "true" \
      --replace "git" "echo"
    substituteInPlace vlib/v/util/util.v \
      --replace "https://github.com/vlang" "gits" \
      --replace "git clone" "cp -r --no-preserve=mode"
  '';

  preBuild = ''
    export HOME=$PWD
    mkdir gits
    cp -r --no-preserve=mode $markdown gits/markdown
    cp -r --no-preserve=mode $vc vc
    export VERBOSE=1
    export VCREPO=vc
    export TCCREPO=
    export local=true
    makeFlagsArray+=(CFLAGS="-O2")
  '';

  postBuild = ''
    # Exclude thirdparty/vschannel as it is windows-specific.
    #filelist=$(find cmd -type f -name '*.v' | sed 's|cmd/v/help/help.v||; s|cmd/tools/vdoc/markdown.v||; s|cmd/tools/vdoc/vdoc.v||')
    rm -rf thirdparty/vschannel thirdparty/picoev
    find thirdparty -type f -name "*.c" -execdir cc -std=gnu11 $CFLAGS -w -c {} $LDFLAGS ';'
    ./v test-self
    ./v build-tools -v
    wrapProgram ./v \
      --prefix LD_LIBRARY_PATH : ${libPath} \
      --prefix PATH : ${lib.makeBinPath [
        stdenv.cc
        binutils-unwrapped
        ]
    }

  '';

  libPath = lib.makeLibraryPath (with pkgs; [
    libGL
    openssl
    boehmgc
    sqlite
    libexecinfo
    xorg.libX11.dev
    xorg.libX11
    xorg.xinput 
    xorg.libXi 
    xorg.libXext 
    xorg.libXcursor
    bintools-unwrapped
    valgrind
  ]);

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib,share}
    cp -r examples $out/share
    cp -r {cmd,vlib,thirdparty} $out/lib
    mv v $out/lib
    makeWrapper $out/lib/v $out/bin/v \
      --prefix LD_LIBRARY_PATH : ${libPath} \
      --prefix PATH : ${lib.makeBinPath [
        stdenv.cc
        binutils-unwrapped
        ]
    }
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://vlang.io/";
    description = "Simple, fast, safe, compiled language for developing maintainable software";
    license = licenses.mit;
    maintainers = with maintainers; [ chiiruno ];
    platforms = platforms.all;
  };
}
