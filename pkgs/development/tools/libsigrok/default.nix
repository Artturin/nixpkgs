{ lib, stdenv, fetchurl, pkg-config, libzip, glib, libusb1, libftdi1, check
, libserialport, librevisa, doxygen, glibmm, python
, version ? "0.5.2", sha256 ? "0g6fl684bpqm5p2z4j12c62m45j1dircznjina63w392ns81yd2d"
}:

stdenv.mkDerivation rec {
  inherit version;
  pname = "libsigrok";

  src = fetchurl {
    url = "https://sigrok.org/download/source/${pname}/${pname}-${version}.tar.gz";
    inherit sha256;
  };

  firmware = fetchurl {
    url = "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-0.1.7.tar.gz";
    sha256 = "1br32wfkbyg3v0bh5smwvn1wbkwmlscqvz2vdlx7irs9al3zsxn8";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libzip glib libusb1 libftdi1 check libserialport
    librevisa doxygen glibmm python
  ];

  postInstall = ''
    mkdir -p "$out/share/sigrok-firmware/"
    tar --strip-components=1 -xvf "${firmware}" -C "$out/share/sigrok-firmware/"
  '';

  meta = with lib; {
    description = "Core library of the sigrok signal analysis software suite";
    homepage = "https://sigrok.org/";
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [ maintainers.bjornfor ];
  };
}
