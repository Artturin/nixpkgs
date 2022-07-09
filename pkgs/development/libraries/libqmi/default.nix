{ lib
, stdenv
, fetchFromGitLab
, meson
, mesonEmulatorHook
, ninja
, pkg-config
, gobject-introspection
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, help2man
, glib
, python3
, libgudev
, libmbim
, libqrtr-glib
, bash-completion
}:

let
  # arch disables them too currently
  # https://github.com/archlinux/svntogit-packages/blob/edb7b6032da30cbdc3e2a25b55f716e124548340/libqmi/trunk/PKGBUILD#L28
  # libqmi> ERROR: Error in gtkdoc helper script:
  # libqmi> ERROR: ['/nix/store/....-gtk-doc-1.33.2/bin/gtkdoc-mkhtml', '--path=/build/source/docs/reference/libqmi-glib:/build/source/build/docs/reference/libqmi-glib', 'libqmi-glib', '../libqmi-glib-docs.xml'] failed with status 6
  withDocs = false;
in

stdenv.mkDerivation rec {
  pname = "libqmi";
  version = "1.30.8";

  outputs = [ "out" "dev" ] ++ lib.optionals withDocs [ "devdoc" ];

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mobile-broadband";
    repo = "libqmi";
    rev = version;
    sha256 = "sha256-3MbuQxdnslZgDMC2aA5elWMIRzOwwc4Wm4oM9epf/fk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    python3
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    help2man
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    bash-completion
    libgudev
    libmbim
  ];

  propagatedBuildInputs = [
    glib
    libqrtr-glib
  ];

  postPatch = ''
    patchShebangs ./build-aux
    patchShebangs ./meson_post_install.py
  '';

  mesonFlags = [
    "-Dgtk_doc=${lib.boolToString withDocs}"
    # uses help2man
    "-Dman=${lib.boolToString (stdenv.buildPlatform.canExecute stdenv.hostPlatform)}"
    "-Dudevdir=${placeholder "out"}/lib/udev"
  ];

  enableParallelBuilding = true;

  doCheck = true;

  meta = with lib; {
    homepage = "https://www.freedesktop.org/wiki/Software/libqmi/";
    description = "Modem protocol helper library";
    maintainers = teams.freedesktop.members;
    platforms = platforms.linux;
    license = with licenses; [
      # Library
      lgpl2Plus
      # Tools
      gpl2Plus
    ];
    changelog = "https://gitlab.freedesktop.org/mobile-broadband/libqmi/-/blob/${version}/NEWS";
  };
}
