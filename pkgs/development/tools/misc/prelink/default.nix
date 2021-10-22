{ lib, stdenv, fetchgit, libelf, autoreconfHook, libiberty }:

stdenv.mkDerivation rec {
  pname = "prelink";
  version = "unstable-2021-02-04";

  src = fetchgit {
    url = "https://git.yoctoproject.org/git/prelink-cross";
    branchName = "cross_prelink";
    rev = "f9975537dbfd9ade0fc813bd5cf5fcbe41753a37";
    sha256 = "sha256-O9/oZooLRyUBBZX3SFcB6LFMmi2vQqkUlqtZnrq5oZc=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    stdenv.cc.libc (lib.getOutput "static" stdenv.cc.libc)
    libelf libiberty
  ];

  # There are some failures to investigate
  doCheck = false;

  #preCheck = ''
  #  patchShebangs --build testsuite
  #'';

  meta = with lib; {
    homepage = "https://wiki.yoctoproject.org/wiki/Cross-Prelink";
    #homepage = "https://people.redhat.com/jakub/prelink/";
    license = "GPL";
    description = "ELF prelinking utility to speed up dynamic linking";
    platforms = platforms.linux;
  };
}
