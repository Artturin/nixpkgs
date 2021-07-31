{ lib
, stdenv
, makeWrapper
, fetchurl
, rpmextract
, autoPatchelfHook
, alsa-lib
, cups
, gdk-pixbuf
, glib
, gtk3
, libnotify
, libuuid
, libX11
, libXScrnSaver
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libxcb
, libxshmfence
, mesa
, nspr
, nss
, pango
, systemd
, libappindicator-gtk3
, libdbusmenu

}:

stdenv.mkDerivation rec {
  pname = "tuxedo-control-center";
  version = "1.0.14";

  src = fetchurl {
    url = "https://rpm.tuxedocomputers.com/opensuse/15.2/x86_64/tuxedo-control-center_${version}.rpm";
    sha256 = "1fhcxf6jdb2b79pkyjxz6l78m8gbzlv0swncys6r17i08y2vv8d1";
  };


  nativeBuildInputs = [
    rpmextract
    makeWrapper
    alsa-lib
    autoPatchelfHook
    cups
    libXdamage
    libX11
    libXScrnSaver
    libXtst
    libxshmfence
    mesa
    nss
    libXrender
    gdk-pixbuf
    gtk3
  ];

  libPath = lib.makeLibraryPath [
    alsa-lib
    gdk-pixbuf
    glib
    gtk3
    libnotify
    libX11
    libXcomposite
    libuuid
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    nspr
    nss
    libxcb
    pango
    systemd
    libXScrnSaver
    libappindicator-gtk3
    libdbusmenu
  ];

  unpackPhase = ''
    mkdir -p $out/bin
    cd $out
    rpmextract $src
  '';

  installPhase = ''
    runHook preInstall

    wrapProgram $out/opt/${pname}/${pname} \
        --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/${pname}

    ln -s $out/opt/${pname}/${pname} $out/bin/

    runHook postInstall
  '';


  meta = with lib; {
    description = "A tool to help you control performance, energy, fan and comfort settings on TUXEDO laptops.";
    homepage = "github.com/tuxedocomputers/tuxedo-control-center";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
