{ lib, stdenv
, buildPackages
, fetchurl
, glib
, flex
, bison
, makeSetupHook
, meson
, ninja
, gtk-doc
, docbook-xsl-nons
, docbook_xml_dtd_43
, docbook_xml_dtd_45
, pkg-config
, libffi
, python3
, cctools
, cairo
, gnome
, substituteAll
, writeText
, nixStoreDir ? builtins.storeDir
, x11Support ? stdenv.buildPlatform == stdenv.hostPlatform
, build_library_and_c_tools ? true
, build_python_tools ? true
, gi_cross_use_prebuilt_gi ? false
, build_introspection_data ?
    build_library_and_c_tools &&
    (build_python_tools || gi_cross_use_prebuilt_gi)
, gobject-introspection-py-tools ? null
}:

# now that gobject-introspection creates large .gir files (eg gtk3 case)
# it may be worth thinking about using multiple derivation outputs
# In that case its about 6MB which could be separated

assert build_library_and_c_tools || build_python_tools;
assert build_introspection_data -> build_library_and_c_tools;
assert gi_cross_use_prebuilt_gi -> gobject-introspection-py-tools != null;

let
  giSetupHook = makeSetupHook {
    name = "gobject-introspection-hook";
  } ./setup-hook.sh;
  mkFlag = name: cond: "-D${name}=${if cond then "true" else "false"}";
in

stdenv.mkDerivation rec {
  pname = "gobject-introspection";
  version = "1.70.0";

  # outputs TODO: share/gobject-introspection-1.0/tests is needed during build
  # by pygobject3 (and maybe others), but it's only searched in $out
  outputs = [ "out" ]
    ++ lib.optionals build_library_and_c_tools [ "dev" "bin" ]
    ++ [ "devdoc" "man" ];

  # Do not propogate the "bin" output, as it refers to the dev output.
  propagatedBuildOutputs = lib.optional build_library_and_c_tools "out";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0jpwraip7pwl9bf9s59am3r7074p34fasvfb5ym1fb8hwc34jawh";
  };

  patches = [
    # Make g-ir-scanner put absolute path to GIR files it generates
    # so that programs can just dlopen them without having to muck
    # with LD_LIBRARY_PATH environment variable.
    (substituteAll {
      src = ./absolute_shlib_path.patch;
      inherit nixStoreDir;
    })
	# We use this during the build, so patch shebangs in the fixed phase is too
	# later. This is a template for string substitution so patch shebangs of
	# the source is also too early.
    #(substituteAll {
    #  src = ./absolute-python-shebang.patch;
    #  python_bin = lib.escapeShellArg python3.interpreter;
    #})
  ] ++ lib.optionals x11Support [
    # Hardcode the cairo shared library path in the Cairo gir shipped with this package.
    # https://github.com/NixOS/nixpkgs/issues/34080
    (substituteAll {
      src = ./absolute_gir_path.patch;
      cairoLib = "${lib.getLib cairo}/lib";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    flex
    bison
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_45
    python3
  ] ++ lib.optionals (build_introspection_data && !gi_cross_use_prebuilt_gi) [
    giSetupHook # move .gir files
  ];

  buildInputs = [
    python3
  ] ++ lib.optionals gi_cross_use_prebuilt_gi [
    gobject-introspection-py-tools
  ];

  checkInputs = lib.optionals stdenv.isDarwin [
    cctools # for otool
  ];

  propagatedBuildInputs = [
    libffi
    glib
  ];

  strictDeps = true;

  mesonFlags = [
    "-Ddoctool=disabled"
    "-Dcairo=disabled"
    "-Dgtk_doc=true"
    (mkFlag "build_library_and_c_tools" build_library_and_c_tools)
    (mkFlag "build_python_tools" build_python_tools)
    (mkFlag "gi_cross_use_prebuilt_gi" gi_cross_use_prebuilt_gi)
    (mkFlag "build_introspection_data" build_introspection_data)
  ] ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    ("--cross-file=" + writeText "cross-file.conf" (''
      [binaries]
      exe_wrapper = ${lib.escapeShellArg (stdenv.hostPlatform.emulator buildPackages)}
    ''))
    "-Dgi_cross_ldd_wrapper=${buildPackages.prelink}/bin/prelink-rtld"
    "-Dgi_cross_binary_wrapper=${stdenv.hostPlatform.emulator buildPackages}"
  ] ++ lib.optional build_library_and_c_tools "--datadir=${placeholder "dev"}/share";

  doCheck = !stdenv.isAarch64;

  # During configurePhase, two python scripts are generated and need this. See
  # https://github.com/NixOS/nixpkgs/pull/98316#issuecomment-695785692
  postConfigure = ''
    patchShebangs tools/*
  '';

  preCheck = ''
    # Our gobject-introspection patches make the shared library paths absolute
    # in the GIR files. When running tests, the library is not yet installed,
    # though, so we need to replace the absolute path with a local one during build.
    # We are using a symlink that we will delete before installation.
    mkdir -p $out/lib
    ln -s $PWD/tests/scanner/libregress-1.0${stdenv.targetPlatform.extensions.sharedLibrary} $out/lib/libregress-1.0${stdenv.targetPlatform.extensions.sharedLibrary}
  '';

  postCheck = ''
    rm $out/lib/libregress-1.0${stdenv.targetPlatform.extensions.sharedLibrary}
  '';

  # Remove the bindir from the pkg-config file. We will add it back in a wrapper.
  postInstall = lib.optionalString build_library_and_c_tools ''
    sed -i '/bindir/d' "$out/lib/pkgconfig"/*.pc
  '';

  setupHook = if build_python_tools then giSetupHook else null;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = with lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage = "https://gi.readthedocs.io/";
    maintainers = teams.gnome.members ++ (with maintainers; [ lovek323 ]);
    platforms = platforms.unix;
    license = with licenses; [ gpl2 lgpl2 ];

    longDescription = ''
      GObject introspection is a middleware layer between C libraries (using
      GObject) and language bindings. The C library can be scanned at compile
      time and generate a metadata file, in addition to the actual native C
      library. Then at runtime, language bindings can read this metadata and
      automatically provide bindings to call into the C library.
    '';
  };
}
