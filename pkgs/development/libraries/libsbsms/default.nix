{ callPackage, fetchurl }:
let
  prototype = callPackage ./common.nix { };
in
rec {
  libsbsms_2_0_2 = prototype.overrideAttrs (finalAttrs: _previousAttrs: {
    version = "2.0.2";
    src = fetchurl {
      url = "mirror://sourceforge/sbsms/libsbsms-${finalAttrs.version}.tar.gz";
      sha256 = "sha256-zqs9lwZkszcFe0a89VKD1Q0ynaY2v4PQ7nw24iNBru4=";
    };
    meta.homepage = "https://sourceforge.net/projects/sbsms/files/sbsms";
  });

  libsbsms_2_3_0 = prototype.overrideAttrs (finalAttrs: _previousAttrs: {
    version = "2.3.0";
    src = fetchurl {
      url = "https://github.com/claytonotey/libsbsms/archive/refs/tags/${finalAttrs.version}.tar.gz";
      sha256 = "sha256-T4jRUrwG/tvanV1lUX1AJUpzEMkFBgGpMSIwnUWv0sk=";
    };
    meta.homepage = "https://github.com/claytonotey/libsbsms";
  });

  libsbsms = libsbsms_2_0_2;
}
