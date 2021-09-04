{ lib, buildPythonPackage, fetchPypi, poster3 }:

buildPythonPackage rec {
  pname = "wikitools3";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-P1uQI2YJD0/nhbnLqqjxzGY8hkmqyRvZ9MX2DnddYq0=";
  };

  propagatedBuildInputs = [ poster3 ];

  pythonImportsCheck = [ "wikitools3" ];

  meta = with lib; {
    description = "Python package for working with MediaWiki wikis";
    homepage = "https://github.com/elsiehupp/wikitools3";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ artturin ];
  };
}
