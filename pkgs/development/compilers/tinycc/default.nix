{ lib, callPackage }:

callPackage ./base.nix rec {
  version = "0.9.27";
  upstreamVersion = "release_${lib.concatStringsSep "_" (builtins.splitVersion version)}";
  rev = upstreamVersion;
  sha256 = "12mm1lqywz0akr2yb2axjfbw8lwv57nh395vzsk534riz03ml977";
}
