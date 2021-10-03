{ lib, stdenv, callPackage, which, xcbuild, cctools, DarwinTools }:

callPackage ./base.nix rec {
  version = "unstable-2021-07-27";
  rev = "dda95e9b0b30771369efe66b4a47e94cf0ca7dc0";
  sha256 = "sha256-7xK0p0XcSlQlKz+/gwX1WKp0ku6sy1cYW6jOZoFXKoU=";

  extraNative = [ which ] 
    ++ lib.optionals stdenv.isDarwin [ xcbuild ];
  extraBuild = [ ] 
    ++ lib.optionals stdenv.isDarwin [ cctools DarwinTools ];
}
