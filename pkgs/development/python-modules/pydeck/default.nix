{ lib
, buildPythonPackage
, fetchPypi
, ipykernel
, ipywidgets
, traitlets
, jinja2
, numpy
, pytestCheckHook
, pandas
, jupyter
}:

buildPythonPackage rec {
  pname = "pydeck";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "24ffadfba72cf610a413d49bd9542f2f4fd745f33d6535dd339b121e9e084be8";
  };

  propagatedBuildInputs = [
    ipykernel
    ipywidgets
    traitlets
    jinja2
    numpy
  ];

  checkInputs = [
    pytestCheckHook
    pandas
  ];

  # Uses network
  disabledTests = [ "test_nbconvert" ];

  meta = with lib; {
    description = "Widget for deck.gl maps";
    homepage = "https://github.com/visgl/deck.gl/tree/master/bindings/pydeck";
    license = licenses.asl20;
    maintainers = with maintainers; [ artturin ];
  };
}
