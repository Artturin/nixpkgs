{ lib
, stdenv
, substituteAll
}:

stdenv.mkDerivation {
  pname = "libsbsms";

  patches = [
    # Fix buidling on platforms other than x86
    (substituteAll {
      src = ./configure.patch;
      msse = lib.optionalString stdenv.isx86_64 "-msse";
    })
  ];

  doCheck = true;

  meta = {
    description = "Subband sinusoidal modeling library for time stretching and pitch scaling audio";
    maintainers = with lib.maintainers; [ yuu ];
    license = lib.licenses.gpl2;
    platforms = lib.platforms.all;
  };
}
