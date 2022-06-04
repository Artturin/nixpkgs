{ stdenv, fetchurl, lib, file
, pkg-config, intltool
, glib, dbus-glib, json-glib
, gtkVersion ? null, gtk2 ? null, gtk3 ? null
, withVala ? stdenv.buildPlatform == stdenv.hostPlatform
, gobject-introspection, vala
}:

with lib;

stdenv.mkDerivation rec {
  pname = "libdbusmenu-${if gtkVersion == null then "glib" else "gtk${gtkVersion}"}";
  version = "16.04.0";

  src = fetchurl {
    url = "https://launchpad.net/dbusmenu/${lib.versions.majorMinor version}/${version}/+download/libdbusmenu-${version}.tar.gz";
    sha256 = "12l7z8dhl917iy9h02sxmpclnhkdjryn08r8i4sr8l3lrlm4mk5r";
  };

  strictDeps = true;
  nativeBuildInputs = [
    pkg-config
    intltool
    glib
  ] ++ lib.optionals withVala [
    vala
    gobject-introspection
  ];

  buildInputs = [
     dbus-glib json-glib
  ] ++ optional (gtkVersion != null) (if gtkVersion == "2" then gtk2 else gtk3)
    ++ lib.optionals withVala [
    gobject-introspection
  ];

  postPatch = ''
    for f in {configure,ltmain.sh,m4/libtool.m4}; do
      substituteInPlace $f \
        --replace /usr/bin/file ${file}/bin/file
    done
  '';

  # https://projects.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/libdbusmenu
  preConfigure = ''
    export HAVE_VALGRIND_TRUE="#"
    export HAVE_VALGRIND_FALSE=""
  '';

  configureFlags = [
    "CFLAGS=-Wno-error"
    "--sysconfdir=/etc"
    (lib.enableFeature withVala "vala")

    "--localstatedir=/var"
    (if gtkVersion == null then "--disable-gtk" else "--with-gtk=${gtkVersion}")
    "--disable-scrollkeeper"
  ] ++ optional (gtkVersion != "2") "--disable-dumper";

  doCheck = false; # generates shebangs in check phase, too lazy to fix

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "localstatedir=\${TMPDIR}"
    "typelibdir=${placeholder "out"}/lib/girepository-1.0"
  ];

  meta = {
    description = "Library for passing menu structures across DBus";
    homepage = "https://launchpad.net/dbusmenu";
    license = with licenses; [ gpl3 lgpl21 lgpl3 ];
    platforms = platforms.linux;
    maintainers = [ maintainers.msteen ];
  };
}
