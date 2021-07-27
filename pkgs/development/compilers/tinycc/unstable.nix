{ lib, stdenv, callPackage, which, xcbuild, cctools, DarwinTools }:

callPackage ./base.nix rec {
  version = "unstable-2021-07-27";
  rev = "b1d9de679474627754be5b960c75907ebc944431";
  sha256 = "1fggahdh15dr9h6rz7hp61zn1ygbk3n4x3ksvisjcbc8p2dinvy5";

  extraNative = [ which ] 
    ++ lib.optionals stdenv.isDarwin [ xcbuild ];
  extraBuild = [ ] 
    ++ lib.optionals stdenv.isDarwin [ cctools DarwinTools ];
}
