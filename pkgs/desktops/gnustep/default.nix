{ newScope
, clangStdenv
}:

let
  callPackage = newScope self;

  self = rec {
    stdenv = clangStdenv;

    gsmakeDerivation = callPackage ./make/gsmakeDerivation.nix {};
    gorm = callPackage ./gorm {};
    projectcenter = callPackage ./projectcenter {};
    system_preferences = callPackage ./systempreferences {};
    libobjc = callPackage ./libobjc2 {};
    make = callPackage ./make {};
    back = callPackage ./back {};
    base = callPackage ./base { };
    gui = callPackage ./gui {};
    gworkspace = callPackage ./gworkspace {};
  };

in self
