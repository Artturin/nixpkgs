{ lib
, stdenv
, buildPackages
, targetPackages
, xorg
, gobject-introspection
, gobject-introspection-py-tools
, libffi
, glib
, rsync
}:

stdenv.mkDerivation rec {
  pname = "gobject-introspection-wrapper";
  version = "1.70.0";
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  dontStrip = true;
  dontFixup = true;

  nativeBuildInputs = [ xorg.lndir rsync ];

  propagatedBuildInputs = [
    libffi
    glib
  ];

  installPhase = ''
    runHook preInstall
    mkdir $out $out/lib $out/bin $out/share $out/nix-support $out/lib/pkgconfig
    #lndir ${buildPackages.gobject-introspection-py-tools}/bin $out/bin
    #lndir ${buildPackages.gobject-introspection.bin}/bin $out/bin
    #cp -r ${gobject-introspection.dev}/lib/pkgconfig/* $out/lib/pkgconfig
    mkdir -p $out

    rsync -r ${buildPackages.gobject-introspection.bin}/* $out
    rsync -rl ${gobject-introspection}/* $out
    rsync -r ${gobject-introspection.dev}/* $out
    rsync -r ${gobject-introspection-py-tools}/* $out

    #ls ${gobject-introspection-py-tools}
    #ln -s ${buildPackages.gobject-introspection.dev}/include $out

    sed \
      -e 's|^#bindir=placeholder|bindir=${placeholder "out"}/bin|g' \
      -e 's|^#g_ir_|g_ir_|g' \
      -i "$out/lib/pkgconfig"/*.pc

    rm -rf $out/nix-support
    runHook postInstall
  '';

  #postInstall = ''
  #  rm $out/nix-support/propagated-build-inputs
  #'';

}
