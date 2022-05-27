{
  lib,
  stdenv,
  ninja,
  fetchFromGitHub,
  fetchurl,
  cmake,
  pkg-config,
  peg,
  libffi,
  pcre,
  boehmgc,
  json_c,
  testers,
  ngs,
  buildMan ? true,
  pandoc,
}:

stdenv.mkDerivation rec {
  pname = "ngs";
  version = "0.2.14";

  #src = fetchFromGitHub {
  #  owner = "ngs-lang";
  #  repo = "ngs";
  #  rev = "v${version}";
  #  sha256 = "sha256-/l1qqp5l+g00O+/5phxyVDahNfB6kqCBRiIgS4AnN3c=";
  #};

  src = /home/artturin/ngs;

  doCheck = true;
  strictDeps = true;
  nativeBuildInputs = [

    cmake
    pkg-config
    ((peg.__spliced.buildHost or peg).overrideAttrs rec {
      version = "0.1.19";
      src = fetchurl {
        url = "http://piumarta.com/software/peg/peg-${version}.tar.gz";
        hash = "sha256-ABPdg6Zzl3hEWmS87T10ufUMB1U/hupDMzrl+rXCu7Q=";
      };
    })
  ] ++ lib.optionals buildMan [ pandoc ];

  buildInputs = [
    libffi
    pcre
    boehmgc
    json_c
  ];

  cmakeFlags = [ "-DBUILD_MAN=${if buildMan then "ON" else "OFF"}" ];

  postPatch = ''
    patchShebangs ./build-scripts
  '';

  passthru = {
    interpreter = "${ngs}/bin/ngs";
    tests.version = testers.testVersion { package = ngs; };
  };

  meta = with lib; {
    description = "Next Generation Shell";
    homepage = "https://ngs-lang.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ artturin ];
    platforms = platforms.all;
    # segfault while running scripts with the binary
    broken = stdenv.hostPlatform.isStatic;
  };
}

