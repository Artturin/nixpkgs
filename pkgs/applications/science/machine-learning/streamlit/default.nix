{   lib, buildPythonApplication, fetchPypi
  , altair, astor, base58, blinker, boto3, botocore, click, enum-compat
  , future, pillow, protobuf, requests, toml, tzlocal, validators, watchdog
  , jinja2, setuptools, pydeck
}:

buildPythonApplication rec {
  pname = "streamlit";
  version = "0.85.0";
  #format = "wheel"; # tar.gz wants pipenv

  src = fetchPypi {
    inherit pname version;
    sha256 = "1410zvknh6rsqf84pivp544jlk5mjjmyqy4c45kqa3pm8y3j8iw6";
  };

  propagatedBuildInputs = [
    altair astor base58 blinker boto3 botocore click enum-compat
    future pillow protobuf requests toml  tzlocal validators watchdog
    jinja2 setuptools pydeck
  ];

  postPatch = ''
    ls
    substituteInPlace setup.py \
      --replace "try:" "" \
      --replace "from pipenv.project import Project" "" \
      --replace "from pipenv.utils import convert_deps_to_pip" \
      --replace "except:" "" \
      --replace "sys.exit(exit_msg)" ""
  '';

  #prepipInstallPhase = ''
  #  substituteInPlace dist/streamlit-0.85.0-py2.py3-none-any.whl/streamlit-${version}.dist-info/METADATA \
  #    --replace "Requires-Dist: click (<8.0,>=7.0)" "Requires-Dist: click (<9.0,>=7.0)"
  #'';

  postInstall = ''
      rm $out/bin/streamlit.cmd # remove windows helper
  '';

  meta = with lib; {
    homepage = "https://streamlit.io/";
    description = "The fastest way to build custom ML tools";
    maintainers = with maintainers; [ yrashk ];
    license = licenses.asl20;
  };

}
